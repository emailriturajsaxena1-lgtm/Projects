import 'package:flutter_test/flutter_test.dart';
import 'package:mygate_clone/core/models/visitor_management.dart';

void main() {
  group('Visitor Management Service Tests', () {
    group('VisitorManagement Model Logic', () {
      test('statusDisplay returns correct text for pending status', () {
        final visitor = VisitorManagement(
          id: 'test_1',
          societyId: 'soc_001',
          flatNumber: '101',
          visitorName: 'Test Visitor',
          purpose: 'Meeting',
          category: 'guest',
          status: 'pending',
          createdAt: DateTime.now(),
        );

        expect(visitor.statusDisplay, 'Awaiting Approval');
      });

      test('statusDisplay returns correct text for approved status', () {
        final visitor = VisitorManagement(
          id: 'test_1',
          societyId: 'soc_001',
          flatNumber: '101',
          visitorName: 'Test Visitor',
          purpose: 'Meeting',
          category: 'guest',
          status: 'approved',
          createdAt: DateTime.now(),
        );

        expect(visitor.statusDisplay, 'Approved');
      });

      test('statusDisplay returns correct text for in status', () {
        final visitor = VisitorManagement(
          id: 'test_1',
          societyId: 'soc_001',
          flatNumber: '101',
          visitorName: 'Test Visitor',
          purpose: 'Meeting',
          category: 'guest',
          status: 'in',
          createdAt: DateTime.now(),
        );

        expect(visitor.statusDisplay, 'Currently Inside');
      });

      test('statusDisplay returns correct text for out status', () {
        final visitor = VisitorManagement(
          id: 'test_1',
          societyId: 'soc_001',
          flatNumber: '101',
          visitorName: 'Test Visitor',
          purpose: 'Meeting',
          category: 'guest',
          status: 'out',
          createdAt: DateTime.now(),
        );

        expect(visitor.statusDisplay, 'Checked Out');
      });

      test('statusDisplay returns correct text for rejected status', () {
        final visitor = VisitorManagement(
          id: 'test_1',
          societyId: 'soc_001',
          flatNumber: '101',
          visitorName: 'Test Visitor',
          purpose: 'Meeting',
          category: 'guest',
          status: 'rejected',
          createdAt: DateTime.now(),
        );

        expect(visitor.statusDisplay, 'Rejected');
      });

      test('visitDuration calculation is correct', () {
        final now = DateTime.now();
        final entryTime = now.subtract(const Duration(hours: 1, minutes: 30));
        final exitTime = now;

        final visitor = VisitorManagement(
          id: 'test_1',
          societyId: 'soc_001',
          flatNumber: '101',
          visitorName: 'Test Visitor',
          purpose: 'Meeting',
          category: 'guest',
          status: 'out',
          createdAt: now,
          entryTime: entryTime,
          exitTime: exitTime,
        );

        final duration = visitor.visitDuration;
        expect(duration, isNotNull);
        expect(duration!.inHours, 1);
        expect(duration.inMinutes, 90);
      });

      test('isInside returns true when status is in', () {
        final visitor = VisitorManagement(
          id: 'test_1',
          societyId: 'soc_001',
          flatNumber: '101',
          visitorName: 'Test Visitor',
          purpose: 'Meeting',
          category: 'guest',
          status: 'in',
          createdAt: DateTime.now(),
        );

        expect(visitor.isInside, isTrue);
      });

      test('isInside returns false when status is not in', () {
        final visitor = VisitorManagement(
          id: 'test_1',
          societyId: 'soc_001',
          flatNumber: '101',
          visitorName: 'Test Visitor',
          purpose: 'Meeting',
          category: 'guest',
          status: 'out',
          createdAt: DateTime.now(),
        );

        expect(visitor.isInside, isFalse);
      });

      test('canCheckIn returns true only for approved status', () {
        final approvedVisitor = VisitorManagement(
          id: 'test_1',
          societyId: 'soc_001',
          flatNumber: '101',
          visitorName: 'Test Visitor',
          purpose: 'Meeting',
          category: 'guest',
          status: 'approved',
          createdAt: DateTime.now(),
        );

        expect(approvedVisitor.canCheckIn, isTrue);

        final pendingVisitor = approvedVisitor.copyWith(status: 'pending');
        expect(pendingVisitor.canCheckIn, isFalse);

        final inVisitor = approvedVisitor.copyWith(status: 'in');
        expect(inVisitor.canCheckIn, isFalse);
      });

      test('canCheckOut returns true only when inside', () {
        final inVisitor = VisitorManagement(
          id: 'test_1',
          societyId: 'soc_001',
          flatNumber: '101',
          visitorName: 'Test Visitor',
          purpose: 'Meeting',
          category: 'guest',
          status: 'in',
          createdAt: DateTime.now(),
        );

        expect(inVisitor.canCheckOut, isTrue);

        final outVisitor = inVisitor.copyWith(status: 'out');
        expect(outVisitor.canCheckOut, isFalse);

        final approvedVisitor = inVisitor.copyWith(status: 'approved');
        expect(approvedVisitor.canCheckOut, isFalse);
      });

      test('copyWith preserves all fields except modified ones', () {
        final now = DateTime.now();
        final original = VisitorManagement(
          id: 'test_1',
          societyId: 'soc_001',
          blockNumber: 'A',
          flatNumber: '101',
          visitorName: 'Test Visitor',
          visitorPhone: '9876543210',
          purpose: 'Meeting',
          category: 'guest',
          status: 'pending',
          createdAt: now,
          entryTime: null,
          exitTime: null,
          metadata: {'note': 'test'},
        );

        final updated = original.copyWith(
          status: 'approved',
          visitorName: 'Updated Visitor',
        );

        // Check modified fields
        expect(updated.status, 'approved');
        expect(updated.visitorName, 'Updated Visitor');

        // Check unmodified fields
        expect(updated.id, 'test_1');
        expect(updated.societyId, 'soc_001');
        expect(updated.flatNumber, '101');
        expect(updated.visitorPhone, '9876543210');
        expect(updated.metadata, {'note': 'test'});
      });

      test('Different visitor categories are supported', () {
        final categories = [
          'vendor',
          'delivery',
          'service',
          'guest',
          'contractor'
        ];

        for (final category in categories) {
          final visitor = VisitorManagement(
            id: 'test_$category',
            societyId: 'soc_001',
            flatNumber: '101',
            visitorName: 'Test',
            purpose: 'Test',
            category: category,
            status: 'pending',
            createdAt: DateTime.now(),
          );

          expect(visitor.category, category);
        }
      });

      test('Visitor with block and flat number formats correctly', () {
        final visitor = VisitorManagement(
          id: 'test_1',
          societyId: 'soc_001',
          blockNumber: 'Tower A',
          flatNumber: '501',
          visitorName: 'Test Visitor',
          purpose: 'Meeting',
          category: 'guest',
          status: 'pending',
          createdAt: DateTime.now(),
        );

        expect(visitor.blockNumber, 'Tower A');
        expect(visitor.flatNumber, '501');
      });

      test('Multiple visitors can have the same flat but different IDs', () {
        final now = DateTime.now();

        final visitor1 = VisitorManagement(
          id: 'test_1',
          societyId: 'soc_001',
          flatNumber: '101',
          visitorName: 'Visitor 1',
          purpose: 'Meeting',
          category: 'guest',
          status: 'pending',
          createdAt: now,
        );

        final visitor2 = VisitorManagement(
          id: 'test_2',
          societyId: 'soc_001',
          flatNumber: '101',
          visitorName: 'Visitor 2',
          purpose: 'Delivery',
          category: 'vendor',
          status: 'pending',
          createdAt: now.add(const Duration(hours: 1)),
        );

        expect(visitor1.flatNumber, visitor2.flatNumber);
        expect(visitor1.id, isNot(visitor2.id));
      });
    });

    group('Visitor Status Transitions', () {
      test('Visitor transitions from pending to approved', () {
        final visitor = VisitorManagement(
          id: 'test_1',
          societyId: 'soc_001',
          flatNumber: '101',
          visitorName: 'Test Visitor',
          purpose: 'Meeting',
          category: 'guest',
          status: 'pending',
          createdAt: DateTime.now(),
        );

        final approved = visitor.copyWith(status: 'approved');
        expect(approved.status, 'approved');
        expect(approved.canCheckIn, isTrue);
      });

      test('Visitor transitions from approved to in', () {
        final now = DateTime.now();
        final visitor = VisitorManagement(
          id: 'test_1',
          societyId: 'soc_001',
          flatNumber: '101',
          visitorName: 'Test Visitor',
          purpose: 'Meeting',
          category: 'guest',
          status: 'approved',
          createdAt: now,
        );

        final checked = visitor.copyWith(
          status: 'in',
          entryTime: now.add(const Duration(minutes: 5)),
        );

        expect(checked.status, 'in');
        expect(checked.isInside, isTrue);
        expect(checked.canCheckOut, isTrue);
      });

      test('Visitor transitions from in to out', () {
        final now = DateTime.now();
        final entryTime = now;
        final exitTime = now.add(const Duration(hours: 2));

        final visitor = VisitorManagement(
          id: 'test_1',
          societyId: 'soc_001',
          flatNumber: '101',
          visitorName: 'Test Visitor',
          purpose: 'Meeting',
          category: 'guest',
          status: 'in',
          createdAt: now,
          entryTime: entryTime,
        );

        final checkedOut = visitor.copyWith(
          status: 'out',
          exitTime: exitTime,
        );

        expect(checkedOut.status, 'out');
        expect(checkedOut.isInside, isFalse);
        expect(checkedOut.visitDuration, isNotNull);
      });

      test('Visitor can be rejected from pending', () {
        final visitor = VisitorManagement(
          id: 'test_1',
          societyId: 'soc_001',
          flatNumber: '101',
          visitorName: 'Test Visitor',
          purpose: 'Meeting',
          category: 'guest',
          status: 'pending',
          createdAt: DateTime.now(),
        );

        final rejected = visitor.copyWith(status: 'rejected');
        expect(rejected.status, 'rejected');
      });
    });
  });
}
