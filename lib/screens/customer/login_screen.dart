import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../data/user_database.dart';
import '../../data/document_database.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  bool _obscurePassword = true;
  bool _isSubmitting = false;
  String? _loginError;

  bool _emailTouched = false;
  bool _passwordTouched = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(() {
      if (!_emailFocusNode.hasFocus) {
        setState(() => _emailTouched = true);
      }
    });
    _passwordFocusNode.addListener(() {
      if (!_passwordFocusNode.hasFocus) {
        setState(() => _passwordTouched = true);
      }
    });
  }

  String? _validateEmail() {
    final val = _emailController.text.trim();
    if (val.isEmpty) return 'Email Address is required';
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(val)) return 'Please enter a valid email address';
    return null;
  }

  String? _validatePassword() {
    final val = _passwordController.text;
    if (val.isEmpty) return 'Password is required';
    return null;
  }

  bool _isFormValid() {
    return _validateEmail() == null && _validatePassword() == null;
  }

  void _handleLogin() {
    if (!_isFormValid()) return;

    setState(() {
      _isSubmitting = true;
      _loginError = null;
    });

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        final email = _emailController.text.trim().toLowerCase();
        final password = _passwordController.text.trim();

        final isWorker = DocumentDatabase.onboardedTechnicians.any(
          (t) => t['email']?.toString().toLowerCase().trim() == email,
        );

        if (isWorker) {
          setState(() {
            _isSubmitting = false;
            _loginError = 'This email is registered as a worker account. Please login from the worker login screen.';
          });
          return;
        }

        final hasCustomer = UserDatabase.users.any(
          (u) => u['email']?.toString().toLowerCase().trim() == email.toLowerCase(),
        );

        if (!hasCustomer) {
          setState(() {
            _isSubmitting = false;
            _loginError = 'No account found with this email.';
          });
          return;
        }

        final bool success;
        try {
          success = UserDatabase.login(email, password);
        } catch (error) {
          setState(() {
            _isSubmitting = false;
            _loginError = 'Unable to complete login. Please try again.';
          });
          return;
        }

        setState(() {
          _isSubmitting = false;
        });

        if (success) {
          final user = UserDatabase.currentUser;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Welcome back, ${user?['fullName'] ?? 'User'}!',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
              backgroundColor: AppColors.primary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
          context.go('/customer/home');
        } else {
          setState(() {
            _loginError = 'Incorrect password. Please try again.';
          });
        }
      }
    });
  }

  void _showForgotPasswordDialog() {
    final TextEditingController resetEmailController = TextEditingController(text: _emailController.text);
    final resetFormKey = GlobalKey<FormState>();
    bool isResetting = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(
                'Forgot Password?',
                style: GoogleFonts.inter(fontWeight: FontWeight.w700),
              ),
              content: Form(
                key: resetFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enter your registered email address and we will send you a simulated password reset link.',
                      style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurfaceVariant, height: 1.4),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: resetEmailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'name@example.com',
                        prefixIcon: const Icon(Icons.email_outlined),
                        filled: true,
                        fillColor: AppColors.surfaceContainerLow,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      validator: (value) {
                        final val = value?.trim() ?? '';
                        if (val.isEmpty) return 'Email is required';
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isResetting ? null : () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant),
                  ),
                ),
                ElevatedButton(
                  onPressed: isResetting
                      ? null
                      : () {
                          if (resetFormKey.currentState?.validate() ?? false) {
                            setDialogState(() => isResetting = true);
                            Future.delayed(const Duration(seconds: 1500), () {
                              if (context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        const Icon(Icons.mark_email_read, color: Colors.white),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Simulated password reset link sent to ${resetEmailController.text.trim()}!',
                                            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                      ],
                                    ),
                                    backgroundColor: AppColors.primary,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                );
                              }
                            });
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: isResetting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text('Send Link', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final formValid = _isFormValid();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Login',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 18, color: AppColors.onSurface),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => context.go('/customer/welcome'),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 48),
                child: IntrinsicHeight(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome Back',
                          style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.onBackground, letterSpacing: -0.5),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Sign in to your USTAAD account to continue booking services',
                          style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurfaceVariant),
                        ),
                        const SizedBox(height: 32),

                        // Login Error Banner
                        if (_loginError != null) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.errorContainer.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline, color: AppColors.error),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _loginError!,
                                    style: GoogleFonts.inter(fontSize: 13, color: AppColors.error, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Email Field
                        _buildFieldLabel('Email Address *'),
                        TextFormField(
                          controller: _emailController,
                          focusNode: _emailFocusNode,
                          keyboardType: TextInputType.emailAddress,
                          style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500),
                          decoration: _buildInputDecoration(
                            hint: 'name@example.com',
                            icon: Icons.email_outlined,
                            errorText: _emailTouched ? _validateEmail() : null,
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 20),

                        // Password Field
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildFieldLabel('Password *'),
                            GestureDetector(
                              onTap: _showForgotPasswordDialog,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 8.0, right: 4),
                                child: Text(
                                  'Forgot Password?',
                                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary),
                                ),
                              ),
                            ),
                          ],
                        ),
                        TextFormField(
                          controller: _passwordController,
                          focusNode: _passwordFocusNode,
                          obscureText: _obscurePassword,
                          style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500),
                          decoration: _buildInputDecoration(
                            hint: 'Enter your password',
                            icon: Icons.lock_outline,
                            errorText: _passwordTouched ? _validatePassword() : null,
                          ).copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: AppColors.onSurfaceVariant,
                              ),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 32),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: (formValid && !_isSubmitting) ? _handleLogin : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: AppColors.surfaceContainerHigh,
                              disabledForegroundColor: AppColors.onSurfaceVariant,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: _isSubmitting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : Text(
                                    'Login',
                                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
                                  ),
                          ),
                        ),
                        const Spacer(),
                        const SizedBox(height: 24),
                        const Divider(color: AppColors.surfaceVariant),
                        const SizedBox(height: 24),

                        // Redirect to Signup
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurfaceVariant),
                            ),
                            GestureDetector(
                              onTap: () => context.go('/customer/signup'),
                              child: Text(
                                'Create Account',
                                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(
        label,
        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.onBackground),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hint,
    required IconData icon,
    required String? errorText,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurfaceVariant),
      prefixIcon: Icon(icon, color: AppColors.onSurfaceVariant, size: 20),
      errorText: errorText,
      errorStyle: GoogleFonts.inter(fontSize: 12, color: AppColors.error, fontWeight: FontWeight.w600),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.surfaceVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.surfaceVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
    );
  }
}
