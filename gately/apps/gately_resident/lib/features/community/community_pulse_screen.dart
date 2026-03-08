import 'package:flutter/material.dart';
import 'package:gately_core/gately_core.dart';
import 'package:intl/intl.dart';

class CommunityPulseScreen extends StatefulWidget {
  final UserProfile userProfile;

  const CommunityPulseScreen({super.key, required this.userProfile});

  @override
  State<CommunityPulseScreen> createState() => _CommunityPulseScreenState();
}

class _CommunityPulseScreenState extends State<CommunityPulseScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _supabaseService = SupabaseService();

  List<CommunityNotice> _notices = [];
  List<CommunityPoll> _polls = [];
  List<CommunityClassified> _classifieds = [];
  bool _loading = true;
  String _classifiedCategory = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    try {
      final notices = await _supabaseService.getNotices(widget.userProfile.societyId);
      final polls = await _supabaseService.getPolls(
        widget.userProfile.societyId,
        userId: widget.userProfile.id,
      );
      final classifieds = await _supabaseService.getClassifieds(
        widget.userProfile.societyId,
        category: _classifiedCategory == 'all' ? null : _classifiedCategory,
      );
      if (mounted) {
        setState(() {
          _notices = notices;
          _polls = polls;
          _classifieds = classifieds;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Pulse'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.campaign), text: 'Notices'),
            Tab(icon: Icon(Icons.poll), text: 'Polls'),
            Tab(icon: Icon(Icons.shopping_bag), text: 'Classifieds'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildNoticesTab(),
                _buildPollsTab(),
                _buildClassifiedsTab(),
              ],
            ),
    );
  }

  Widget _buildNoticesTab() {
    if (_notices.isEmpty) {
      return _emptyState(
        icon: Icons.campaign_outlined,
        title: 'No notices yet',
        subtitle: 'Society notices will appear here.',
      );
    }
    return RefreshIndicator(
      onRefresh: _loadAll,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _notices.length,
        itemBuilder: (context, i) {
          final n = _notices[i];
          if (n.isExpired) return const SizedBox.shrink();
          return _NoticeCard(notice: n);
        },
      ),
    );
  }

  Widget _buildPollsTab() {
    if (_polls.isEmpty) {
      return _emptyState(
        icon: Icons.poll_outlined,
        title: 'No polls yet',
        subtitle: 'Community polls will appear here.',
      );
    }
    return RefreshIndicator(
      onRefresh: _loadAll,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _polls.length,
        itemBuilder: (context, i) => _PollCard(
          poll: _polls[i],
          userId: widget.userProfile.id,
          onVote: () => _loadAll(),
          supabaseService: _supabaseService,
        ),
      ),
    );
  }

  Widget _buildClassifiedsTab() {
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              _buildCategoryChip('all'),
              ...CommunityClassified.categories.map(_buildCategoryChip),
            ],
          ),
        ),
        Expanded(
          child: _classifieds.isEmpty
              ? _emptyState(
                  icon: Icons.shopping_bag_outlined,
                  title: 'No classifieds',
                  subtitle: 'Tap + to post one.',
                )
              : RefreshIndicator(
                  onRefresh: _loadAll,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _classifieds.length,
                    itemBuilder: (context, i) =>
                        _ClassifiedCard(classified: _classifieds[i]),
                  ),
                ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _showPostClassifiedDialog(),
                icon: const Icon(Icons.add),
                label: const Text('Post Classified'),
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String cat) {
    final selected = _classifiedCategory == cat;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(cat == 'all' ? 'All' : cat.toUpperCase()),
        selected: selected,
        onSelected: (_) async {
          setState(() => _classifiedCategory = cat);
          final list = await _supabaseService.getClassifieds(
            widget.userProfile.societyId,
            category: cat == 'all' ? null : cat,
          );
          if (mounted) setState(() => _classifieds = list);
        },
      ),
    );
  }

  Widget _emptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showPostClassifiedDialog() {
    final title = TextEditingController();
    final desc = TextEditingController();
    final contact = TextEditingController();
    String category = 'sell';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Post Classified',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: title,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: category,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: CommunityClassified.categories
                      .map((c) => DropdownMenuItem(
                            value: c,
                            child: Text(c.toUpperCase()),
                          ))
                      .toList(),
                  onChanged: (v) => category = v ?? 'sell',
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: desc,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: contact,
                  decoration: const InputDecoration(
                    labelText: 'Contact number',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () async {
                    if (title.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Enter a title')),
                      );
                      return;
                    }
                    try {
                      await _supabaseService.createClassified(
                        societyId: widget.userProfile.societyId,
                        title: title.text.trim(),
                        description: desc.text.trim().isEmpty
                            ? null
                            : desc.text.trim(),
                        category: category,
                        contactPhone: contact.text.trim().isEmpty
                            ? null
                            : contact.text.trim(),
                        contactName: widget.userProfile.fullName,
                      );
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Classified posted!')),
                        );
                        _loadAll();
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    }
                  },
                  child: const Text('Post'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

class _NoticeCard extends StatelessWidget {
  final CommunityNotice notice;

  const _NoticeCard({required this.notice});

  @override
  Widget build(BuildContext context) {
    final isUrgent = notice.isUrgent;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isUrgent ? Colors.red.shade50 : null,
      child: InkWell(
        onTap: () => showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(notice.title),
            content: SingleChildScrollView(
              child: Text(notice.body),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isUrgent ? Icons.warning_amber : Icons.campaign,
                    color: isUrgent ? Colors.red : Colors.orange,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      notice.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  if (isUrgent)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'URGENT',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                notice.body,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                DateFormat('MMM d, y • h:mm a').format(notice.createdAt),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PollCard extends StatelessWidget {
  final CommunityPoll poll;
  final String userId;
  final VoidCallback onVote;
  final SupabaseService supabaseService;

  const _PollCard({
    required this.poll,
    required this.userId,
    required this.onVote,
    required this.supabaseService,
  });

  @override
  Widget build(BuildContext context) {
    final total = poll.totalVotes;
    final voted = poll.userVotedOptionId != null;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              poll.question,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (poll.endsAt != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Ends ${DateFormat('MMM d').format(poll.endsAt!)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            const SizedBox(height: 12),
            ...poll.options.map((opt) {
              final pct = total > 0 ? (opt.voteCount / total) : 0.0;
              final isVoted = poll.userVotedOptionId == opt.id;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: poll.isEnded || voted
                        ? null
                        : () async {
                            try {
                              await supabaseService.votePoll(
                                  poll.id, opt.id, userId);
                              onVote();
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('$e')),
                                );
                              }
                            }
                          },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isVoted
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey.shade300,
                          width: isVoted ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(opt.optionText),
                                if (voted || poll.isEnded)
                                  const SizedBox(height: 4),
                                if (voted || poll.isEnded)
                                  LinearProgressIndicator(
                                    value: pct,
                                    backgroundColor: Colors.grey.shade200,
                                  ),
                                if (voted || poll.isEnded)
                                  Text(
                                    '${opt.voteCount} votes',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (isVoted)
                            Icon(
                              Icons.check_circle,
                              color: Theme.of(context).colorScheme.primary,
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _ClassifiedCard extends StatelessWidget {
  final CommunityClassified classified;

  const _ClassifiedCard({required this.classified});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: Colors.orange.shade100,
          child: Icon(
            Icons.shopping_bag,
            color: Colors.orange.shade700,
          ),
        ),
        title: Text(
          classified.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (classified.description != null &&
                classified.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  classified.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    classified.category.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade800,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat('MMM d').format(classified.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: classified.contactPhone != null
            ? IconButton(
                icon: const Icon(Icons.phone),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Contact: ${classified.contactPhone}')),
                  );
                },
              )
            : null,
      ),
    );
  }
}
