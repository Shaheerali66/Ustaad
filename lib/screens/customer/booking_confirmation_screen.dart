import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';

class BookingConfirmationScreen extends StatelessWidget {
  const BookingConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            const SizedBox(height: 40),
            Container(width: 80, height: 80, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.secondaryContainer.withValues(alpha: 0.3)), child: const Icon(Icons.check_circle, size: 48, color: AppColors.secondary)),
            const SizedBox(height: 16),
            Text('Booking Confirmed!', style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.secondary)),
            const SizedBox(height: 8),
            Text('Booking logged to system — Provider notified', style: GoogleFonts.inter(fontSize: 16, color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 24),
            // AI Orchestration
            Container(
              width: double.infinity, padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppColors.surfaceContainerLowest, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.surfaceVariant)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('AI Orchestration', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                _step('Assigning provider', 'Done'), _step('Scheduling slot', 'Done', sub: '10:00 AM Tomorrow'), _step('Creating booking record', 'Done'), _step('Sending confirmation', 'Done'),
              ]),
            ),
            const SizedBox(height: 16),
            // Receipt
            Container(
              width: double.infinity, padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.primary, width: 2)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('RECEIPT ID', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.onSurfaceVariant, letterSpacing: 1)),
                    Text('#KAI-20240517-001', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700)),
                  ]),
                  const Spacer(),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: AppColors.secondaryContainer.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(9999)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.secondary)), const SizedBox(width: 6), Text('CONFIRMED', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.secondary))])),
                ]),
                const SizedBox(height: 16),
                _infoRow(Icons.ac_unit, 'Service', 'AC Technician', AppColors.primary),
                const SizedBox(height: 12),
                _infoRow(Icons.circle, 'Provider', 'Ali AC Services', AppColors.tertiary, trailing: '★ 4.8'),
                const SizedBox(height: 12),
                _infoRow(Icons.access_time, 'Time', 'Tomorrow, 10:00 AM', AppColors.onSurfaceVariant),
              ]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(onPressed: () => context.go('/customer/bookings'), icon: const Icon(Icons.event_note), label: Text('View My Bookings', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600))),
            const SizedBox(height: 12),
            OutlinedButton.icon(onPressed: () => context.go('/customer/home'), icon: const Icon(Icons.home, color: AppColors.primary), label: Text('Back to Home', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primary)), style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.primary))),
            const SizedBox(height: 24),
          ]),
        ),
      ),
    );
  }

  Widget _step(String title, String status, {String? sub}) {
    return Padding(padding: const EdgeInsets.only(bottom: 16), child: Row(children: [
      const Icon(Icons.check_circle, size: 24, color: AppColors.secondary),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
        if (sub != null) Text(sub, style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant)),
      ])),
      Text(status, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.secondary)),
    ]));
  }

  Widget _infoRow(IconData icon, String label, String value, Color iconColor, {String? trailing}) {
    return Row(children: [
      Container(width: 40, height: 40, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.surfaceContainerHigh), child: Icon(icon, size: 20, color: iconColor)),
      const SizedBox(width: 12),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant)),
        Text(value, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
      ]),
      if (trailing != null) ...[const Spacer(), Text(trailing, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.tertiaryFixedDim))],
    ]);
  }
}
