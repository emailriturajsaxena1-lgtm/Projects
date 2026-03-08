# Gately - Society Management Apps

Gately is a society management platform split into **two Android applications**:

## 1. Gately Resident (Society Resident App)
**Package:** `gately_resident`  
**Location:** `apps/gately_resident/`

### Features
- **Login** - Email/Phone authentication with OTP
- **Smart Dashboard** - Contextual greeting, quick actions
- **Community Pulse** - Notices, polls, classifieds feed
- **Footer Pages** - Home, Services, Accounts, Profile
- **Quick Actions** - Gate Pass, Pay Now, Helpdesk, SOS
- **Helpdesk** - Create and track support tickets
- **Payments** - Maintenance bills (unpaid/paid/overdue)
- **SOS** - Emergency alert for residents

### Run
```bash
cd apps/gately_resident
flutter run
```

---

## 2. Gately Visitor (Visitor Management App)
**Package:** `gately_visitor`  
**Location:** `apps/gately_visitor/`

### Features
- **Login** - Security staff (Supervisor/Guard) authentication
- **Visitor Management** - Pending, Today, Report tabs
- **Supervisor Dashboard** - Security control center
- **Guard Gate Dashboard** - QR scan, manual entry/exit, History
- **Tower Guard** - Check-in/check-out visitors, Quick Check-In

### Run
```bash
cd apps/gately_visitor
flutter run
```

---

## Project Structure

```
gately/
├── packages/
│   └── gately_core/          # Shared models & services
│       ├── lib/
│       │   ├── models/       # UserProfile, Society, VisitorManagement, etc.
│       │   ├── services/     # SupabaseService
│       │   └── gately_core.dart
│       └── pubspec.yaml
├── apps/
│   ├── gately_resident/      # Society Resident app
│   └── gately_visitor/       # Visitor Management app
└── README.md
```

## Setup

1. **Run Community Pulse migration** (optional but recommended for Resident app):
   - In Supabase SQL Editor, run the script in `packages/gately_core/supabase/migrations/002_community_pulse.sql`
   - This creates tables: `community_notices`, `community_polls`, `community_poll_options`, `community_poll_votes`, `community_classifieds`, `amenity_bookings`

2. **Configure Supabase** - Copy `.env.example` to `.env` in each app folder:
   ```
   SUPABASE_URL=your_supabase_url
   SUPABASE_ANON_KEY=your_anon_key
   ```

2. **Get dependencies:**
   ```bash
   cd packages/gately_core && flutter pub get
   cd ../../apps/gately_resident && flutter pub get
   cd ../gately_visitor && flutter pub get
   ```

3. **Build Android:**
   ```bash
   cd apps/gately_resident
   flutter build apk
   
   cd ../gately_visitor
   flutter build apk
   ```

## App Division Summary

| Feature | Gately Resident | Gately Visitor |
|---------|-----------------|----------------|
| Login | ✅ | ✅ |
| Smart Dashboard | ✅ | ❌ |
| Community Pulse | ✅ | ❌ |
| Footer (Home/Services/Accounts/Profile) | ✅ | ❌ |
| Helpdesk | ✅ | ❌ |
| Payments | ✅ | ❌ |
| SOS (Resident) | ✅ | ❌ |
| Visitor Management | ❌ | ✅ |
| Supervisor Dashboard | ❌ | ✅ |
| Guard Gate Dashboard | ❌ | ✅ |
| Tower Guard | ❌ | ✅ |
