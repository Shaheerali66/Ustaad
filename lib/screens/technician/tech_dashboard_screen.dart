import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../data/booking_state.dart';
import '../../data/user_database.dart';

class TechDashboardScreen extends StatefulWidget {
  const TechDashboardScreen({super.key});

  @override
  State<TechDashboardScreen> createState() => _TechDashboardScreenState();
}

class _TechDashboardScreenState extends State<TechDashboardScreen> {
  bool _isOnline = true;
  bool get _jobStarted => BookingState.jobStarted;
  set _jobStarted(bool val) => BookingState.jobStarted = val;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface, surfaceTintColor: Colors.transparent, automaticallyImplyLeading: false,
        title: Row(children: [
          const CircleAvatar(radius: 16, backgroundImage: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuAvYftedLPCJAs_RUUhjyQ4hyPqRfIgNtibPXAtILOlM6X-wwqViIJ1mU8sDcA57992Wa_ZJZEkONXlNQyzOWnerO2pxuOy8KHiygva1BepTsjcuaF5yfEIAhU_7oSEmVOlsuMz6XoJnbW_HzV-lmB6CEhW7uI3Hc1AiF73la1R79VKg-WBwc8DQCSxgbor-D35ZcuRNEkoJqNrguGS6-9q3DYwVni7trO9avClJVMMoDlhmwA3c8YzIXfXs1Z3wd94Vf2AkdtmCbQ')),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(UserDatabase.currentTechnician?['name'] ?? 'Service Provider', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
            Row(children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: _isOnline ? AppColors.secondary : AppColors.onSurfaceVariant)),
              const SizedBox(width: 4),
              Text(_isOnline ? 'Technician' : 'Offline', style: GoogleFonts.inter(fontSize: 12, color: _isOnline ? AppColors.secondary : AppColors.onSurfaceVariant)),
            ]),
          ]),
          const Spacer(),
          // Working Online/Offline toggle
          GestureDetector(
            onTap: () {
              setState(() => _isOnline = !_isOnline);
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(children: [
                    Icon(_isOnline ? Icons.wifi : Icons.wifi_off, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      _isOnline ? 'You are now Online — Ready to receive jobs' : 'You are now Offline — No new jobs will be assigned',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                    ),
                  ]),
                  backgroundColor: _isOnline ? AppColors.secondary : AppColors.onSurfaceVariant,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _isOnline ? AppColors.surfaceContainerLow : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(9999),
                border: Border.all(color: _isOnline ? AppColors.secondary.withValues(alpha: 0.3) : AppColors.outlineVariant),
              ),
              child: Row(children: [
                Text(_isOnline ? 'Online' : 'Offline', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: _isOnline ? AppColors.onSurface : AppColors.onSurfaceVariant)),
                const SizedBox(width: 8),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 44, height: 24,
                  decoration: BoxDecoration(
                    color: _isOnline ? AppColors.secondary : AppColors.outlineVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 300),
                    alignment: _isOnline ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      width: 20, height: 20,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ]),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Offline banner
          if (!_isOnline)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: Row(children: [
                const Icon(Icons.info_outline, color: AppColors.onSurfaceVariant),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('You are Offline', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
                  Text('Toggle Online to start receiving job requests.', style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurfaceVariant)),
                ])),
              ]),
            ),
          // Earnings
          Container(
            width: double.infinity, padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.surfaceVariant)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Earnings This Week', style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurfaceVariant)),
              const SizedBox(height: 4),
              Text('Rs. 15,450', style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
              Row(children: [const Icon(Icons.trending_up, size: 16, color: AppColors.secondary), const SizedBox(width: 4), Text('+12% from last week', style: GoogleFonts.inter(fontSize: 14, color: AppColors.secondary))]),
            ]),
          ),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _statCard('Total Jobs', '142', Icons.build)),
            const SizedBox(width: 12),
            Expanded(child: _statCard('Rating', '4.8 / 5.0', Icons.star_outline)),
          ]),
          const SizedBox(height: 24),
          Text('Active Booking', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          // Active booking card
          Container(
            width: double.infinity, padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.surfaceContainerLowest, borderRadius: BorderRadius.circular(16), border: Border.all(color: _jobStarted ? AppColors.secondary.withValues(alpha: 0.3) : AppColors.primary.withValues(alpha: 0.3))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(width: 40, height: 40, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.surfaceContainerLow), child: const Icon(Icons.plumbing, size: 20, color: AppColors.primary)),
                const SizedBox(width: 12),
                _statusBadge(_jobStarted ? 'On The Way' : 'In Progress', _jobStarted ? AppColors.tertiary : AppColors.secondary),
                const Spacer(),
                _infoBadge('✨ Matched via AI'),
              ]),
              const SizedBox(height: 12),
              Text('Emergency Plumbing Repair', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600)),
              Text('House 42, Street 10, DHA Phase 5', style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurfaceVariant)),
              const SizedBox(height: 4),
              Text('Client: Sara Ahmed • 2.5 km away', style: GoogleFonts.inter(fontSize: 14, color: AppColors.primary)),

              if (_jobStarted) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.secondaryContainer.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                  child: Row(children: [
                    const Icon(Icons.check_circle, size: 18, color: AppColors.secondary),
                    const SizedBox(width: 8),
                    Expanded(child: Text('Customer notified — Sara knows you\'re on your way!', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.secondary))),
                  ]),
                ),
              ],

              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: OutlinedButton.icon(
                  onPressed: () => context.push('/technician/navigation'),
                  icon: const Icon(Icons.navigation, size: 18),
                  label: const Text('Navigate'),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.primary), minimumSize: const Size(0, 44)),
                )),
                const SizedBox(width: 12),
                Expanded(child: ElevatedButton(
                  onPressed: _jobStarted ? null : () => _handleStartJob(),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 44),
                    backgroundColor: _jobStarted ? AppColors.surfaceVariant : AppColors.primary,
                    foregroundColor: _jobStarted ? AppColors.onSurfaceVariant : Colors.white,
                  ),
                  child: Text(_jobStarted ? 'Job Started ✓' : 'Start Job'),
                )),
              ]),
            ]),
          ),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Available Jobs Near You', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600)), Text('View All', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary))]),
          const SizedBox(height: 12),
          if (_isOnline) ...[
            _jobCard('AC Installation (1.5 Ton)', 'Gulberg III, Lahore', 'Rs. 2500', '1.2 km', true),
            const SizedBox(height: 8),
            _jobCard('Geyser Thermostat Repair', 'Johar Town, Lahore', 'Rs. 1200', '3.8 km', false),
          ] else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: AppColors.surfaceContainerLowest, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.surfaceVariant)),
              child: Column(children: [
                const Icon(Icons.wifi_off, size: 40, color: AppColors.onSurfaceVariant),
                const SizedBox(height: 8),
                Text('Go Online to see available jobs', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
              ]),
            ),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }

  void _handleStartJob() {
    setState(() => _jobStarted = true);
    // Show notification dialog
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.all(32),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.secondaryContainer.withValues(alpha: 0.3)),
              child: const Icon(Icons.notifications_active, size: 36, color: AppColors.secondary),
            ),
            const SizedBox(height: 16),
            Text('Notification Sent! 🎉', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.secondary)),
            const SizedBox(height: 8),
            Text(
              'Sara Ahmed has been notified that you have accepted the job and are on your way.',
              style: GoogleFonts.inter(fontSize: 15, color: AppColors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(12)),
              child: Column(children: [
                Row(children: [const Icon(Icons.chat, size: 16, color: AppColors.primary), const SizedBox(width: 8), Expanded(child: Text('WhatsApp notification sent ✓', style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurface)))]),
                const SizedBox(height: 6),
                Row(children: [const Icon(Icons.sms, size: 16, color: AppColors.primary), const SizedBox(width: 8), Expanded(child: Text('SMS notification sent ✓', style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurface)))]),
                const SizedBox(height: 6),
                Row(children: [const Icon(Icons.phone_android, size: 16, color: AppColors.primary), const SizedBox(width: 8), Expanded(child: Text('Push notification sent ✓', style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurface)))]),
              ]),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(minimumSize: const Size(0, 48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: Text('Got it!', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: AppColors.surfaceContainerLowest, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.surfaceVariant)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Icon(icon, size: 18, color: AppColors.onSurfaceVariant), const SizedBox(width: 8), Text(label, style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurfaceVariant))]),
      const SizedBox(height: 8),
      Text(value, style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700)),
    ]),
  );

  Widget _statusBadge(String t, Color c) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(9999)), child: Text(t, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)));
  Widget _infoBadge(String t) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(9999)), child: Text(t, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)));

  Widget _jobCard(String title, String loc, String price, String dist, bool isNew) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: AppColors.surfaceContainerLowest, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.surfaceVariant)),
    child: Row(children: [
      Container(width: 40, height: 40, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.surfaceContainerLow), child: const Icon(Icons.electrical_services, size: 20, color: AppColors.onSurfaceVariant)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
        Text(loc, style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant)),
        Row(children: [if (isNew) Container(margin: const EdgeInsets.only(right: 8), padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: AppColors.secondaryContainer, borderRadius: BorderRadius.circular(9999)), child: Text('New', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.onSecondaryContainer))), const Icon(Icons.location_on_outlined, size: 14, color: AppColors.onSurfaceVariant), Text(' $dist', style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant))]),
      ])),
      Column(children: [
        Text(price, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary)),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Row(children: [const Icon(Icons.check_circle, color: Colors.white, size: 20), const SizedBox(width: 8), Text('Job accepted! Customer notified.', style: GoogleFonts.inter(fontWeight: FontWeight.w600))]),
              backgroundColor: AppColors.secondary, behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ));
          },
          child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(color: AppColors.secondaryContainer, borderRadius: BorderRadius.circular(9999)), child: Text('Accept', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.onSecondaryContainer))),
        ),
      ]),
    ]),
  );
}
