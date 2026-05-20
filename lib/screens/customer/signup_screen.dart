import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../data/user_database.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _addressFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();

  String? _selectedCity;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isSubmitting = false;

  // Touched states for inline focus validation
  bool _nameTouched = false;
  bool _emailTouched = false;
  bool _phoneTouched = false;
  bool _addressTouched = false;
  bool _cityTouched = false;
  bool _passwordTouched = false;
  bool _confirmPasswordTouched = false;

  final List<String> _cities = [
    'Islamabad',
    'Lahore',
    'Karachi',
    'Rawalpindi',
    'Peshawar',
    'Multan',
    'Faisalabad',
    'Sialkot',
    'Hyderabad',
    'Quetta',
    'Gujranwala'
  ];

  @override
  void initState() {
    super.initState();
    // Add focus listeners
    _nameFocusNode.addListener(() {
      if (!_nameFocusNode.hasFocus) {
        setState(() => _nameTouched = true);
      }
    });
    _emailFocusNode.addListener(() {
      if (!_emailFocusNode.hasFocus) {
        setState(() => _emailTouched = true);
      }
    });
    _phoneFocusNode.addListener(() {
      if (!_phoneFocusNode.hasFocus) {
        setState(() => _phoneTouched = true);
      }
    });
    _addressFocusNode.addListener(() {
      if (!_addressFocusNode.hasFocus) {
        setState(() => _addressTouched = true);
      }
    });
    _passwordFocusNode.addListener(() {
      if (!_passwordFocusNode.hasFocus) {
        setState(() => _passwordTouched = true);
      }
    });
    _confirmPasswordFocusNode.addListener(() {
      if (!_confirmPasswordFocusNode.hasFocus) {
        setState(() => _confirmPasswordTouched = true);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _phoneFocusNode.dispose();
    _addressFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  // Field validation functions
  String? _validateName() {
    final val = _nameController.text.trim();
    if (val.isEmpty) return 'Full Name is required';
    return null;
  }

  String? _validateEmail() {
    final val = _emailController.text.trim();
    if (val.isEmpty) return 'Email Address is required';
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(val)) return 'Please enter a valid email address';
    return null;
  }

  String? _validatePhone() {
    final val = _phoneController.text.trim();
    if (val.isEmpty) return 'Phone number is required';
    if (val.length != 11 || !val.startsWith('03')) {
      return 'Phone number must be exactly 11 digits starting with 03';
    }
    return null;
  }

  String? _validateAddress() {
    final val = _addressController.text.trim();
    if (val.isEmpty) return 'Complete Address is required';
    return null;
  }

  String? _validateCity() {
    if (_selectedCity == null) return 'City is required';
    return null;
  }

  String? _validatePassword() {
    final val = _passwordController.text;
    if (val.isEmpty) return 'Password is required';
    if (val.length < 8) return 'Password must be minimum 8 characters';
    if (!RegExp(r'[A-Z]').hasMatch(val)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(val)) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  String? _validateConfirmPassword() {
    final val = _confirmPasswordController.text;
    if (val.isEmpty) return 'Please confirm your password';
    if (val != _passwordController.text) return 'Passwords do not match';
    return null;
  }

  bool _isFormValid() {
    return _validateName() == null &&
        _validateEmail() == null &&
        _validatePhone() == null &&
        _validateAddress() == null &&
        _validateCity() == null &&
        _validatePassword() == null &&
        _validateConfirmPassword() == null;
  }

  void _showCitySearchSheet() {
    setState(() => _cityTouched = true);
    String filterText = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final filteredCities = _cities
                .where((city) => city.toLowerCase().contains(filterText.toLowerCase()))
                .toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  // Drag indicator
                  Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Select Your City',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onBackground,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search city...',
                        prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                        filled: true,
                        fillColor: AppColors.surfaceContainerLow,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      onChanged: (value) {
                        setSheetState(() {
                          filterText = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Cities List
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredCities.length,
                      itemBuilder: (context, index) {
                        final city = filteredCities[index];
                        final isSelected = city == _selectedCity;

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                          title: Text(
                            city,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? AppColors.primary : AppColors.onBackground,
                            ),
                          ),
                          trailing: isSelected
                              ? const Icon(Icons.check_circle, color: AppColors.primary)
                              : null,
                          onTap: () {
                            setState(() {
                              _selectedCity = city;
                            });
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showTermsDialog(String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        content: SingleChildScrollView(
          child: Text(
            'Welcome to Khidmat AI services! By using our platform, you agree to connect with verified service providers honestly and verify final pricing before service initiation. Your details are secured locally on your device for absolute privacy.',
            style: GoogleFonts.inter(fontSize: 14, height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.primary)),
          )
        ],
      ),
    );
  }

  void _handleSignup() {
    if (!_isFormValid()) return;

    setState(() {
      _isSubmitting = true;
    });

    // Simulate database signup saving
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        final success = UserDatabase.signup({
          'fullName': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
          'address': _addressController.text.trim(),
          'city': _selectedCity!,
          'password': _passwordController.text,
        });

        setState(() {
          _isSubmitting = false;
        });

        if (success) {
          // Toast verification message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Welcome to Khidmat AI, ${_nameController.text.trim()}!',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
              backgroundColor: AppColors.primary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
          // Navigate to home screen
          context.go('/customer/home');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Email already registered! Try logging in.',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    });
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
          'Create Account',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 18, color: AppColors.onSurface),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => context.go('/customer/welcome'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Join Khidmat AI',
                  style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.onBackground, letterSpacing: -0.5),
                ),
                const SizedBox(height: 6),
                Text(
                  'Get access to top-rated service providers instantly',
                  style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: 24),

                // Name Input
                _buildFieldLabel('Full Name *'),
                TextFormField(
                  controller: _nameController,
                  focusNode: _nameFocusNode,
                  keyboardType: TextInputType.name,
                  style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500),
                  decoration: _buildInputDecoration(
                    hint: 'Enter your full name',
                    icon: Icons.person_outline,
                    errorText: _nameTouched ? _validateName() : null,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 20),

                // Email Input
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

                // Phone Input (With 🇵🇰 Pakistan flag prefix layout)
                _buildFieldLabel('Phone Number *'),
                TextFormField(
                  controller: _phoneController,
                  focusNode: _phoneFocusNode,
                  keyboardType: TextInputType.phone,
                  maxLength: 11,
                  buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500),
                  decoration: _buildInputDecoration(
                    hint: 'e.g. 03001234567',
                    icon: null,
                    errorText: _phoneTouched ? _validatePhone() : null,
                  ).copyWith(
                    prefixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(width: 16),
                        const Text('🇵🇰', style: TextStyle(fontSize: 22)),
                        const SizedBox(width: 12),
                      ],
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 20),

                // City Input (Interactive Bottom Sheet Searcher)
                _buildFieldLabel('City *'),
                InkWell(
                  onTap: _showCitySearchSheet,
                  borderRadius: BorderRadius.circular(12),
                  child: InputDecorator(
                    decoration: _buildInputDecoration(
                      hint: 'Select your city',
                      icon: Icons.location_city_outlined,
                      errorText: _cityTouched ? _validateCity() : null,
                    ),
                    isEmpty: _selectedCity == null,
                    child: _selectedCity != null
                        ? Text(
                            _selectedCity!,
                            style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.onSurface),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 20),

                // Address Input
                _buildFieldLabel('Complete Address *'),
                TextFormField(
                  controller: _addressController,
                  focusNode: _addressFocusNode,
                  maxLines: 3,
                  minLines: 2,
                  style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500),
                  decoration: _buildInputDecoration(
                    hint: 'House number, street, sector, area info...',
                    icon: Icons.map_outlined,
                    errorText: _addressTouched ? _validateAddress() : null,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 20),

                // Password Input
                _buildFieldLabel('Password *'),
                TextFormField(
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  obscureText: _obscurePassword,
                  style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500),
                  decoration: _buildInputDecoration(
                    hint: 'Minimum 8 characters',
                    icon: Icons.lock_open_outlined,
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
                const SizedBox(height: 20),

                // Confirm Password Input
                _buildFieldLabel('Confirm Password *'),
                TextFormField(
                  controller: _confirmPasswordController,
                  focusNode: _confirmPasswordFocusNode,
                  obscureText: _obscureConfirmPassword,
                  style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500),
                  decoration: _buildInputDecoration(
                    hint: 'Repeat your password',
                    icon: Icons.lock_outline,
                    errorText: _confirmPasswordTouched ? _validateConfirmPassword() : null,
                  ).copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: AppColors.onSurfaceVariant,
                      ),
                      onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 32),

                // Create Account Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: (formValid && !_isSubmitting) ? _handleSignup : null,
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
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Creating your account...',
                                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
                              ),
                            ],
                          )
                        : Text(
                            'Create Account',
                            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // Terms and Conditions Note
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        Text(
                          'By creating an account you agree to our ',
                          style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant),
                          textAlign: TextAlign.center,
                        ),
                        GestureDetector(
                          onTap: () => _showTermsDialog('Terms of Service'),
                          child: Text(
                            'Terms of Service',
                            style: GoogleFonts.inter(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600),
                          ),
                        ),
                        Text(
                          ' and ',
                          style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant),
                        ),
                        GestureDetector(
                          onTap: () => _showTermsDialog('Privacy Policy'),
                          child: Text(
                            'Privacy Policy',
                            style: GoogleFonts.inter(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Divider(color: AppColors.surfaceVariant),
                const SizedBox(height: 24),

                // Bottom Login Option
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurfaceVariant),
                    ),
                    GestureDetector(
                      onTap: () => context.go('/customer/login'),
                      child: Text(
                        'Login',
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
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
    required IconData? icon,
    required String? errorText,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurfaceVariant),
      prefixIcon: icon != null ? Icon(icon, color: AppColors.onSurfaceVariant, size: 20) : null,
      errorText: errorText,
      errorMaxLines: 2,
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
