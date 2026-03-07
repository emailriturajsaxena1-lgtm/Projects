# 🔐 Supabase Setup - Visual Guide

## Step 1️⃣: Go to Supabase Dashboard

**URL:** https://app.supabase.com

Select your MyGate project

---

## Step 2️⃣: Disable Email Confirmation (EASIEST METHOD)

### **Option A - No Email Verification (For Testing)**

1. Click **Authentication** (left sidebar)
2. Click **Providers** tab
3. Find **Email** provider
4. **SCROLL DOWN** and uncheck: 
   ```
   ☐ Confirm email
   ```
5. Click **Save**

**Result:** Users can signup/login immediately without email verification ✅

---

### **Option B - Create Users Manually (If A doesn't work)**

1. Click **Authentication** → **Users**
2. Click **"Add user"** (top right)
3. Fill:
   ```
   Email:     resident@test.com
   Password:  password123
   ☐ Auto send sign up confirmation  [UNCHECK THIS]
   ```
4. Click **Create user**
5. Repeat for:
   ```
   Email:     guard@test.com
   Password:  password123
   ```

**Result:** 2 users created in Supabase ✅

---

## Step 3️⃣: Create User Profiles (REQUIRED!)

1. Go to **SQL Editor** (left sidebar)
2. Click **New Query**
3. Copy & paste this SQL:

```sql
-- Create profiles for test users
INSERT INTO profiles (id, full_name, unit_id, role)
SELECT id, 'Test Resident', '550e8400-e29b-41d4-a716-446655440101', 'resident'
FROM auth.users 
WHERE email = 'resident@test.com'
ON CONFLICT (id) DO NOTHING;

INSERT INTO profiles (id, full_name, role)
SELECT id, 'Test Guard', 'guard'
FROM auth.users 
WHERE email = 'guard@test.com'
ON CONFLICT (id) DO NOTHING;
```

4. Click **Run** (top right, Ctrl+Enter)

**Expected Output:**
```
Query Complete! (0.5s)
```

**Result:** User profiles created in database ✅

---

## Step 4️⃣: Verify Setup

### **Check Users Created:**
1. Go **Authentication** → **Users**
2. Should see:
   - ✅ resident@test.com
   - ✅ guard@test.com

### **Check Profiles Created:**
1. Go **SQL Editor**
2. Run:
   ```sql
   SELECT id, full_name, role FROM profiles;
   ```
3. Should see both users with their roles

**Result:** All set! ✅

---

## Step 5️⃣: Test in Flutter App

```bash
flutter run
```

### **Test Login:**
1. Input: `resident@test.com` / `password123`
2. ✅ Should see Resident Dashboard
3. Logout
4. Input: `guard@test.com` / `password123`
5. ✅ Should see Guard Dashboard

---

## 📊 **Setup Status Checklist**

- [ ] Email confirmation disabled in Supabase (or users created)
- [ ] resident@test.com user created
- [ ] guard@test.com user created
- [ ] Profiles created via SQL
- [ ] App can login as resident
- [ ] App can login as guard

---

## 🆘 **Common Issues**

| Problem | Solution |
|---------|----------|
| "User not found" error | Create user in Step 2 above |
| Login works but profile doesn't load | Run SQL from Step 3 |
| Still getting email confirmation errors | Make sure email confirmation is disabled (Step 2, Option A) |
| Signup says "Email invalid" | Try creating users manually (Option B) then just login |

---

## ✅ **Expected App Behavior**

### **After Login (Resident):**
```
Home Screen
├─ Welcome message with name
├─ 6 Feature Cards:
│  ├─ Activity (Visitor logs)
│  ├─ Payments (Bills)
│  ├─ Daily Help
│  ├─ Helpdesk (Tickets)
│  ├─ Notice Board
│  └─ SOS (Emergency)
└─ Menu (Settings, Logout)
```

### **After Login (Guard):**
```
Guard Dashboard
├─ ON DUTY status badge
├─ 4 Action Cards:
│  ├─ QR Checkpoint
│  ├─ Log Visitor
│  ├─ Patrols
│  └─ Alerts
└─ Recent activity log
```

---

**All Set! 🎉 Click "Run" in your terminal to test the app.**
