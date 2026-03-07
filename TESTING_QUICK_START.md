# ✅ MyGate Testing Guide - QUICK START

## 🚀 **1. Run the App**

```bash
cd c:\Projects\mygate_clone
flutter clean
flutter pub get
flutter run
```

---

## 📝 **2. Create Test Users in Supabase (2 min setup)**

Go to **https://app.supabase.com** → Your Project

### **Create RESIDENT User:**
1. Click **Authentication** (left sidebar)
2. Click **Users** tab
3. Click **"Add user"** (top right)
4. Fill:
   - Email: `resident@test.com`
   - Password: `password123`
   - **Uncheck** "Auto send sign up confirmation"
5. Click **Create user**

### **Create GUARD User:**
Repeat above with:
   - Email: `guard@test.com`
   - Password: `password123`

### **Create User Profiles (Required!):**

Go to **SQL Editor** and paste this:

```sql
INSERT INTO profiles (id, full_name, unit_id, role)
SELECT id, 'Test Resident', '550e8400-e29b-41d4-a716-446655440101', 'resident'
FROM auth.users WHERE email = 'resident@test.com'
ON CONFLICT (id) DO NOTHING;

INSERT INTO profiles (id, full_name, role)
SELECT id, 'Test Guard', 'guard'
FROM auth.users WHERE email = 'guard@test.com'
ON CONFLICT (id) DO NOTHING;
```

Click **Run** ✅

---

## 🧪 **3. Test Login Flow**

**In App:**
1. Click **Login** (not Sign Up)
2. Enter: `resident@test.com` / `password123`
3. **Expected:** Dashboard loads with 6 feature cards ✅
4. Log out (menu → Logout)
5. Enter: `guard@test.com` / `password123`
6. **Expected:** Guard Dashboard loads with 4 action cards ✅

---

## 🆕 **4. Test Sign-Up Flow (Optional)**

1. Click **"Don't have an account? Sign up"**
2. Enter:
   - Name: `John User`
   - Email: `john@test.com`
   - Password: `password123`
3. Click **Sign Up**
4. **Expected:** Success message → Returns to Login
5. Now **Login** with `john@test.com` / `password123`
6. Should see Resident Dashboard ✅

---

## 🧭 **5. Test Feature Navigation**

Once logged in as resident:

| Feature | Test | Expected |
|---------|------|----------|
| **Activity** | Add visitor "Amazon" | Shows in recent activity ✓ |
| **Payments** | View bills | Shows unpaid/overdue bills ✓ |
| **Helpdesk** | Create ticket | Shows in tickets list ✓ |
| **Daily Help** | Book maid | Shows booking dialog ✓ |
| **Notice Board** | View notices | Shows 3 sample notices ✓ |
| **SOS** | Hold red button | Shows alert message ✓ |

---

## ✅ **Checklist**

- [ ] Resident login works → Dashboard shows
- [ ] Guard login works → Guard dashboard shows
- [ ] Can navigate to all 6 features
- [ ] Can create visitor/ticket
- [ ] New signup creates account
- [ ] Logout works

---

## ⚠️ **Common Issues**

| Issue | Fix |
|-------|-----|
| "Login successful" but page doesn't load | Wait 2 sec, profile may be loading |
| Login fails "Invalid credentials" | Check email/password in Supabase |
| "Error loading profile" after login | Need to create profile in SQL (step 2) |
| Signup fails "email invalid" | Try `testuser123@gmail.com` format |

---

## 📞 **Need Help?**

See detailed troubleshooting in **TROUBLESHOOTING.md**

---

**Happy Testing! 🎉**
