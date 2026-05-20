import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../data/user_database.dart';
import '../../data/document_database.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();

  // Text Controllers for edit mode
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  String? _tempSelectedCity;

  // Touched states for inline validations in edit mode
  bool _nameTouched = false;
  bool _emailTouched = false;
  bool _phoneTouched = false;
  bool _addressTouched = false;

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
    _resetControllers();
  }

  void _resetControllers() {
    final user = UserDatabase.currentUser;
    _nameController = TextEditingController(text: user?['fullName'] ?? 'Ahmed Ali');
    _emailController = TextEditingController(text: user?['email'] ?? 'ahmed@gmail.com');
    _phoneController = TextEditingController(text: user?['phone'] ?? '0300-1234567');
    _addressController = TextEditingController(text: user?['address'] ?? 'House 12, Sector G-13');
    _tempSelectedCity = user?['city'] ?? 'Islamabad';

    _nameTouched = false;
    _emailTouched = false;
    _phoneTouched = false;
    _addressTouched = false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // Edit Mode Validations
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
    final phoneRegExp = RegExp(r'^03\d{2}-?\d{7}$');
    if (!phoneRegExp.hasMatch(val)) {
      return 'Phone number must be in 03XX-XXXXXXX format';
    }
    return null;
  }

  String? _validateAddress() {
    final val = _addressController.text.trim();
    if (val.isEmpty) return 'Complete Address is required';
    return null;
  }

  bool _isEditsValid() {
    return _validateName() == null &&
        _validateEmail() == null &&
        _validatePhone() == null &&
        _validateAddress() == null &&
        _tempSelectedCity != null;
  }

  // Get Initials for Avatar
  String _getUserInitials(String name) {
    if (name.isEmpty) return 'U';
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  void _showCitySelectSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select City',
                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              const Divider(),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _cities.length,
                  itemBuilder: (context, index) {
                    final city = _cities[index];
                    final isSelected = city == _tempSelectedCity;

                    return ListTile(
                      title: Text(
                        city,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? AppColors.primary : AppColors.onSurface,
                        ),
                      ),
                      trailing: isSelected ? const Icon(Icons.check_circle, color: AppColors.primary) : null,
                      onTap: () {
                        setState(() {
                          _tempSelectedCity = city;
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
  }

  void _saveProfileChanges() {
    if (!_isEditsValid()) return;

    if (UserDatabase.isTechAuthenticated) {
      final techId = UserDatabase.currentTechnician!['id']?.toString() ?? '';
      final updatedData = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'area': _addressController.text.trim(),
        'city': _tempSelectedCity!,
      };
      DocumentDatabase.updateTechnician(techId, updatedData);
      
      final updatedTech = Map<String, dynamic>.from(UserDatabase.currentTechnician!);
      updatedData.forEach((k, v) {
        updatedTech[k] = v;
      });
      UserDatabase.techLogin(updatedTech);
    } else {
      UserDatabase.updateProfile({
        'fullName': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'city': _tempSelectedCity!,
      });
    }

    setState(() {
      _isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Profile updated successfully!',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showChangePasswordSheet() {
    final TextEditingController currentPassController = TextEditingController();
    final TextEditingController newPassController = TextEditingController();
    final TextEditingController confirmPassController = TextEditingController();

    final passFormKey = GlobalKey<FormState>();
    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            // Password strength validation helpers
            final newPass = newPassController.text;
            final isLongEnough = newPass.length >= 8;
            final hasUppercase = RegExp(r'[A-Z]').hasMatch(newPass);
            final hasNumber = RegExp(r'[0-9]').hasMatch(newPass);

            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                top: 24,
                left: 24,
                right: 24,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: passFormKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Change Password',
                        style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 20),

                      // Current Password
                      Text(
                        'Current Password *',
                        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: currentPassController,
                        obscureText: obscureCurrent,
                        decoration: InputDecoration(
                          hintText: 'Enter current password',
                          filled: true,
                          fillColor: AppColors.surfaceContainerLow,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(obscureCurrent ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                            onPressed: () => setSheetState(() => obscureCurrent = !obscureCurrent),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Current password is required';
                          if (!UserDatabase.verifyCurrentPassword(value)) {
                            return 'Incorrect current password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // New Password
                      Text(
                        'New Password *',
                        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: newPassController,
                        obscureText: obscureNew,
                        onChanged: (_) => setSheetState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Minimum 8 characters',
                          filled: true,
                          fillColor: AppColors.surfaceContainerLow,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(obscureNew ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                            onPressed: () => setSheetState(() => obscureNew = !obscureNew),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'New password is required';
                          if (value.length < 8) return 'Password must be minimum 8 characters';
                          if (!RegExp(r'[A-Z]').hasMatch(value)) {
                            return 'Password must contain at least one uppercase letter';
                          }
                          if (!RegExp(r'[0-9]').hasMatch(value)) {
                            return 'Password must contain at least one number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      // Requirements indicator checks
                      Wrap(
                        spacing: 12,
                        children: [
                          _reqCheck(isLongEnough, '8+ chars'),
                          _reqCheck(hasUppercase, '1 Uppercase'),
                          _reqCheck(hasNumber, '1 Number'),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Confirm Password
                      Text(
                        'Confirm New Password *',
                        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: confirmPassController,
                        obscureText: obscureConfirm,
                        decoration: InputDecoration(
                          hintText: 'Repeat new password',
                          filled: true,
                          fillColor: AppColors.surfaceContainerLow,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                            onPressed: () => setSheetState(() => obscureConfirm = !obscureConfirm),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Please confirm your password';
                          if (value != newPassController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Action button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () {
                            if (passFormKey.currentState?.validate() ?? false) {
                              UserDatabase.updatePassword(newPassController.text);
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Password updated successfully!',
                                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                                  ),
                                  backgroundColor: AppColors.primary,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text('Update Password', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _reqCheck(bool valid, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          valid ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 14,
          color: valid ? AppColors.primary : AppColors.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: valid ? AppColors.primary : AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTech = UserDatabase.isTechAuthenticated;
    final name = isTech ? (UserDatabase.currentTechnician?['name'] ?? '') : (UserDatabase.currentUser?['fullName'] ?? 'Ahmed Ali');
    final email = isTech ? (UserDatabase.currentTechnician?['email'] ?? '') : (UserDatabase.currentUser?['email'] ?? 'ahmed@gmail.com');
    final phone = isTech ? (UserDatabase.currentTechnician?['phone'] ?? '') : (UserDatabase.currentUser?['phone'] ?? '0300-1234567');
    final address = isTech ? (UserDatabase.currentTechnician?['area'] ?? '') : (UserDatabase.currentUser?['address'] ?? 'House 12, Sector G-13');
    final city = isTech ? (UserDatabase.currentTechnician?['city'] ?? '') : (UserDatabase.currentUser?['city'] ?? 'Islamabad');
    final initials = _getUserInitials(name);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Text(
              'Profile',
              style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.onSurface),
            ),
            const Spacer(),
            if (!_isEditing)
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _isEditing = true;
                    _resetControllers();
                  });
                },
                icon: const Icon(Icons.edit, size: 16),
                label: Text('Edit Profile', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.surfaceVariant),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.primaryContainer,
                      child: Text(
                        initials,
                        style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      name,
                      style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.onBackground),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Details Card (View & Edit States)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.surfaceVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PERSONAL DETAILS',
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant, letterSpacing: 1.1),
                    ),
                    const SizedBox(height: 16),

                    if (!_isEditing) ...[
                      // View Mode Layout
                      _buildDetailRow(Icons.person_outline, 'Full Name', name),
                      _buildDetailRow(Icons.email_outlined, 'Email Address', email),
                      _buildDetailRow(
                        Icons.phone_outlined,
                        'Phone Number',
                        phone,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🇵🇰', style: TextStyle(fontSize: 16)),
                            const SizedBox(width: 4),
                            Text('+92', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
                          ],
                        ),
                      ),
                      _buildDetailRow(Icons.location_on_outlined, 'City', city),
                      _buildDetailRow(Icons.map_outlined, 'Complete Address', address),
                      _buildPasswordRow(),
                    ] else ...[
                      // Edit Mode Layout
                      _buildEditLabel('Full Name'),
                      TextFormField(
                        controller: _nameController,
                        style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500),
                        decoration: _buildEditInputDecoration(
                          hint: 'Full Name',
                          errorText: _nameTouched ? _validateName() : null,
                        ),
                        onChanged: (_) {
                          setState(() => _nameTouched = true);
                        },
                      ),
                      const SizedBox(height: 16),

                      _buildEditLabel('Email Address'),
                      TextFormField(
                        controller: _emailController,
                        style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500),
                        decoration: _buildEditInputDecoration(
                          hint: 'Email Address',
                          errorText: _emailTouched ? _validateEmail() : null,
                        ),
                        onChanged: (_) {
                          setState(() => _emailTouched = true);
                        },
                      ),
                      const SizedBox(height: 16),

                      _buildEditLabel('Phone Number'),
                      TextFormField(
                        controller: _phoneController,
                        style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500),
                        decoration: _buildEditInputDecoration(
                          hint: '03XX-XXXXXXX',
                          errorText: _phoneTouched ? _validatePhone() : null,
                        ),
                        onChanged: (_) {
                          setState(() => _phoneTouched = true);
                        },
                      ),
                      const SizedBox(height: 16),

                      _buildEditLabel('City'),
                      InkWell(
                        onTap: _showCitySelectSheet,
                        child: InputDecorator(
                          decoration: _buildEditInputDecoration(
                            hint: 'Select City',
                            errorText: null,
                          ),
                          child: Text(
                            _tempSelectedCity ?? 'Select City',
                            style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildEditLabel('Complete Address'),
                      TextFormField(
                        controller: _addressController,
                        maxLines: 2,
                        style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500),
                        decoration: _buildEditInputDecoration(
                          hint: 'Complete Address',
                          errorText: _addressTouched ? _validateAddress() : null,
                        ),
                        onChanged: (_) {
                          setState(() => _addressTouched = true);
                        },
                      ),
                      const SizedBox(height: 24),

                      // Cancel and Save actions
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  _isEditing = false;
                                  _resetControllers();
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.outlineVariant),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                minimumSize: const Size(0, 48),
                              ),
                              child: Text('Cancel', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.onSurface)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isEditsValid() ? _saveProfileChanges : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: AppColors.surfaceContainerHigh,
                                disabledForegroundColor: AppColors.onSurfaceVariant,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                minimumSize: const Size(0, 48),
                                elevation: 0,
                              ),
                              child: Text('Save Changes', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // About Section (from original screen)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.surfaceVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('About Khidmat AI', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurfaceVariant),
                        children: [
                          const TextSpan(text: 'Empowering connections through smart orchestration. Powered by advanced AI and integrated with '),
                          TextSpan(text: 'Google Antigravity', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppColors.primary)),
                          const TextSpan(text: ' technology for seamless service delivery.'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Log Out Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: TextButton.icon(
                  onPressed: () {
                    UserDatabase.logout();
                    UserDatabase.techLogout();
                    context.go('/');
                  },
                  icon: const Icon(Icons.logout, color: AppColors.error),
                  label: Text('Sign Out', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.error)),
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.errorContainer.withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String val, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: 2),
                Text(
                  val,
                  style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.onBackground),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildPasswordRow() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lock_outline, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Password',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: 2),
                Text(
                  '••••••••',
                  style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.onBackground),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _showChangePasswordSheet,
            child: Text(
              'Change Password',
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0, left: 2, top: 12),
      child: Text(
        label,
        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.onBackground),
      ),
    );
  }

  InputDecoration _buildEditInputDecoration({
    required String hint,
    required String? errorText,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurfaceVariant),
      errorText: errorText,
      errorStyle: GoogleFonts.inter(fontSize: 11, color: AppColors.error, fontWeight: FontWeight.w600),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
