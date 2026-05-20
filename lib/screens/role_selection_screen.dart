import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../data/user_database.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 32),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(),
                      // Sparkle icon
                      const Icon(Icons.auto_awesome, size: 32, color: AppColors.tertiaryFixedDim),
                      const SizedBox(height: 8),
                      Text(
                        'Join USTAAD',
                        style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.primary, letterSpacing: -0.52),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Choose how you want to use the platform',
                        style: GoogleFonts.inter(fontSize: 16, color: AppColors.onSurfaceVariant),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      // Customer Card
                      _RoleCard(
                        icon: Icons.home_repair_service,
                        iconBg: AppColors.primaryContainer,
                        iconColor: AppColors.onPrimaryContainer,
                        title: 'I Want a Service',
                        subtitle: 'Find verified professionals for your needs.',
                        onTap: () => context.go('/customer/welcome'),
                      ),
                      const SizedBox(height: 16),
                      // Provider Card
                      _RoleCard(
                        icon: Icons.build,
                        iconBg: AppColors.secondaryContainer,
                        iconColor: AppColors.onSecondaryContainer,
                        title: 'I Am a Service Provider',
                        subtitle: 'Offer your skills and earn on your schedule.',
                        onTap: () {
                          if (UserDatabase.isTechAuthenticated) {
                            context.go('/technician/home');
                          } else {
                            context.go('/technician/welcome');
                          }
                        },
                      ),
                      const Spacer(),
                      const SizedBox(height: 24),
                      // Login Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Already have an account? ', style: GoogleFonts.inter(fontSize: 16, color: AppColors.onSurfaceVariant)),
                          GestureDetector(
                            onTap: () => context.go('/customer/login'),
                            child: Text('Log In', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      
                      // Backend Admin Portal Link
                      GestureDetector(
                        onTap: () => context.go('/admin/login'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.blueGrey.shade50,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.blueGrey.shade100),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.admin_panel_settings, size: 16, color: Colors.blueGrey.shade800),
                              const SizedBox(width: 6),
                              Text(
                                'Login as Admin',
                                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.blueGrey.shade800),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.surfaceVariant),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(shape: BoxShape.circle, color: iconBg),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: GoogleFonts.inter(fontSize: 16, color: AppColors.onSurfaceVariant)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
