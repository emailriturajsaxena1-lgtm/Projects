-- TEST DATA INSERTION SCRIPT
-- Run this after the initial schema is created

-- 1. INSERT TEST SOCIETY
INSERT INTO societies (id, name, config)
VALUES (
  '550e8400-e29b-41d4-a716-446655440001',
  'Green Heights Society',
  '{"billing_cycle": "monthly", "currency": "INR"}'
)
ON CONFLICT DO NOTHING;

-- 2. INSERT TEST UNITS
INSERT INTO units (id, society_id, block, flat_no)
VALUES
  ('550e8400-e29b-41d4-a716-446655440101', '550e8400-e29b-41d4-a716-446655440001', 'A', '101'),
  ('550e8400-e29b-41d4-a716-446655440102', '550e8400-e29b-41d4-a716-446655440001', 'A', '102'),
  ('550e8400-e29b-41d4-a716-446655440103', '550e8400-e29b-41d4-a716-446655440001', 'B', '201')
ON CONFLICT DO NOTHING;

-- 3. INSERT TEST VISITOR LOGS (sample data showing visitor activity)
INSERT INTO visitor_logs (id, unit_id, visitor_name, purpose, status, entry_at, exit_at)
VALUES
  (
    '550e8400-e29b-41d4-a716-446655440201',
    '550e8400-e29b-41d4-a716-446655440101',
    'Amazon Delivery',
    'Delivery',
    'approved',
    NOW() - INTERVAL '2 days',
    NOW() - INTERVAL '2 days' + INTERVAL '10 minutes'
  ),
  (
    '550e8400-e29b-41d4-a716-446655440202',
    '550e8400-e29b-41d4-a716-446655440101',
    'Flipkart Delivery',
    'Delivery',
    'approved',
    NOW() - INTERVAL '1 day',
    NOW() - INTERVAL '1 day' + INTERVAL '5 minutes'
  ),
  (
    '550e8400-e29b-41d4-a716-446655440203',
    '550e8400-e29b-41d4-a716-446655440102',
    'Plumber John',
    'Service',
    'approved',
    NOW() - INTERVAL '3 days',
    NOW() - INTERVAL '3 days' + INTERVAL '1 hour'
  ),
  (
    '550e8400-e29b-41d4-a716-446655440204',
    '550e8400-e29b-41d4-a716-446655440103',
    'Guest - Rajesh',
    'Guest',
    'approved',
    NOW() - INTERVAL '5 hours',
    NULL
  )
ON CONFLICT DO NOTHING;

-- 4. INSERT TEST MAINTENANCE BILLS
INSERT INTO maintenance_bills (id, unit_id, amount, due_date, status)
VALUES
  (
    '550e8400-e29b-41d4-a716-446655440301',
    '550e8400-e29b-41d4-a716-446655440101',
    5000.00,
    NOW()::date + INTERVAL '5 days',
    'unpaid'
  ),
  (
    '550e8400-e29b-41d4-a716-446655440302',
    '550e8400-e29b-41d4-a716-446655440101',
    5000.00,
    (NOW() - INTERVAL '10 days')::date,
    'overdue'
  ),
  (
    '550e8400-e29b-41d4-a716-446655440303',
    '550e8400-e29b-41d4-a716-446655440102',
    5000.00,
    (NOW() - INTERVAL '5 days')::date,
    'paid'
  ),
  (
    '550e8400-e29b-41d4-a716-446655440304',
    '550e8400-e29b-41d4-a716-446655440103',
    5000.00,
    NOW()::date + INTERVAL '10 days',
    'unpaid'
  )
ON CONFLICT DO NOTHING;

-- 5. INSERT TEST GUARD CHECKPOINTS
INSERT INTO guard_checkpoints (id, society_id, checkpoint_name, qr_code_data)
VALUES
  (
    '550e8400-e29b-41d4-a716-446655440401',
    '550e8400-e29b-41d4-a716-446655440001',
    'Main Gate',
    'CHECKPOINT_A_MAIN_GATE_001'
  ),
  (
    '550e8400-e29b-41d4-a716-446655440402',
    '550e8400-e29b-41d4-a716-446655440001',
    'Back Gate',
    'CHECKPOINT_B_BACK_GATE_001'
  ),
  (
    '550e8400-e29b-41d4-a716-446655440403',
    '550e8400-e29b-41d4-a716-446655440001',
    'Parking Area',
    'CHECKPOINT_C_PARKING_001'
  )
ON CONFLICT DO NOTHING;

-- NOTE: To insert auth users, you'll need to use the Supabase Auth API
-- This SQL script handles database records only
-- Use the Flutter app UI to create new users, or use Supabase dashboard to create auth users

-- Example comment:
-- For testing, create users like:
-- Email: resident@test.com / Password: password
-- Email: guard@test.com / Password: password
-- Then manually create their profiles in the admin dashboard
