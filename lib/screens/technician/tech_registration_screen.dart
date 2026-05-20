import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../data/document_database.dart';

class TechRegistrationScreen extends StatefulWidget {
  const TechRegistrationScreen({super.key});

  @override
  State<TechRegistrationScreen> createState() => _TechRegistrationScreenState();
}

class _TechRegistrationScreenState extends State<TechRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _cnicController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    // Load pre-existing if any
    _nameController.text = DocumentDatabase.currentName ?? '';
    _emailController.text = DocumentDatabase.currentEmail ?? '';
    _phoneController.text = DocumentDatabase.currentPhone ?? '';
    _cnicController.text = DocumentDatabase.currentCnic ?? '';
    _passwordController.text = DocumentDatabase.currentPassword ?? '';
    _confirmPasswordController.text = DocumentDatabase.currentPassword ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cnicController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _isNameValid(String val) {
    final trimVal = val.trim();
    if (trimVal.isEmpty || trimVal.length < 3) return false;
    return RegExp(r"^[a-zA-Z\s]+$").hasMatch(trimVal);
  }

  bool _isEmailValid(String val) {
    final trimVal = val.trim();
    if (trimVal.isEmpty) return false;
    return RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(trimVal);
  }

  bool _isPhoneValid(String val) {
    final trimVal = val.trim();
    if (trimVal.length != 11 || !trimVal.startsWith('03')) return false;
    return RegExp(r"^\d+$").hasMatch(trimVal);
  }

  bool _isCnicValid(String val) {
    final trimVal = val.trim();
    if (trimVal.length != 13) return false;
    return RegExp(r"^\d+$").hasMatch(trimVal);
  }

  bool _isPasswordValid(String val) {
    if (val.length < 8) return false;
    final hasUppercase = val.contains(RegExp(r'[A-Z]'));
    final hasDigits = val.contains(RegExp(r'[0-9]'));
    return hasUppercase && hasDigits;
  }

  bool _isConfirmPasswordValid(String val, String pass) {
    return val == pass && val.isNotEmpty;
  }

  bool _isFormValid() {
    return _isNameValid(_nameController.text) &&
        _isEmailValid(_emailController.text) &&
        _isPhoneValid(_phoneController.text) &&
        _isCnicValid(_cnicController.text) &&
        _isPasswordValid(_passwordController.text) &&
        _isConfirmPasswordValid(_confirmPasswordController.text, _passwordController.text);
  }

  void _handleContinue() {
    if (_isFormValid() && _formKey.currentState!.validate()) {
      DocumentDatabase.currentName = _nameController.text.trim();
      DocumentDatabase.currentEmail = _emailController.text.trim();
      DocumentDatabase.currentPhone = _phoneController.text.trim();
      DocumentDatabase.currentCnic = _cnicController.text.trim();
      DocumentDatabase.currentPassword = _passwordController.text;
      context.go('/technician/service-info');
    } else {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Please fill in all required fields correctly before proceeding',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
            ),
          ]),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool formValid = _isFormValid();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => context.go('/role-selection')),
        title: Text('Khidmat AI', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary)),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight - 32),
              child: IntrinsicHeight(
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(children: [
                    Text('Become a Technician', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Text('Join our platform and connect with customers in your area.', style: GoogleFonts.inter(fontSize: 16, color: AppColors.onSurfaceVariant), textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    // Step indicator
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      _stepCircle('1', 'Personal', true),
                      Container(width: 40, height: 2, color: AppColors.surfaceVariant),
                      _stepCircle('2', 'Service', false),
                      Container(width: 40, height: 2, color: AppColors.surfaceVariant),
                      _stepCircle('3', 'Docs', false),
                    ]),
                    const SizedBox(height: 32),
                    // Form
                    Container(
                      width: double.infinity, padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: AppColors.surfaceContainerLowest, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.surfaceVariant)),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('1. Personal Info', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 16),
                        
                        // Full Name
                        Text('Full Name *', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(hintText: 'e.g. Ahmed Khan'),
                          onChanged: (_) => setState(() {}),
                          validator: (value) {
                            final val = value ?? '';
                            if (val.trim().isEmpty) return 'Full Name is required';
                            if (val.trim().length < 3) return 'Full Name must be at least 3 characters';
                            if (!RegExp(r"^[a-zA-Z\s]+$").hasMatch(val.trim())) {
                              return 'No numbers or special characters allowed';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Email Address
                        Text('Email Address *', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(hintText: 'e.g. ahmed.khan@example.com'),
                          onChanged: (_) => setState(() {}),
                          validator: (value) {
                            final val = value ?? '';
                            if (val.trim().isEmpty) return 'Email is required';
                            if (!RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(val.trim())) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Phone Number
                        Text('Phone Number *', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          maxLength: 11,
                          buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: const InputDecoration(
                            hintText: 'e.g. 03001234567',
                            prefixIcon: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('🇵🇰', style: TextStyle(fontSize: 22)),
                                  SizedBox(width: 8),
                                ],
                              ),
                            ),
                          ),
                          onChanged: (_) => setState(() {}),
                          validator: (value) {
                            final val = value ?? '';
                            if (val.trim().isEmpty) return 'Phone number is required';
                            if (val.trim().length != 11) {
                              return 'Phone number must be exactly 11 digits';
                            }
                            if (!val.trim().startsWith('03')) {
                              return 'Please enter a valid Pakistani mobile number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // CNIC Number
                        Text('CNIC Number *', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _cnicController,
                          keyboardType: TextInputType.number,
                          maxLength: 13,
                          buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: const InputDecoration(hintText: 'e.g. 4210112345671'),
                          onChanged: (_) => setState(() {}),
                          validator: (value) {
                            final val = value ?? '';
                            if (val.trim().isEmpty) return 'CNIC number is required';
                            if (val.trim().length != 13) {
                              return 'CNIC must be exactly 13 digits';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Password
                        Text('Password *', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: 'Minimum 8 characters',
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          validator: (value) {
                            final val = value ?? '';
                            if (val.isEmpty) return 'Password is required';
                            if (val.length < 8 || !val.contains(RegExp(r'[A-Z]')) || !val.contains(RegExp(r'[0-9]'))) {
                              return 'Password must be at least 8 characters with one uppercase letter and one number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Confirm Password
                        Text('Confirm Password *', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: 'Repeat password',
                            suffixIcon: IconButton(
                              icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                              onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                            ),
                          ),
                          validator: (value) {
                            final val = value ?? '';
                            if (val.isEmpty) return 'Confirm Password is required';
                            if (val != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                      ]),
                    ),
                    const Spacer(),
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: _handleContinue,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(140, 52),
                          backgroundColor: formValid ? AppColors.primary : AppColors.surfaceContainerHigh,
                          foregroundColor: formValid ? Colors.white : AppColors.onSurfaceVariant,
                          elevation: formValid ? 2 : 0,
                          shadowColor: formValid ? null : Colors.transparent,
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [Text('Continue', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)), const SizedBox(width: 8), const Icon(Icons.arrow_forward, size: 20)]),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.auto_awesome, size: 14, color: AppColors.tertiaryFixedDim), const SizedBox(width: 4), Text('AI-Powered Verification', style: GoogleFonts.inter(fontSize: 14, color: AppColors.primary))]),
                    const SizedBox(height: 16),
                  ]),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _stepCircle(String num, String label, bool active) {
    return Column(children: [
      Container(
        width: 32, height: 32,
        decoration: BoxDecoration(shape: BoxShape.circle, color: active ? AppColors.primary : AppColors.surfaceContainerHigh),
        child: Center(child: Text(num, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: active ? Colors.white : AppColors.onSurfaceVariant))),
      ),
      const SizedBox(height: 4),
      Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: active ? FontWeight.w700 : FontWeight.w400, color: active ? AppColors.primary : AppColors.onSurfaceVariant)),
    ]);
  }
}
