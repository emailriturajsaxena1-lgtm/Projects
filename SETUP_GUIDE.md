# MyGate Society Management App - Complete Setup Guide

## 📱 App Overview

MyGate is a comprehensive society management app with role-based access for residents, guards, and management. It includes:

**Resident Features:**
- ✅ Activity Log (Visitor Management)
- ✅ Payments (Maintenance Bills)
- ✅ Daily Help (Maid, Driver, Grocery Services)
- ✅ Helpdesk (Support Tickets)
- ✅ Notice Board (Announcements)
- ✅ SOS Emergency Alert

**Guard Features:**
- ✅ QR Code Checkpoint Scanning
- ✅ Visitor Logging
- ✅ Patrol Management
- ✅ Incident Alerts
- ✅ Activity Dashboard

---

## 🚀 Quick Start

### Prerequisites
- Flutter SDK 3.0+ & Dart 3.0+
- Supabase account (https://supabase.com)
- Android Studio / Xcode (for emulator)
- VS Code with Flutter extension (recommended)

### 1. Setup Supabase Project

1. Create a new Supabase project
2. Run the migrations:
   - Go to SQL Editor in Supabase Dashboard
   - Execute `supabase/migrations/001_initial_schema.sql`
   - Execute `supabase/migrations/002_seed_test_data.sql`
3. Get your credentials:
   - Project URL → `SUPABASE_URL`
   - Anon Key → `SUPABASE_ANON_KEY`

### 2. Configure Flutter Project

1. **Create `.env` file** (copy from `.env.example`):
   ```
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_ANON_KEY=your-anon-key
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Clean & prepare:**
   ```bash
   flutter clean
   flutter pub get
   ```

### 3. Run the App

```bash
flutter run
```

Or select a specific device:
```bash
flutter devices           # List available devices
flutter run -d <device>  # Run on specific device
```

---

## 🧪 Testing the App

### Test Accounts (Create in Supabase Auth)

**Admin/Setup**: First create these users in Supabase Dashboard → Authentication → Users

Then create their profiles using the app UI or directly in the database:

#### Resident Account
- **Email**: `resident@test.com`
- **Password**: `password`
- **Create Profile**: Use app sign-up or insert directly in `profiles` table

```sql
-- Insert in profiles table after creating auth user
INSERT INTO profiles (id, full_name, unit_id, role)
VALUES (
  'user-id-from-auth',
  'John Resident',
  '550e8400-e29b-41d4-a716-446655440101',
  'resident'
);
```

#### Guard Account
- **Email**: `guard@test.com`
- **Password**: `password`
- **Create Profile**: 

```sql
INSERT INTO profiles (id, full_name, role)
VALUES (
  'guard-user-id-from-auth',
  'Ram Guard',
  'guard'
);
```

---

## 🧑‍💻 Testing Workflows

### 1. Test Resident Login & Dashboard
1. Launch app
2. Tap "Sign Up" on login screen
3. Sign up with new email
4. Log in with credentials
5. Verify all 6 feature cards appear

### 2. Test Activity (Visitor Logs)
1. From dashboard, tap **Activity**
2. **Add Visitor:**
   - Name: "Amazon Delivery"
   - Purpose: "Delivery"
   - Tap "Log Visitor"
3. **Verify**: New visitor appears in "Recent Activity" list

### 3. Test Payments
1. From dashboard, tap **Payments**
2. **Verify:**
   - Total unpaid amount & overdue amount display
   - Bills grouped by status (Overdue, Pending, Paid)
   - Test bill: ₹5000 unpaid bill due tomorrow
   - Tap "PAY" button → shows "Payment feature coming soon"

### 4. Test Helpdesk
1. From dashboard, tap **Helpdesk**
2. **Create Ticket:**
   - Category: "Plumbing"
   - Description: "Bathroom pipe leaking"
   - Tap "Create Ticket"
3. **Verify:**
   - New ticket appears with "OPEN" status
   - Shows date created

### 5. Test Daily Help
1. From dashboard, tap **Daily Help**
2. **Book Service:**
   - Tap "Maid Request" card
   - Fill date, time, instructions
   - Tap "Book Now" → confirmation message

### 6. Test SOS Alert
1. From dashboard, tap **SOS**
2. **Hold** the red emergency button for 1+ second
3. **Verify:**
   - Alert message: "SOS Alert sent! Security & Management notified"
   - Button activates (changes color)
   - Emergency contacts display

### 7. Test Guard Dashboard
1. Log out (tap menu → Logout)
2. Sign in with guard account
3. **Verify:**
   - "Guard Dashboard" loads
   - "ON DUTY" status badge
   - 4 quick action cards (QR Checkpoint, Log Visitor, Patrols, Alerts)
   - Recent activity log displays

---

## 📊 Database Test Data

Test data is automatically seeded by `002_seed_test_data.sql`:

### Test Visitor Logs (4 entries)
- Amazon Delivery - Approved (2 days ago)
- Flipkart Delivery - Approved (1 day ago)
- Plumber - Approved (3 days ago)
- Guest Rajesh - Approved (5 hours ago)

### Test Maintenance Bills (4 entries)
- ₹5,000 unpaid (due in 5 days)
- ₹5,000 overdue (due 10 days ago) ⚠️
- ₹5,000 paid (paid 5 days ago) ✓
- ₹5,000 unpaid (due in 10 days)

### Test Guard Checkpoints (3 entries)
- Main Gate QR-001
- Back Gate QR-002
- Parking Area QR-003

---

## 🔧 Troubleshooting

### Issue: "Unresolved reference: Registrar" (Android Build)
**Solution**: Already fixed. AGP updated to 8.3.0 & supabase_flutter to 2.12.0

### Issue: "Connection test failed"
1. Check `.env` file has correct URL & key
2. Test connection: Flutter will show "✅ Supabase connection successful" on startup
3. Verify Supabase project is active

### Issue: Auth fails after sign up
1. Check Supabase Auth settings → Email templates
2. Verify email configuration in Supabase
3. Use Supabase dashboard to manually create test users

### Issue: No test data showing
1. Run migrations in Supabase SQL Editor
2. Query `SELECT * FROM visitor_logs;` to verify data exists
3. Check `unit_id` matches in your test profile

---

## 📚 Key App Features

### Architecture
- **State Management**: Riverpod (providers)
- **Backend**: Supabase (Postgres + Auth)
- **Real-time**: Supabase Realtime subscriptions
- **UI**: Material Design 3 with Orange accent

### Core Services
- **SupabaseService**: Handles all API calls
- **UserProfile Model**: User data management
- **Role-based Routing**: AuthGate determines UI

### Database Schema
```
├── societies
├── units
├── profiles
├── visitor_logs
├── maintenance_bills
├── helpdesk_tickets
├── guard_checkpoints
└── sos_event_logs
```

---

## 📝 Next Steps for Production

1. **Authentication**
   - [ ] Add phone OTP login
   - [ ] Add Apple Sign-In (already added: sign_in_with_apple 6.1.0)
   - [ ] Add Google Sign-In

2. **Features**
   - [ ] Implement Payment Gateway (Razorpay/PayU)
   - [ ] Add Notifications (FCM)
   - [ ] Implement Real-time Chat
   - [ ] Add Document Upload

3. **Security**
   - [ ] Implement Row-Level Security (RLS)
   - [ ] Add Rate Limiting
   - [ ] Validate all inputs

4. **Testing**
   - [ ] Unit tests
   - [ ] Integration tests
   - [ ] UI tests

---

## 📞 Support

For issues or questions:
1. Check Supabase documentation: https://supabase.com/docs
2. Check Flutter documentation: https://flutter.dev
3. Review database logs in Supabase dashboard

---

**Happy Building! 🚀**
