class CommunityPoll {
  final String id;
  final String societyId;
  final String question;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime? endsAt;
  final List<CommunityPollOption> options;
  final String? userVotedOptionId;

  CommunityPoll({
    required this.id,
    required this.societyId,
    required this.question,
    this.createdBy,
    required this.createdAt,
    this.endsAt,
    required this.options,
    this.userVotedOptionId,
  });

  factory CommunityPoll.fromJson(Map<String, dynamic> json,
      {List<CommunityPollOption>? options, String? userVotedOptionId}) {
    return CommunityPoll(
      id: json['id'] as String,
      societyId: json['society_id'] as String,
      question: json['question'] as String,
      createdBy: json['created_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      endsAt: json['ends_at'] != null
          ? DateTime.parse(json['ends_at'] as String)
          : null,
      options: options ?? [],
      userVotedOptionId: userVotedOptionId,
    );
  }

  int get totalVotes => options.fold(0, (sum, o) => sum + o.voteCount);
  bool get isEnded =>
      endsAt != null && DateTime.now().isAfter(endsAt!);
}

class CommunityPollOption {
  final String id;
  final String pollId;
  final String optionText;
  final int voteCount;

  CommunityPollOption({
    required this.id,
    required this.pollId,
    required this.optionText,
    this.voteCount = 0,
  });

  factory CommunityPollOption.fromJson(Map<String, dynamic> json) {
    return CommunityPollOption(
      id: json['id'] as String,
      pollId: json['poll_id'] as String,
      optionText: json['option_text'] as String,
      voteCount: json['vote_count'] as int? ?? 0,
    );
  }
}
