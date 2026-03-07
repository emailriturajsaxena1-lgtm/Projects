# 🐛 MyGate Troubleshooting Guide

## ✅ Setup For Testing

### Step 1: Create Test Users in Supabase Dashboard

**For RESIDENT:**
1. Go to https://app.supabase.com → Your Project
2. **Authentication** → **Users** → **"Add user"**
3. Fill in:
   - **Email**: `resident@test.com`
   - **Password**: `password123`
4. **Uncheck** "Auto send sign up confirmation"
5. Click **Create user**

**For GUARD:**
Repeat with:
   - **Email**: `guard@test.com`
   - **Password**: `password123`

### Step 2: Create User Profiles in Database

Go to **SQL Editor** and run:

```sql
-- Create resident profile
INSERT INTO profiles (id, full_name, unit_id, role)
SELECT id, 'Test Resident', '550e8400-e29b-41d4-a716-446655440101', 'resident'
FROM auth.users WHERE email = 'resident@test.com'
ON CONFLICT (id) DO NOTHING;

-- Create guard profile
INSERT INTO profiles (id, full_name, role)
SELECT id, 'Test Guard', 'guard'
FROM auth.users WHERE email = 'guard@test.com'
ON CONFLICT (id) DO NOTHING;
```

### Step 3: Test in App

```bash
flutter clean
flutter pub get
flutter run
```

**Login with:**
- Email: `resident@test.com` | Password: `password123`
- Email: `guard@test.com` | Password: `password123`

---

## ❌ Sign-Up Error: "Email address is invalid"

### Root Cause
Supabase email confirmation is enabled but SMTP is not configured, causing validation to fail.

### ✅ Solution 1: Disable Email Confirmation (EASIEST)

**Steps:**
1. Go to **Supabase Dashboard** → https://app.supabase.com
2. Select your project
3. Navigate to **Authentication** in left sidebar
4. Click **Providers** → **Email**
5. **UNCHECK** the checkbox for **"Confirm email"**
6. Click **Save**
7. Return to app and try sign-up again

**Expected Result:** Sign-up should work immediately without email verification.

---

### ✅ Solution 2: Create Test Users in Dashboard

**Steps:**
1. Go to **Supabase Dashboard** → **Authentication** → **Users**
2. Click **"Add user"** button (top right)
3. Fill in:
   - **Email**: `resident@test.com`
   - **Password**: `password` (or any password)
4. **UNCHECK** "Auto send sign up confirmation" (important!)
5. Click **Create user**
6. Repeat for Guard: `guard@test.com` / `password`

**In App:**
- Don't use Sign-Up
- Use **Login** instead
- Enter the email and password you created

---

### ✅ Solution 3: Enable SMTP (For Production)

If you want email verification in production:

1. Go to **Supabase Dashboard** → **Settings** → **Email Templates**
2. Scroll down to **SMTP Settings**
3. Configure your email provider (sendgrid, mailgun, etc.)
4. Save and test

This requires setting up an external email service.

---

## 🔍 Verify Your Setup

Run this in Supabase SQL Editor to check database is working:

```sql
SELECT * FROM auth.users LIMIT 5;
SELECT * FROM profiles LIMIT 5;
```

If you see test data, your backend is connected correctly.

---

## 📋 Common Errors & Fixes

| Error | Cause | Fix |
|-------|-------|-----|
| `email_address_invalid` | Email confirmation enabled, no SMTP | Disable email confirmation (Solution 1) |
| `user_already_exists` | Email already registered | Use different email or delete user in dashboard |
| `weak_password` | Password < 6 characters | Use at least 6 character password |
| `Supabase connection failed` | Wrong URL/Key in .env | Check `.env` file credentials |
| `No test data showing` | Migrations not executed | Run SQL from `002_seed_test_data.sql` |

---

## ✅ Testing Checklist

- [ ] Supabase project created
- [ ] Migrations executed (001 & 002)
- [ ] `.env` file configured with URL & Key
- [ ] Email confirmation disabled OR test users created
- [ ] App runs without crash
- [ ] Can login successfully
- [ ] Dashboard shows 6 feature cards
- [ ] Can navigate to Activity, Payments, etc.

---

## 🆘 Still Getting Errors?

Check these in order:

1. **App Logs**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

2. **Supabase Dashboard**
   - Check if project is active
   - Verify API keys are correct
   - Check "SQL Editor" → test database connection

3. **Environment Variables**
   - Confirm `.env` exists in project root
   - Verify `SUPABASE_URL` and `SUPABASE_ANON_KEY` are set
   - No extra spaces or quotes

4. **Android Build**
   ```bash
   cd android
   gradlew clean
   cd ..
   flutter run
   ```

5. **Network**
   - Check internet connection
   - Firewall may block Supabase API
   - Try using VPN or different network

---

## 📞 Support Resources

- **Supabase Docs**: https://supabase.com/docs
- **Supabase Discord**: https://discord.supabase.io
- **Flutter Docs**: https://flutter.dev/docs
- **Project SETUP_GUIDE**: See SETUP_GUIDE.md

---

**Last Updated**: March 1, 2026
