# Multi-Society Authentication Setup Guide

## 🎯 Overview
The MyGate app now supports:
- ✅ Multi-Society support with dropdown selection
- ✅ Dual login methods (Email & Phone)
- ✅ Flat/Unit selection during registration
- ✅ Document uploads for verification (ID Proof, Address Proof)
- ✅ Modern, clean UI design matching the MyGate brand

## 📋 Prerequisites

### 1. Database Migrations
Apply the migrations to your Supabase database:

```bash
# Run in Supabase SQL Editor or via CLI
supabase db push
```

Required migrations:
1. `001_initial_schema.sql` - Core tables structure with RLS policies
2. `002_seed_test_data.sql` - Test helpdesk data
3. `003_seed_societies_and_testing.sql` - Test societies and units

### 2. Storage Setup (Document Upload)
Create a storage bucket for document uploads:

**Via Supabase Dashboard:**
1. Go to **Storage** → **New Bucket**
2. Bucket name: `documents`
3. Make it **Private**
4. Enable **File size limit**: 50 MB

**Add RLS Policy to storage.objects:**
```sql
CREATE POLICY "Users can upload documents" ON storage.objects
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Users can read their documents" ON storage.objects
  FOR SELECT USING (auth.role() = 'authenticated');
```

### 3. Flutter Dependencies
All packages are already added in `pubspec.yaml`:
```yaml
file_picker: ^6.1.0         # File selection
image_picker: ^1.0.0        # Image capture/selection
```

Install them:
```bash
flutter pub get
```

## 🔐 Authentication Flow

### Email Registration
```
1. User enters name, email, password, phone
2. Selects society from dropdown
3. Selects flat/unit for that society
4. Optionally uploads ID proof & address proof
5. Account created with society & flat mapping
6. User automatically receives login prompt
```

### Phone Registration (Coming Soon)
```
1. User enters phone number
2. OTP sent via SMS
3. User verifies OTP
4. Proceeds with society & flat selection
5. Account created
```

### Email Login
```
1. User enters email & password
2. System authenticates via Supabase Auth
3. Fetches user profile (auto-creates if missing)
4. Redirects to appropriate dashboard
```

### Phone Login (Coming Soon)
```
1. User enters phone number
2. OTP sent
3. User verifies OTP
4. Redirects to dashboard
```

## 🏛️ Multi-Society Support

### How It Works
Each user belongs to exactly ONE society but the system supports multiple societies:

**Database Structure:**
```
societies
├── id (UUID)
├── name
└── config (JSON)

units
├── id (UUID)
├── society_id (FK) ← links to societies
├── block
└── flat_no

profiles
├── id (UUID)
├── society_id (FK) ← which society user belongs to
├── unit_id (FK) ← which flat in that society
├── full_name
├── phone_number
└── role (resident/guard/admin)
```

### Test Societies
Three test societies are pre-seeded:
1. **Ambience Creations** - Sector 22, Gurgaon
   - Flats: A-101, A-102, A-103, B-201, B-202, C-301, C-302

2. **Ashiana Greens** - Sector 50, Gurgaon
   - Flats: 1-101, 1-102, 2-201, 2-202, 3-301

3. **DLF Pinnacle** - Downtown, Gurgaum
   - Flats: 1A, 2A, 1B, 2B

## 📄 Document Upload

### Supported Formats
- **ID Proof**: PDF, JPG, PNG, JPEG (Max 50 MB)
- **Address Proof**: PDF, JPG, PNG, JPEG (Max 50 MB)

### Document Storage
Files are stored in:
```
documents/
└── {user_id}/
    ├── {user_id}_id_proof_[timestamp].pdf
    └── {user_id}_address_proof_[timestamp].pdf
```

### Database Reference
```sql
CREATE TABLE user_documents (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES profiles(id),
    document_type TEXT, -- 'id_proof', 'address_proof', 'rental_agreement'
    file_url TEXT,      -- Public URL from Supabase Storage
    verified BOOLEAN,   -- Admin verification status
    uploaded_at TIMESTAMPTZ
);
```

## 🧪 Testing

### Test Accounts (Pre-seeded)

**Resident Account:**
- Email: `resident@test.com`
- Password: `password123`
- Society: Ambience Creations
- Flat: A-101

**Guard Account:**
- Email: `guard@test.com`
- Password: `password123`
- Society: Ambience Creations

### New Registration Flow
1. Click "Sign Up" on login screen
2. Fill in all fields (name, email, password, phone)
3. Select society: **Ambience Creations**
4. Select flat: **A-102** (or any available)
5. Upload optional documents
6. Click "Create Account"
7. Should see success message
8. Automatically return to login screen
9. Login with new credentials

## 🐛 Troubleshooting

### "User profile not found" Error
**Solution:**
- The app auto-creates missing profiles now
- If still fails, check RLS policies are enabled
- Run: `supabase db push` to apply all migrations

### Documents Not Upload
**Solution:**
- Ensure `documents` storage bucket exists and is **Private**
- Check RLS policies on `storage.objects` table
- Verify file size < 50 MB
- Check file format is PDF/JPG/PNG

### Society Dropdown Empty
**Solution:**
- Run migration `003_seed_societies_and_testing.sql`
- Ensure profile table has `society_id` (not nullable)
- Check database connection in `.env`

### Phone Login Not Working
**Solution:**
- Phone login is currently a placeholder
- Currently only Email login is fully functional
- Phone login will be implemented in next iteration with SMS provider

## 🚀 Next Steps

1. **Admin Dashboard** - Verify documents and approve new residents
2. **Phone Authentication** - Integrate with SMS provider (Twilio/SNS)
3. **Email Verification** - Require email confirmation during signup
4. **Guards Management** - Allow society admin to onboard guards
5. **Analytics** - Track registration metrics per society

## 📚 API Reference

### SupabaseService Methods

```dart
// Get all societies
Future<List<Society>> getSocieties()

// Get units by society
Future<List<Unit>> getUnitsBySociety(String societyId)

// Register with email & society
Future<AuthResponse> signUpWithEmailAndSociety({
  required String email,
  required String password,
  required String fullName,
  required String phoneNumber,
  required String societyId,
  required String flatId,
})

// Upload documents
Future<String> uploadDocument({
  required File file,
  required String userId,
  required String documentType,  // 'id_proof' or 'address_proof'
})

// Get user documents
Future<List<Map<String, dynamic>>> getUserDocuments(String userId)
```

## 📞 Support

For issues or questions:
1. Check database migrations are applied
2. Verify RLS policies are enabled
3. Check `.env` has correct Supabase credentials
4. Check logs for detailed error messages
5. Review the test data in migration `003_seed_societies_and_testing.sql`
