import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';
import 'dart:io';
import '../models/user_profile.dart';
import '../models/visitor_log.dart';
import '../models/maintenance_bill.dart';
import '../models/helpdesk_ticket.dart';
import '../models/society.dart';

final logger = Logger();

class SupabaseService {
  late final SupabaseClient _client;

  SupabaseService() {
    _client = Supabase.instance.client;
  }

  // Auth Methods
  Future<AuthResponse> signUpWithEmail(String email, String password) async {
    try {
      final response =
          await _client.auth.signUp(email: email, password: password);
      logger.i('Sign up successful: ${response.user?.id}');
      return response;
    } catch (e) {
      logger.e('Sign up error: $e');
      rethrow;
    }
  }

  Future<AuthResponse> signInWithEmail(String email, String password) async {
    try {
      final response = await _client.auth
          .signInWithPassword(email: email, password: password);
      logger.i('Login successful: ${response.user?.id}');
      return response;
    } catch (e) {
      logger.e('Login error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
      logger.i('Logged out successfully');
    } catch (e) {
      logger.e('Logout error: $e');
      rethrow;
    }
  }

  // Phone OTP Authentication
  Future<void> signInWithPhone(String phone) async {
    try {
      await _client.auth.signInWithOtp(phone: phone);
      logger.i('OTP sent to phone: $phone');
    } catch (e) {
      logger.e('Error sending OTP: $e');
      rethrow;
    }
  }

  Future<AuthResponse> verifyPhoneOTP(String phone, String token) async {
    try {
      final response = await _client.auth.verifyOTP(
        phone: phone,
        token: token,
        type: OtpType.sms,
      );
      logger.i('Phone OTP verified successfully: ${response.user?.id}');
      return response;
    } catch (e) {
      logger.e('OTP verification error: $e');
      rethrow;
    }
  }

  Session? get currentSession => _client.auth.currentSession;
  User? get currentUser => _client.auth.currentUser;

  // Profile Methods
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response != null) {
        logger.i('Profile fetched: ${response['full_name']}');
        return UserProfile.fromJson(response);
      }
      return null;
    } catch (e) {
      logger.e('Error fetching profile: $e');
      rethrow;
    }
  }

  // Recovery: Get or create profile if missing (for users logged in without profile)
  Future<UserProfile?> getOrCreateUserProfile(String userId,
      {String? fallbackName}) async {
    try {
      var profile = await getUserProfile(userId);

      // If profile exists, return it
      if (profile != null) {
        return profile;
      }

      // Profile doesn't exist - create with fallback name
      logger.w('Profile missing for user $userId - creating default profile');
      await createUserProfile(
        id: userId,
        fullName: fallbackName ?? 'User ${userId.substring(0, 8)}',
        phoneNumber: null,
        email: null,
        societyId: 'soc_001', // Default to first society for fallback
        role: 'resident',
      );

      // Fetch the newly created profile
      profile = await getUserProfile(userId);
      logger.i('Default profile created: ${profile?.fullName}');
      return profile;
    } catch (e) {
      logger.e('Error in getOrCreateUserProfile: $e');
      rethrow;
    }
  }

  // Visitor Logs
  Future<List<VisitorLog>> getVisitorLogs(String unitId) async {
    try {
      final response = await _client
          .from('visitor_logs')
          .select()
          .eq('unit_id', unitId)
          .order('entry_at', ascending: false);

      logger.i('Visitor logs fetched: ${response.length}');
      return [for (final item in response) VisitorLog.fromJson(item)];
    } catch (e) {
      logger.e('Error fetching visitor logs: $e');
      rethrow;
    }
  }

  Future<void> createVisitorLog({
    required String unitId,
    required String visitorName,
    required String purpose,
  }) async {
    try {
      await _client.from('visitor_logs').insert({
        'unit_id': unitId,
        'visitor_name': visitorName,
        'purpose': purpose,
        'status': 'pending',
      });
      logger.i('Visitor log created for: $visitorName');
    } catch (e) {
      logger.e('Error creating visitor log: $e');
      rethrow;
    }
  }

  // Maintenance Bills
  Future<List<MaintenanceBill>> getMaintenanceBills(String unitId) async {
    try {
      final response = await _client
          .from('maintenance_bills')
          .select()
          .eq('unit_id', unitId)
          .order('due_date', ascending: true);

      logger.i('Bills fetched: ${response.length}');
      return [for (final item in response) MaintenanceBill.fromJson(item)];
    } catch (e) {
      logger.e('Error fetching bills: $e');
      rethrow;
    }
  }

  // Helpdesk Tickets
  Future<List<HelpdeskTicket>> getHelpdeskTickets(String residentId) async {
    try {
      final response = await _client
          .from('helpdesk_tickets')
          .select()
          .eq('resident_id', residentId)
          .order('created_at', ascending: false);

      logger.i('Tickets fetched: ${response.length}');
      return [for (final item in response) HelpdeskTicket.fromJson(item)];
    } catch (e) {
      logger.e('Error fetching tickets: $e');
      rethrow;
    }
  }

  Future<void> createHelpdeskTicket({
    required String residentId,
    required String category,
    required String description,
  }) async {
    try {
      await _client.from('helpdesk_tickets').insert({
        'resident_id': residentId,
        'category': category,
        'description': description,
        'status': 'open',
      });
      logger.i('Ticket created: $category');
    } catch (e) {
      logger.e('Error creating ticket: $e');
      rethrow;
    }
  }

  // Test Connection
  Future<bool> testConnection() async {
    try {
      await _client.from('societies').select().limit(1);
      logger.i('Connection test successful');
      return true;
    } catch (e) {
      logger.e('Connection test failed: $e');
      return false;
    }
  }

  // ==================== SOCIETY & UNIT METHODS ====================

  /// Fetch all societies
  Future<List<Society>> getSocieties() async {
    try {
      final response = await _client.from('societies').select();
      logger.i('Societies fetched: ${response.length}');
      return [for (final item in response) Society.fromJson(item)];
    } catch (e) {
      logger.e('Error fetching societies: $e');
      rethrow;
    }
  }

  /// Fetch units by society
  Future<List<Unit>> getUnitsBySociety(String societyId) async {
    try {
      final response = await _client
          .from('units')
          .select()
          .eq('society_id', societyId)
          .order('flat_no', ascending: true);

      logger.i('Units fetched for society $societyId: ${response.length}');
      return [for (final item in response) Unit.fromJson(item)];
    } catch (e) {
      logger.e('Error fetching units: $e');
      rethrow;
    }
  }

  // ==================== AUTH WITH SOCIETY & FLAT ====================

  /// Sign up with email and society selection
  Future<AuthResponse> signUpWithEmailAndSociety({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    required String societyId,
    required String flatId,
  }) async {
    try {
      // 1. Create user in auth
      final authResponse = await _client.auth.signUp(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        throw Exception('User creation failed');
      }

      // 2. Create user profile
      await _client.from('profiles').insert({
        'id': authResponse.user!.id,
        'full_name': fullName,
        'phone_number': phoneNumber,
        'email': email,
        'society_id': societyId,
        'unit_id': flatId,
        'role': 'resident',
      });

      logger.i('✅ User registered: $email with society: $societyId');
      return authResponse;
    } catch (e) {
      logger.e('Sign up error: $e');
      rethrow;
    }
  }

  /// Update user profile with profile details and society
  Future<void> createUserProfile({
    required String id,
    required String fullName,
    String? phoneNumber,
    String? email,
    required String societyId,
    String? unitId,
    String role = 'resident',
  }) async {
    try {
      await _client.from('profiles').insert({
        'id': id,
        'full_name': fullName,
        'phone_number': phoneNumber,
        'email': email,
        'society_id': societyId,
        'unit_id': unitId,
        'role': role,
      });
      logger.i('Profile created for: $fullName in society: $societyId');
    } catch (e) {
      logger.e('Error creating profile: $e');
      rethrow;
    }
  }

  /// Create profile for phone-authenticated users
  Future<void> createPhoneProfile({
    required String fullName,
    required String phoneNumber,
    required String societyId,
    required String flatId,
  }) async {
    try {
      final userId = currentUser?.id;
      if (userId == null) {
        throw Exception('No authenticated user found');
      }

      await createUserProfile(
        id: userId,
        fullName: fullName,
        phoneNumber: phoneNumber,
        societyId: societyId,
        unitId: flatId,
        role: 'resident',
      );
      logger.i('Phone profile created for: $fullName');
    } catch (e) {
      logger.e('Error creating phone profile: $e');
      rethrow;
    }
  }

  // ==================== FILE UPLOAD ====================

  /// Upload file to Supabase Storage
  Future<String> uploadDocument({
    required File file,
    required String userId,
    required String documentType,
  }) async {
    try {
      final fileName =
          '${userId}_${documentType}_${DateTime.now().millisecondsSinceEpoch}.${file.path.split('.').last}';
      final path = 'documents/$userId/$fileName';

      await _client.storage.from('documents').upload(path, file);

      final url = _client.storage.from('documents').getPublicUrl(path);

      // Save file reference in database
      await _client.from('user_documents').insert({
        'user_id': userId,
        'document_type': documentType,
        'file_url': url,
        'file_name': fileName,
      });

      logger.i('Document uploaded: $fileName');
      return url;
    } catch (e) {
      logger.e('Error uploading document: $e');
      rethrow;
    }
  }

  /// Get user documents
  Future<List<Map<String, dynamic>>> getUserDocuments(String userId) async {
    try {
      final response = await _client
          .from('user_documents')
          .select()
          .eq('user_id', userId)
          .order('uploaded_at', ascending: false);

      logger.i('User documents fetched: ${response.length}');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      logger.e('Error fetching documents: $e');
      rethrow;
    }
  }

  // ==================== VISITOR MANAGEMENT ====================

  /// Import VisitorManagement model
  /// import '../models/visitor_management.dart';

  /// Create new visitor record
  Future<String> createVisitorRecord({
    required String societyId,
    required String? blockNumber,
    required String flatNumber,
    required String visitorName,
    required String? visitorPhone,
    required String purpose,
    required String category,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await _client.from('visitor_management').insert({
        'society_id': societyId,
        'block_number': blockNumber,
        'flat_number': flatNumber,
        'visitor_name': visitorName,
        'visitor_phone': visitorPhone,
        'purpose': purpose,
        'category': category,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
        'created_by_user_id': currentUser?.id,
        'metadata': metadata,
      }).select();

      final recordId = response[0]['id'] as String;
      logger.i('Visitor record created: $recordId');
      return recordId;
    } catch (e) {
      logger.e('Error creating visitor record: $e');
      rethrow;
    }
  }

  /// Get all pending visitors for a society
  Future<List<Map<String, dynamic>>> getPendingVisitors(
      String societyId) async {
    try {
      final response = await _client
          .from('visitor_management')
          .select()
          .eq('society_id', societyId)
          .eq('status', 'pending')
          .order('created_at', ascending: false);

      logger.i('Pending visitors fetched: ${response.length}');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      logger.e('Error fetching pending visitors: $e');
      rethrow;
    }
  }

  /// Approve visitor
  Future<void> approveVisitor(String visitorId) async {
    try {
      await _client.from('visitor_management').update({
        'status': 'approved',
        'approved_by_user_id': currentUser?.id,
      }).eq('id', visitorId);

      logger.i('Visitor approved: $visitorId');
    } catch (e) {
      logger.e('Error approving visitor: $e');
      rethrow;
    }
  }

  /// Reject visitor
  Future<void> rejectVisitor(String visitorId) async {
    try {
      await _client
          .from('visitor_management')
          .update({'status': 'rejected'}).eq('id', visitorId);

      logger.i('Visitor rejected: $visitorId');
    } catch (e) {
      logger.e('Error rejecting visitor: $e');
      rethrow;
    }
  }

  /// Mark visitor as checked in
  Future<void> checkInVisitor(String visitorId, {String? gateId}) async {
    try {
      await _client.from('visitor_management').update({
        'status': 'in',
        'entry_time': DateTime.now().toIso8601String(),
        'entry_gate_id': gateId,
      }).eq('id', visitorId);

      logger.i('Visitor checked in: $visitorId');
    } catch (e) {
      logger.e('Error checking in visitor: $e');
      rethrow;
    }
  }

  /// Mark visitor as checked out
  Future<void> checkOutVisitor(String visitorId, {String? gateId}) async {
    try {
      await _client.from('visitor_management').update({
        'status': 'out',
        'exit_time': DateTime.now().toIso8601String(),
        'exit_gate_id': gateId,
      }).eq('id', visitorId);

      logger.i('Visitor checked out: $visitorId');
    } catch (e) {
      logger.e('Error checking out visitor: $e');
      rethrow;
    }
  }

  /// Get today's all visitor logs (tower guard view)
  Future<List<Map<String, dynamic>>> getTodayVisitors(String societyId) async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = today.add(const Duration(days: 1));

      final response = await _client
          .from('visitor_management')
          .select()
          .eq('society_id', societyId)
          .gte('created_at', today.toIso8601String())
          .lt('created_at', tomorrow.toIso8601String())
          .order('created_at', ascending: false);

      logger.i('Today visitors fetched: ${response.length}');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      logger.e('Error fetching today visitors: $e');
      rethrow;
    }
  }

  /// Get currently inside visitors (status = 'in')
  Future<List<Map<String, dynamic>>> getCurrentlyInsideVisitors(
      String societyId) async {
    try {
      final response = await _client
          .from('visitor_management')
          .select()
          .eq('society_id', societyId)
          .eq('status', 'in')
          .order('entry_time', ascending: false);

      logger.i('Currently inside visitors fetched: ${response.length}');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      logger.e('Error fetching inside visitors: $e');
      rethrow;
    }
  }

  /// Get daily visitor report
  Future<Map<String, dynamic>> getDailyVisitorReport(String societyId) async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = today.add(const Duration(days: 1));

      final allVisitors = await _client
          .from('visitor_management')
          .select()
          .eq('society_id', societyId)
          .gte('created_at', today.toIso8601String())
          .lt('created_at', tomorrow.toIso8601String());

      int approved = 0;
      int checkedIn = 0;
      int checkedOut = 0;
      int pending = 0;
      int rejected = 0;

      for (var visitor in allVisitors) {
        switch (visitor['status']) {
          case 'approved':
            approved++;
            break;
          case 'in':
            checkedIn++;
            break;
          case 'out':
            checkedOut++;
            break;
          case 'pending':
            pending++;
            break;
          case 'rejected':
            rejected++;
            break;
        }
      }

      return {
        'total': allVisitors.length,
        'approved': approved,
        'checked_in': checkedIn,
        'checked_out': checkedOut,
        'pending': pending,
        'rejected': rejected,
        'currently_inside': checkedIn,
      };
    } catch (e) {
      logger.e('Error generating daily report: $e');
      rethrow;
    }
  }
}
