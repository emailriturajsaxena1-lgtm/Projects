-- Community Pulse: Notices, Polls, Classifieds
-- Run this in Supabase SQL Editor if not using migrations

-- NOTICES
CREATE TABLE IF NOT EXISTS community_notices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    society_id UUID NOT NULL REFERENCES societies(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    priority TEXT DEFAULT 'normal', -- normal, urgent, info
    created_by UUID REFERENCES profiles(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    expires_at TIMESTAMPTZ
);

-- POLLS
CREATE TABLE IF NOT EXISTS community_polls (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    society_id UUID NOT NULL REFERENCES societies(id) ON DELETE CASCADE,
    question TEXT NOT NULL,
    created_by UUID REFERENCES profiles(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    ends_at TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS community_poll_options (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    poll_id UUID NOT NULL REFERENCES community_polls(id) ON DELETE CASCADE,
    option_text TEXT NOT NULL,
    vote_count INT DEFAULT 0
);

CREATE TABLE IF NOT EXISTS community_poll_votes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    poll_id UUID NOT NULL REFERENCES community_polls(id) ON DELETE CASCADE,
    option_id UUID NOT NULL REFERENCES community_poll_options(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(poll_id, user_id)
);

-- CLASSIFIEDS
CREATE TABLE IF NOT EXISTS community_classifieds (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    society_id UUID NOT NULL REFERENCES societies(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    category TEXT NOT NULL, -- sell, buy, rent, services, other
    contact_phone TEXT,
    contact_name TEXT,
    created_by UUID REFERENCES profiles(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    status TEXT DEFAULT 'active' -- active, closed
);

-- AMENITY BOOKINGS (for Services tab)
CREATE TABLE IF NOT EXISTS amenity_bookings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    society_id UUID NOT NULL REFERENCES societies(id) ON DELETE CASCADE,
    amenity_name TEXT NOT NULL, -- gym, clubhouse, court, pool
    resident_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    slot_date DATE NOT NULL,
    slot_start TIME NOT NULL,
    slot_end TIME NOT NULL,
    status TEXT DEFAULT 'confirmed', -- requested, confirmed, cancelled
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS
ALTER TABLE community_notices ENABLE ROW LEVEL SECURITY;
ALTER TABLE community_polls ENABLE ROW LEVEL SECURITY;
ALTER TABLE community_poll_options ENABLE ROW LEVEL SECURITY;
ALTER TABLE community_poll_votes ENABLE ROW LEVEL SECURITY;
ALTER TABLE community_classifieds ENABLE ROW LEVEL SECURITY;
ALTER TABLE amenity_bookings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Society members can read notices" ON community_notices
  FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Society members can read polls and options" ON community_polls
  FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Society members can read poll options" ON community_poll_options
  FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Users can vote on polls" ON community_poll_votes
  FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can read poll votes" ON community_poll_votes
  FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Society members can read classifieds" ON community_classifieds
  FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Residents can insert classifieds" ON community_classifieds
  FOR INSERT WITH CHECK (auth.uid() = created_by);

CREATE POLICY "Residents can manage own amenity bookings" ON amenity_bookings
  FOR ALL USING (auth.uid() = resident_id);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_notices_society ON community_notices(society_id);
CREATE INDEX IF NOT EXISTS idx_notices_created ON community_notices(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_polls_society ON community_polls(society_id);
CREATE INDEX IF NOT EXISTS idx_classifieds_society ON community_classifieds(society_id);
CREATE INDEX IF NOT EXISTS idx_amenity_bookings_resident ON amenity_bookings(resident_id);
