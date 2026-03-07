-- Add Test Societies
INSERT INTO societies (id, name, config) VALUES
(
  'soc_001'::uuid,
  'Ambience Creations',
  '{"billing_cycle": "monthly", "currency": "INR", "location": "Sector 22, Gurgaon"}'
),
(
  'soc_002'::uuid,
  'Ashiana Greens',
  '{"billing_cycle": "monthly", "currency": "INR", "location": "Sector 50, Gurgaon"}'
),
(
  'soc_003'::uuid,
  'DLF Pinnacle',
  '{"billing_cycle": "monthly", "currency": "INR", "location": "Downtown, Gurgaon"}'
);

-- Add Units/Flats for Ambience Creations
INSERT INTO units (society_id, block, flat_no) VALUES
('soc_001'::uuid, 'Tower A', 'A-101'),
('soc_001'::uuid, 'Tower A', 'A-102'),
('soc_001'::uuid, 'Tower A', 'A-103'),
('soc_001'::uuid, 'Tower B', 'B-201'),
('soc_001'::uuid, 'Tower B', 'B-202'),
('soc_001'::uuid, 'Tower C', 'C-301'),
('soc_001'::uuid, 'Tower C', 'C-302');

-- Add Units/Flats for Ashiana Greens
INSERT INTO units (society_id, block, flat_no) VALUES
('soc_002'::uuid, 'Block 1', '1-101'),
('soc_002'::uuid, 'Block 1', '1-102'),
('soc_002'::uuid, 'Block 2', '2-201'),
('soc_002'::uuid, 'Block 2', '2-202'),
('soc_002'::uuid, 'Block 3', '3-301');

-- Add Units/Flats for DLF Pinnacle
INSERT INTO units (society_id, block, flat_no) VALUES
('soc_003'::uuid, 'Tower 1', '1A'),
('soc_003'::uuid, 'Tower 1', '2A'),
('soc_003'::uuid, 'Tower 2', '1B'),
('soc_003'::uuid, 'Tower 2', '2B');

-- Add test resident and guard users (password is hashed during signup)
INSERT INTO profiles (id, society_id, unit_id, role, full_name, phone_number, email) VALUES
(
  '11111111-1111-1111-1111-111111111111'::uuid,
  'soc_001'::uuid,
  (SELECT id FROM units WHERE society_id = 'soc_001'::uuid AND flat_no = 'A-101' LIMIT 1),
  'resident',
  'Raj Kumar',
  '+91 98765 43210',
  'resident@test.com'
),
(
  '22222222-2222-2222-2222-222222222222'::uuid,
  'soc_001'::uuid,
  NULL,
  'guard',
  'Suresh Patel',
  '+91 97654 32109',
  'guard@test.com'
);
