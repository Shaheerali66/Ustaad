import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../data/bookings_repository.dart';

class ProviderDetailsScreen extends StatelessWidget {
  final Map<String, dynamic>? technician;
  
  const ProviderDetailsScreen({
    super.key,
    this.technician,
  });

  @override
  Widget build(BuildContext context) {
    // Crash-proof property mapping
    final name = (technician?['name'] ?? 'Professional Provider').toString();
    final category = (technician?['category'] ?? 'Home Services').toString();
    final subService = (technician?['subService'] ?? 'General Service').toString();
    final phone = (technician?['phone'] ?? '+92 300 0000000').toString();
    final city = (technician?['city'] ?? 'Islamabad').toString();
    final area = (technician?['area'] ?? 'Sector G-13').toString();
    final description = (technician?['description'] ?? 'Expert service professional dedicated to high quality craftsmanship and reliable results.').toString();
    final languages = (technician?['languages'] ?? 'Urdu, English').toString();
    final availability = (technician?['availability'] ?? 'Available').toString();
    final gender = (technician?['gender'] ?? 'Male').toString();

    final rating = double.tryParse(technician?['rating']?.toString() ?? '') ?? 4.5;
    final experience = int.tryParse(technician?['experience']?.toString() ?? '') ?? 3;
    final completedJobs = int.tryParse(technician?['completedJobs']?.toString() ?? '') ?? 10;
    final hourlyRate = int.tryParse(technician?['hourlyRate']?.toString() ?? '') ?? 1200;

    final isCnicVerified = technician?['cnicVerified']?.toString() == 'Yes';
    final isBgVerified = technician?['bgVerified']?.toString() == 'Yes';
    final isEmergency = technician?['emergencyService']?.toString() == 'Yes';
    final isAvailable = availability == 'Available';

    // Generate initials for avatar fallback (extremely crash-proof)
    String initials = 'W';
    if (name.trim().isNotEmpty) {
      final parts = name.trim().split(RegExp(r'\s+'));
      if (parts.isNotEmpty) {
        final firstChar = parts.first.isNotEmpty ? parts.first[0] : '';
        final secondChar = (parts.length > 1 && parts[1].isNotEmpty) ? parts[1][0] : '';
        initials = (firstChar + secondChar).toUpperCase();
      }
    }
    if (initials.isEmpty) {
      initials = 'W';
    }

    // Dynamic premium avatar color depending on name length
    final avatarColor = Colors.primaries[name.length % Colors.primaries.length].shade400;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.only(left: 12, top: 8, bottom: 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, size: 20, color: AppColors.onSurface),
            onPressed: () => context.pop(),
          ),
        ),
        title: Text(
          'Provider Profile',
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.onSurface),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.share, size: 20, color: AppColors.onSurface),
              onPressed: () {},
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Profile Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Row(
                children: [
                  Hero(
                    tag: 'provider_avatar_${technician?['id'] ?? name}',
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: avatarColor.withValues(alpha: 0.15),
                      backgroundImage: (technician != null && technician!['profilePhoto'] != null)
                          ? MemoryImage(base64Decode(technician!['profilePhoto'].split(',').last))
                          : null,
                      child: (technician == null || technician!['profilePhoto'] == null)
                          ? Text(
                              initials,
                              style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w800, color: avatarColor),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.onSurface),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subService,
                          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 14, color: AppColors.onSurfaceVariant),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '$area, $city',
                                style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w500),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Statistics Grid (Rating, Experience, Jobs, Hourly Rate)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _metricTile(Icons.star, 'RATING', '$rating', Colors.amber),
                  const SizedBox(width: 10),
                  _metricTile(Icons.work_history, 'EXPERIENCE', '$experience yrs', Colors.blue.shade600),
                  const SizedBox(width: 10),
                  _metricTile(Icons.task_alt, 'COMPLETED', '$completedJobs', Colors.green.shade600),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Secondary Details (Hourly Rate & Availability & Language)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.surfaceVariant),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('HOURLY RATE', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant, letterSpacing: 0.5)),
                          const SizedBox(height: 4),
                          Text('Rs. $hourlyRate / hr', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.primary)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.surfaceVariant),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('AVAILABILITY', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant, letterSpacing: 0.5)),
                          const SizedBox(height: 4),
                          Text(
                            availability,
                            style: GoogleFonts.inter(
                              fontSize: 15, 
                              fontWeight: FontWeight.w800, 
                              color: isAvailable ? Colors.green.shade700 : Colors.red.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Bio & Details Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About Provider',
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.onSurface),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.surfaceVariant),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.format_quote, size: 24, color: AppColors.outlineVariant),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurfaceVariant, height: 1.5),
                        ),
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.translate, size: 16, color: AppColors.onSurfaceVariant),
                            const SizedBox(width: 8),
                            Text(
                              'Languages: ',
                              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant),
                            ),
                            Text(
                              languages,
                              style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurface, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Trust & Verification Status
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Trust & Verification',
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.onSurface),
                  ),
                  const SizedBox(height: 10),
                  _verificationRow('CNIC Verification', isCnicVerified),
                  const SizedBox(height: 8),
                  _verificationRow('Background Check Clear', isBgVerified),
                  const SizedBox(height: 8),
                  _verificationRow('24/7 Emergency Service Support', isEmergency),
                ],
              ),
            ),

            const SizedBox(height: 120),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            )
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.chat_bubble_outline, size: 18),
                  label: const Text('Chat'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    side: const BorderSide(color: AppColors.outlineVariant),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    IconData catIcon = Icons.build;
                    final catLower = category.toLowerCase();
                    if (catLower.contains('ac')) {
                      catIcon = Icons.hvac;
                    } else if (catLower.contains('plumb')) {
                      catIcon = Icons.plumbing;
                    } else if (catLower.contains('elect')) {
                      catIcon = Icons.electrical_services;
                    } else if (catLower.contains('paint')) {
                      catIcon = Icons.format_paint;
                    } else if (catLower.contains('clean')) {
                      catIcon = Icons.cleaning_services;
                    }

                    BookingsRepository.addBooking(
                      BookingData(
                        title: category,
                        provider: 'Provider: $name',
                        date: 'Tomorrow, 10:00 AM',
                        status: 'Confirmed',
                        statusColor: AppColors.primary,
                        action: 'Track',
                        icon: catIcon,
                      ),
                    );

                    context.go('/customer/bookings');
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    'Book Now',
                    style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metricTile(IconData icon, String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.surfaceVariant),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.onSurface),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant, letterSpacing: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _verificationRow(String label, bool verified) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onSurface),
          ),
          Row(
            children: [
              Text(
                verified ? 'Verified' : 'Not Applicable',
                style: GoogleFonts.inter(
                  fontSize: 12, 
                  fontWeight: FontWeight.w700, 
                  color: verified ? Colors.teal.shade700 : AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                verified ? Icons.check_circle : Icons.info_outline, 
                size: 18, 
                color: verified ? Colors.teal.shade700 : AppColors.onSurfaceVariant,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
