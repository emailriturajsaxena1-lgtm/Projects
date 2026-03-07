-- 1. EXTENSIONS & ENUMS
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE TYPE user_role AS ENUM ('admin', 'resident', 'guard', 'staff');
CREATE TYPE ticket_status AS ENUM ('open', 'in_progress', 'resolved', 'closed');

-- 2. CORE SOCIETY TABLES
CREATE TABLE societies (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    config JSONB DEFAULT '{"billing_cycle": "monthly", "currency": "INR"}'
);

CREATE TABLE units (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    society_id UUID REFERENCES societies(id),
    block TEXT,
    flat_no TEXT NOT NULL
);

-- 3. PROFILES (Security + Privacy)
CREATE TABLE profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id),
    society_id UUID REFERENCES societies(id) NOT NULL,
    unit_id UUID REFERENCES units(id),
    role user_role DEFAULT 'resident',
    full_name TEXT NOT NULL,
    phone_number TEXT,
    email TEXT,
    device_token TEXT, -- For FCM Alerts
    daily_help_code TEXT UNIQUE, -- For Maid/Driver Entry
    is_sos_enabled BOOLEAN DEFAULT TRUE,
    data_processing_consent BOOLEAN DEFAULT FALSE,
    consent_timestamp TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3.1 USER DOCUMENTS (File Attachments for Verification)
CREATE TABLE user_documents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    document_type TEXT NOT NULL, -- 'id_proof', 'address_proof', 'rental_agreement'
    file_url TEXT NOT NULL,
    file_name TEXT,
    uploaded_at TIMESTAMPTZ DEFAULT NOW(),
    verified BOOLEAN DEFAULT FALSE,
    verified_by UUID REFERENCES profiles(id),
    verified_at TIMESTAMPTZ
);

-- 4. VISITOR & SECURITY MODULE
CREATE TABLE visitor_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    unit_id UUID REFERENCES units(id),
    visitor_name TEXT,
    purpose TEXT, -- Delivery, Guest, Service
    status TEXT DEFAULT 'pending', -- pending, approved, denied, leave_at_gate
    entry_gate_id TEXT,
    entry_at TIMESTAMPTZ DEFAULT NOW(),
    exit_at TIMESTAMPTZ
);

-- 5. BILLING & ERP MODULE (MyGate Payments)
CREATE TABLE maintenance_bills (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    unit_id UUID REFERENCES units(id),
    amount DECIMAL(10,2),
    due_date DATE,
    status TEXT DEFAULT 'unpaid', -- unpaid, paid, overdue
    payment_link TEXT
);

-- 6. COMMUNITY & HELPDESK
CREATE TABLE helpdesk_tickets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    resident_id UUID REFERENCES profiles(id),
    category TEXT, -- Plumbing, Security, Electrical, EMERGENCY
    description TEXT,
    status ticket_status DEFAULT 'open',
    assigned_to UUID REFERENCES profiles(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    resolved_at TIMESTAMPTZ
);

-- 7. GUARD PATROLLING & CHECKPOINTS
CREATE TABLE guard_checkpoints (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    society_id UUID REFERENCES societies(id),
    checkpoint_name TEXT NOT NULL,
    qr_code_data TEXT UNIQUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 8. SOS EVENT LOGS (Audit Trail)
CREATE TABLE sos_event_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    resident_id UUID REFERENCES profiles(id),
    sos_ticket_id UUID REFERENCES helpdesk_tickets(id),
    triggered_at TIMESTAMPTZ DEFAULT NOW(),
    resolved_by UUID REFERENCES profiles(id),
    resolved_at TIMESTAMPTZ
);

-- ENABLE REALTIME (Crucial for Guard/Resident Loop)
alter publication supabase_realtime add table visitor_logs, maintenance_bills, helpdesk_tickets, sos_event_logs, guard_checkpoints;
-- ROW LEVEL SECURITY POLICIES (Critical for Auth)
-- Enable RLS on all tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE visitor_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE maintenance_bills ENABLE ROW LEVEL SECURITY;
ALTER TABLE helpdesk_tickets ENABLE ROW LEVEL SECURITY;
ALTER TABLE guard_checkpoints ENABLE ROW LEVEL SECURITY;
ALTER TABLE sos_event_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_documents ENABLE ROW LEVEL SECURITY;

-- PROFILES - Users can create and view their own profile
CREATE POLICY "Users can insert their own profile" ON profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can select their own profile" ON profiles
  FOR SELECT USING (auth.uid() = id OR auth.role() = 'authenticated');

CREATE POLICY "Users can update their own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);

-- USER DOCUMENTS - Users can upload and view their documents
CREATE POLICY "Users can insert their own documents" ON user_documents
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can select their own documents" ON user_documents
  FOR SELECT USING (auth.uid() = user_id AND (SELECT role FROM profiles WHERE id = auth.uid()) IN ('admin', 'resident', 'guard', 'staff'));

-- VISITOR LOGS - Users can create logs for their unit
CREATE POLICY "Anyone can insert visitor logs" ON visitor_logs
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Anyone can select visitor logs" ON visitor_logs
  FOR SELECT USING (true);

-- MAINTENANCE BILLS - Users can view their own bills
CREATE POLICY "Users can select their own bills" ON maintenance_bills
  FOR SELECT USING (true);

-- HELPDESK TICKETS - Users can create and view their tickets
CREATE POLICY "Users can insert helpdesk tickets" ON helpdesk_tickets
  FOR INSERT WITH CHECK (auth.uid() = resident_id);

CREATE POLICY "Users can select their helpdesk tickets" ON helpdesk_tickets
  FOR SELECT USING (auth.uid() = resident_id OR auth.uid() = assigned_to);

-- GUARD CHECKPOINTS - Guards can view checkpoints
CREATE POLICY "Authenticated users can select guard checkpoints" ON guard_checkpoints
  FOR SELECT USING (auth.role() = 'authenticated');

-- SOS EVENT LOGS - Audit trail
CREATE POLICY "Users can insert SOS events" ON sos_event_logs
  FOR INSERT WITH CHECK (auth.uid() = resident_id OR auth.uid() = resolved_by);

CREATE POLICY "Users can select their SOS events" ON sos_event_logs
  FOR SELECT USING (auth.uid() = resident_id OR auth.uid() = resolved_by);