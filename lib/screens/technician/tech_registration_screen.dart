import 'package:flutter/material.dart';
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
  final TextEditingController _cnicController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  void _handleContinue() {
    if (_formKey.currentState!.validate()) {
      DocumentDatabase.currentName = _nameController.text.trim();
      DocumentDatabase.currentCnic = _cnicController.text.trim();
      DocumentDatabase.currentPhone = _phoneController.text.trim();
      context.go('/technician/service-info');
    } else {
      // Show snackbar notifying form errors
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.white),
            const SizedBox(width: 8),
            Text('Please fill out all personal details first!', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ]),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cnicController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                        Text('Full Name', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.onSurface)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(hintText: 'e.g. Ahmed Khan'),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your full name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        Text('CNIC Number', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.onSurface)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _cnicController,
                          decoration: const InputDecoration(hintText: 'e.g. 35201-1234567-9'),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your CNIC number';
                            }
                            if (value.trim().length < 13) {
                              return 'Please enter a valid CNIC';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        Text('Phone Number', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.onSurface)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _phoneController,
                          decoration: const InputDecoration(hintText: 'e.g. 0300 1234567'),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your phone number';
                            }
                            if (value.trim().length < 10) {
                              return 'Please enter a valid mobile number';
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
                        style: ElevatedButton.styleFrom(minimumSize: const Size(140, 52)),
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
