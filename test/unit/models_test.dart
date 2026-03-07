import 'package:flutter_test/flutter_test.dart';
import 'package:mygate_clone/core/models/society.dart';
import 'package:mygate_clone/core/models/visitor_management.dart';

void main() {
  group('Models - Unit Tests', () {
    // ==================== SOCIETY TESTS ====================
    group('Society Model', () {
      test('Society.fromJson creates instance correctly', () {
        final json = {
          'id': 'soc_001',
          'name': 'Spring Valley',
          'config': {'towers': 3}
        };

        final society = Society.fromJson(json);

        expect(society.id, 'soc_001');
        expect(society.name, 'Spring Valley');
        expect(society.config, {'towers': 3});
      });

      test('Society.toJson converts instance correctly', () {
        final society = Society(
          id: 'soc_001',
          name: 'Spring Valley',
          config: {'towers': 3},
        );

        final json = society.toJson();

        expect(json['id'], 'soc_001');
        expect(json['name'], 'Spring Valley');
        expect(json['config'], {'towers': 3});
      });

      test('Society with null config', () {
        final society = Society(
          id: 'soc_001',
          name: 'Spring Valley',
          config: null,
        );

        final json = society.toJson();
        expect(json['config'], isNull);
      });
    });

    // ==================== UNIT TESTS ====================
    group('Unit Model', () {
      test('Unit.fromJson creates instance correctly', () {
        final json = {
          'id': 'unit_001',
          'society_id': 'soc_001',
          'block': 'A',
          'flat_no': '101',
        };

        final unit = Unit.fromJson(json);

        expect(unit.id, 'unit_001');
        expect(unit.societyId, 'soc_001');
        expect(unit.block, 'A');
        expect(unit.flatNo, '101');
      });

      test('Unit.toJson converts instance correctly', () {
        final unit = Unit(
          id: 'unit_001',
          societyId: 'soc_001',
          block: 'A',
          flatNo: '101',
        );

        final json = unit.toJson();

        expect(json['id'], 'unit_001');
        expect(json['society_id'], 'soc_001');
        expect(json['block'], 'A');
        expect(json['flat_no'], '101');
      });

      test('Unit.toString returns block-flatNo format when block exists', () {
        final unit = Unit(
          id: 'unit_001',
          societyId: 'soc_001',
          block: 'A',
          flatNo: '101',
        );

        expect(unit.toString(), 'A-101');
      });

      test('Unit.toString returns only flatNo when block is null', () {
        final unit = Unit(
          id: 'unit_001',
          societyId: 'soc_001',
          block: null,
          flatNo: '101',
        );

        expect(unit.toString(), '101');
      });

      test('Unit with no block', () {
        final json = {
          'id': 'unit_002',
          'society_id': 'soc_001',
          'block': null,
          'flat_no': '202',
        };

        final unit = Unit.fromJson(json);
        expect(unit.block, isNull);
        expect(unit.toString(), '202');
      });
    });

    // ==================== VISITOR MANAGEMENT TESTS ====================
    group('VisitorManagement Model', () {
      test('VisitorManagement.fromJson creates instance correctly', () {
        final now = DateTime.now();
        final json = {
          'id': 'visitor_001',
          'society_id': 'soc_001',
          'block_number': 'A',
          'flat_number': '101',
          'visitor_name': 'John Doe',
          'visitor_phone': '9876543210',
          'purpose': 'Delivery',
          'category': 'vendor',
          'status': 'approved',
          'created_at': now.toIso8601String(),
          'entry_time': null,
          'exit_time': null,
          'metadata': {'vehicle': 'Two Wheeler'},
        };

        final visitor = VisitorManagement.fromJson(json);

        expect(visitor.id, 'visitor_001');
        expect(visitor.societyId, 'soc_001');
        expect(visitor.visitorName, 'John Doe');
        expect(visitor.category, 'vendor');
        expect(visitor.status, 'approved');
      });

      test('VisitorManagement.toJson converts correctly', () {
        final now = DateTime.now();
        final visitor = VisitorManagement(
          id: 'visitor_001',
          societyId: 'soc_001',
          blockNumber: 'A',
          flatNumber: '101',
          visitorName: 'John Doe',
          visitorPhone: '9876543210',
          purpose: 'Delivery',
          category: 'vendor',
          status: 'approved',
          createdAt: now,
        );

        final json = visitor.toJson();

        expect(json['id'], 'visitor_001');
        expect(json['visitor_name'], 'John Doe');
        expect(json['category'], 'vendor');
      });

      test('VisitorManagement status display', () {
        final visitor = VisitorManagement(
          id: 'visitor_001',
          societyId: 'soc_001',
          flatNumber: '101',
          visitorName: 'John',
          purpose: 'Visit',
          category: 'guest',
          status: 'pending',
          createdAt: DateTime.now(),
        );

        expect(visitor.statusDisplay, 'Awaiting Approval');

        final approvedVisitor = visitor.copyWith(status: 'approved');
        expect(approvedVisitor.statusDisplay, 'Approved');

        final inVisitor = visitor.copyWith(status: 'in');
        expect(inVisitor.statusDisplay, 'Currently Inside');
      });

      test('VisitorManagement visit duration calculation', () {
        final now = DateTime.now();
        final entryTime = now.subtract(const Duration(hours: 2, minutes: 30));
        final exitTime = now;

        final visitor = VisitorManagement(
          id: 'visitor_001',
          societyId: 'soc_001',
          flatNumber: '101',
          visitorName: 'John',
          purpose: 'Visit',
          category: 'guest',
          status: 'out',
          createdAt: now,
          entryTime: entryTime,
          exitTime: exitTime,
        );

        final duration = visitor.visitDuration;
        expect(duration, isNotNull);
        expect(duration!.inHours, 2);
      });

      test('VisitorManagement isInside property', () {
        final visitor = VisitorManagement(
          id: 'visitor_001',
          societyId: 'soc_001',
          flatNumber: '101',
          visitorName: 'John',
          purpose: 'Visit',
          category: 'guest',
          status: 'in',
          createdAt: DateTime.now(),
        );

        expect(visitor.isInside, isTrue);

        final outsideVisitor = visitor.copyWith(status: 'out');
        expect(outsideVisitor.isInside, isFalse);
      });

      test('VisitorManagement copyWith creates new instance', () {
        final original = VisitorManagement(
          id: 'visitor_001',
          societyId: 'soc_001',
          flatNumber: '101',
          visitorName: 'John',
          purpose: 'Visit',
          category: 'guest',
          status: 'pending',
          createdAt: DateTime.now(),
        );

        final updated = original.copyWith(
          status: 'approved',
          visitorName: 'Jane',
        );

        expect(updated.id, 'visitor_001');
        expect(updated.status, 'approved');
        expect(updated.visitorName, 'Jane');
        expect(updated.category, 'guest'); // Unchanged
      });

      test('VisitorManagement different categories', () {
        final categories = ['vendor', 'delivery', 'service', 'guest'];

        for (final category in categories) {
          final visitor = VisitorManagement(
            id: 'visitor_$category',
            societyId: 'soc_001',
            flatNumber: '101',
            visitorName: 'Test Person',
            purpose: 'Test',
            category: category,
            status: 'approved',
            createdAt: DateTime.now(),
          );

          expect(visitor.category, category);
        }
      });

      test('VisitorManagement with null optional fields', () {
        final visitor = VisitorManagement(
          id: 'visitor_001',
          societyId: 'soc_001',
          flatNumber: '101',
          visitorName: 'John',
          purpose: 'Visit',
          category: 'guest',
          status: 'pending',
          createdAt: DateTime.now(),
          blockNumber: null,
          visitorPhone: null,
          entryTime: null,
          exitTime: null,
          metadata: null,
        );

        expect(visitor.blockNumber, isNull);
        expect(visitor.visitorPhone, isNull);
        expect(visitor.visitDuration, isNull);
      });
    });
  });
}
