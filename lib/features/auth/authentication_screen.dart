import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../core/services/supabase_service.dart';
import '../../core/models/society.dart';

final logger = Logger();

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({super.key});

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  bool _isLogin = true; // Toggle between login and signup
  bool _isPhoneAuth = false; // Toggle between email and phone authentication

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLogin
          ? (_isPhoneAuth ? _buildPhoneLoginScreen() : _buildEmailLoginScreen())
          : (_isPhoneAuth
              ? _buildPhoneSignupScreen()
              : _buildEmailSignupScreen()),
    );
  }

  // ==================== EMAIL LOGIN ====================
  Widget _buildEmailLoginScreen() {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    bool isLoading = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                // Header
                Icon(Icons.gps_fixed, size: 60, color: Colors.orange.shade400),
                const SizedBox(height: 20),
                const Text(
                  'MyGate',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Society Management Made Easy',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Email Field
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    hintText: 'Enter email',
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.orange.shade50,
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                // Password Field
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    hintText: 'Enter password',
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.orange.shade50,
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 24),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: isLoading
                        ? null
                        : () async {
                            if (emailController.text.isEmpty ||
                                passwordController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please fill all fields'),
                                ),
                              );
                              return;
                            }

                            try {
                              final service = SupabaseService();
                              await service.signInWithEmail(
                                emailController.text.trim(),
                                passwordController.text,
                              );
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Login failed: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            } finally {
                              if (mounted) setState(() => isLoading = false);
                            }
                          },
                    child: isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Login with Email',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // Switch to Phone Login
                TextButton(
                  onPressed: () => setState(() => _isPhoneAuth = true),
                  child: const Text(
                    'Login with Phone Number',
                    style: TextStyle(color: Colors.orange),
                  ),
                ),
                const SizedBox(height: 24),

                // Switch to Signup
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? "),
                    TextButton(
                      onPressed: () => setState(() => _isLogin = false),
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==================== PHONE LOGIN ====================
  Widget _buildPhoneLoginScreen() {
    final phoneController = TextEditingController();
    final otpController = TextEditingController();
    bool isLoading = false;
    bool otpSent = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                Icon(Icons.phone_android,
                    size: 60, color: Colors.orange.shade400),
                const SizedBox(height: 20),
                const Text(
                  'Login with Phone',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),

                // Phone Field
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    hintText: '+91 98765 43210',
                    prefixIcon: const Icon(Icons.phone),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.orange.shade50,
                  ),
                  keyboardType: TextInputType.phone,
                  enabled: !otpSent && !isLoading,
                ),
                const SizedBox(height: 16),

                if (otpSent) ...[
                  // OTP Field
                  TextField(
                    controller: otpController,
                    decoration: InputDecoration(
                      hintText: 'Enter 6-digit OTP',
                      prefixIcon: const Icon(Icons.security),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.orange.shade50,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 24),
                ],

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: isLoading
                        ? null
                        : () async {
                            if (!otpSent) {
                              // Send OTP
                              if (phoneController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please enter phone number'),
                                  ),
                                );
                                return;
                              }

                              setState(() => isLoading = true);

                              try {
                                final service = SupabaseService();
                                await service.signInWithPhone(
                                  phoneController.text.trim(),
                                );
                                setState(() {
                                  otpSent = true;
                                  isLoading = false;
                                });

                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('OTP sent to your phone!'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                }
                              } catch (e) {
                                setState(() => isLoading = false);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            } else {
                              // Verify OTP
                              if (otpController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please enter OTP'),
                                  ),
                                );
                                return;
                              }

                              setState(() => isLoading = true);

                              try {
                                final service = SupabaseService();
                                await service.verifyPhoneOTP(
                                  phoneController.text.trim(),
                                  otpController.text.trim(),
                                );

                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Login successful!'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          Text('OTP verification failed: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              } finally {
                                if (mounted) setState(() => isLoading = false);
                              }
                            }
                          },
                    child: isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            otpSent ? 'Verify OTP' : 'Send OTP',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // Back to Email Login
                TextButton(
                  onPressed: () => setState(() => _isPhoneAuth = false),
                  child: const Text(
                    'Login with Email Instead',
                    style: TextStyle(color: Colors.orange),
                  ),
                ),
                const SizedBox(height: 24),

                // Switch to Signup
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? "),
                    TextButton(
                      onPressed: () => setState(() => _isLogin = false),
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==================== SIGNUP SCREEN ====================
  Widget _buildEmailSignupScreen() {
    return _SignupScreenWidget(
      onBack: () => setState(() => _isLogin = true),
      usePhone: false,
    );
  }

  Widget _buildPhoneSignupScreen() {
    return _SignupScreenWidget(
      onBack: () => setState(() => _isLogin = true),
      usePhone: true,
    );
  }
}

// ==================== SIGNUP WIDGET ====================
class _SignupScreenWidget extends StatefulWidget {
  final VoidCallback onBack;
  final bool usePhone;

  const _SignupScreenWidget({
    required this.onBack,
    this.usePhone = false,
  });

  @override
  State<_SignupScreenWidget> createState() => _SignupScreenWidgetState();
}

class _SignupScreenWidgetState extends State<_SignupScreenWidget> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  List<Society> _societies = [];
  Society? _selectedSociety;
  List<Unit> _units = [];
  Unit? _selectedUnit;

  File? _idProofFile;
  File? _addressProofFile;

  bool _isLoading = false;
  bool _isLoadingSocieties = true;
  bool _otpSent = false;

  final _supabaseService = SupabaseService();

  @override
  void initState() {
    super.initState();
    _loadSocieties();
  }

  Future<void> _loadSocieties() async {
    try {
      final societies = await _supabaseService.getSocieties();
      setState(() {
        _societies = societies;
        _isLoadingSocieties = false;
      });
    } catch (e) {
      logger.e('Error loading societies: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading societies: $e')),
        );
      }
      setState(() => _isLoadingSocieties = false);
    }
  }

  Future<void> _loadUnits(String societyId) async {
    try {
      final units = await _supabaseService.getUnitsBySociety(societyId);
      setState(() => _units = units);
    } catch (e) {
      logger.e('Error loading units: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading flats: $e')),
        );
      }
    }
  }

  Future<void> _pickFile(String docType) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'png', 'jpeg'],
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          if (docType == 'id_proof') {
            _idProofFile = File(result.files.first.path!);
          } else {
            _addressProofFile = File(result.files.first.path!);
          }
        });
      }
    } catch (e) {
      logger.e('Error picking file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking file: $e')),
      );
    }
  }

  Future<void> _signup() async {
    // Validation
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _nameController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _selectedSociety == null ||
        _selectedUnit == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
        ),
      );
      return;
    }

    if (_passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must be at least 6 characters'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Sign up user
      final response = await _supabaseService.signUpWithEmailAndSociety(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        societyId: _selectedSociety!.id,
        flatId: _selectedUnit!.id,
      );

      if (response.user != null && mounted) {
        // Upload documents if selected

        if (_idProofFile != null) {
          await _supabaseService.uploadDocument(
            file: _idProofFile!,
            userId: response.user!.id,
            documentType: 'id_proof',
          );
        }

        if (_addressProofFile != null) {
          await _supabaseService.uploadDocument(
            file: _addressProofFile!,
            userId: response.user!.id,
            documentType: 'address_proof',
          );
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sign up successful! Please login now.'),
              duration: Duration(seconds: 3),
            ),
          );

          // Navigate back to login
          await Future.delayed(const Duration(seconds: 2));
          if (mounted) {
            widget.onBack();
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign up failed: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingSocieties) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
      ),
      body: widget.usePhone ? _buildPhoneSignupForm() : _buildEmailSignupForm(),
    );
  }

  // ==================== EMAIL SIGNUP FORM ====================
  Widget _buildEmailSignupForm() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // Name Field
            _buildTextField(
              controller: _nameController,
              label: 'Full Name',
              icon: Icons.person,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),

            // Phone Field
            _buildTextField(
              controller: _phoneController,
              label: 'Phone Number',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),

            // Email Field
            _buildTextField(
              controller: _emailController,
              label: 'Email',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),

            // Password Field
            _buildTextField(
              controller: _passwordController,
              label: 'Password',
              icon: Icons.lock,
              obscureText: true,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 24),

            // Society Dropdown
            const Text(
              'Select Your Society *',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<Society>(
              value: _selectedSociety,
              items: _societies
                  .map(
                    (s) => DropdownMenuItem(
                      value: s,
                      child: Text(s.name),
                    ),
                  )
                  .toList(),
              onChanged: _isLoading
                  ? null
                  : (society) {
                      setState(() {
                        _selectedSociety = society;
                        _selectedUnit = null;
                        _units = [];
                      });
                      if (society != null) {
                        _loadUnits(society.id);
                      }
                    },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.orange.shade50,
                hintText: 'Choose a society',
              ),
            ),
            const SizedBox(height: 16),

            // Flat Dropdown
            if (_selectedSociety != null) ...[
              const Text(
                'Select Your Flat/Unit *',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<Unit>(
                value: _selectedUnit,
                items: _units
                    .map(
                      (u) => DropdownMenuItem(
                        value: u,
                        child: Text(u.toString()),
                      ),
                    )
                    .toList(),
                onChanged: _isLoading
                    ? null
                    : (unit) {
                        setState(() => _selectedUnit = unit);
                      },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.orange.shade50,
                  hintText: 'Choose your flat',
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Document Upload Section
            const Text(
              'Upload Documents (Optional)',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),

            _buildDocumentUploadButton(
              label: 'ID Proof (Aadhar/PAN)',
              file: _idProofFile,
              onTap: () => _pickFile('id_proof'),
            ),
            const SizedBox(height: 12),

            _buildDocumentUploadButton(
              label: 'Address Proof',
              file: _addressProofFile,
              onTap: () => _pickFile('address_proof'),
            ),
            const SizedBox(height: 32),

            // Sign Up Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isLoading ? null : _signup,
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // Toggle to Phone Signup
            Center(
              child: TextButton(
                onPressed: () => widget.onBack(),
                child: const Text(
                  'Already have an account? Login',
                  style: TextStyle(color: Colors.orange),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ==================== PHONE SIGNUP FORM ====================
  Widget _buildPhoneSignupForm() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Icon(Icons.phone_android, size: 60, color: Colors.orange.shade400),
            const SizedBox(height: 20),
            const Text(
              'Sign Up with Phone',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),

            // Name Field
            _buildTextField(
              controller: _nameController,
              label: 'Full Name',
              icon: Icons.person,
              enabled: !_isLoading && !_otpSent,
            ),
            const SizedBox(height: 16),

            // Phone Field
            _buildTextField(
              controller: _phoneController,
              label: 'Phone Number',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
              enabled: !_isLoading && !_otpSent,
            ),
            const SizedBox(height: 16),

            if (_otpSent) ...[
              // OTP Field
              _buildTextField(
                controller: _otpController,
                label: 'Enter 6-digit OTP',
                icon: Icons.security,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 24),
            ],

            // Society Dropdown
            const Text(
              'Select Your Society *',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<Society>(
              value: _selectedSociety,
              items: _societies
                  .map(
                    (s) => DropdownMenuItem(
                      value: s,
                      child: Text(s.name),
                    ),
                  )
                  .toList(),
              onChanged: (_isLoading || _otpSent)
                  ? null
                  : (society) {
                      setState(() {
                        _selectedSociety = society;
                        _selectedUnit = null;
                        _units = [];
                      });
                      if (society != null) {
                        _loadUnits(society.id);
                      }
                    },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.orange.shade50,
                hintText: 'Choose a society',
              ),
            ),
            const SizedBox(height: 16),

            // Flat Dropdown
            if (_selectedSociety != null) ...[
              const Text(
                'Select Your Flat/Unit *',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<Unit>(
                value: _selectedUnit,
                items: _units
                    .map(
                      (u) => DropdownMenuItem(
                        value: u,
                        child: Text(u.toString()),
                      ),
                    )
                    .toList(),
                onChanged: (_isLoading || _otpSent)
                    ? null
                    : (unit) {
                        setState(() => _selectedUnit = unit);
                      },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.orange.shade50,
                  hintText: 'Choose your flat',
                ),
              ),
              const SizedBox(height: 24),
            ],

            const SizedBox(height: 24),

            // Sign Up Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isLoading ? null : () => _signupWithPhone(),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        _otpSent ? 'Verify & Sign Up' : 'Send OTP',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // Toggle to Email Signup
            Center(
              child: TextButton(
                onPressed: () => widget.onBack(),
                child: const Text(
                  'Already have an account? Login',
                  style: TextStyle(color: Colors.orange),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ==================== PHONE SIGNUP METHOD ====================
  Future<void> _signupWithPhone() async {
    if (!_otpSent) {
      // Send OTP
      if (_phoneController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter phone number')),
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        await _supabaseService.signInWithPhone(_phoneController.text.trim());
        setState(() {
          _otpSent = true;
          _isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('OTP sent! Check your phone.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error sending OTP: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      // Verify OTP and sign up
      if (_nameController.text.isEmpty ||
          _otpController.text.isEmpty ||
          _selectedSociety == null ||
          _selectedUnit == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all required fields')),
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        await _supabaseService.verifyPhoneOTP(
          _phoneController.text.trim(),
          _otpController.text.trim(),
        );

        // Create profile with phone
        await _supabaseService.createPhoneProfile(
          fullName: _nameController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          societyId: _selectedSociety!.id,
          flatId: _selectedUnit!.id,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sign up successful! Please login now.'),
              duration: Duration(seconds: 3),
            ),
          );

          await Future.delayed(const Duration(seconds: 2));
          if (mounted) {
            widget.onBack();
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.orange.shade50,
      ),
      keyboardType: keyboardType,
      obscureText: obscureText,
      enabled: enabled,
    );
  }

  Widget _buildDocumentUploadButton({
    required String label,
    required File? file,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.orange),
          borderRadius: BorderRadius.circular(12),
          color: file != null ? Colors.green.shade50 : Colors.orange.shade50,
        ),
        child: Row(
          children: [
            Icon(
              file != null ? Icons.check_circle : Icons.upload_file,
              color: file != null ? Colors.green : Colors.orange,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  if (file != null)
                    Text(
                      'Uploaded: ${file.path.split('/').last}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  else
                    const Text(
                      'Click to upload PDF or Image',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }
}
