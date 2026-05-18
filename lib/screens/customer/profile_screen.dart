import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  static const _avatarUrl = 'https://lh3.googleusercontent.com/aida-public/AB6AXuAvYftedLPCJAs_RUUhjyQ4hyPqRfIgNtibPXAtILOlM6X-wwqViIJ1mU8sDcA57992Wa_ZJZEkONXlNQyzOWnerO2pxuOy8KHiygva1BepTsjcuaF5yfEIAhU_7oSEmVOlsuMz6XoJnbW_HzV-lmB6CEhW7uI3Hc1AiF73la1R79VKg-WBwc8DQCSxgbor-D35ZcuRNEkoJqNrguGS6-9q3DYwVni7trO9avClJVMMoDlhmwA3c8YzIXfXs1Z3wd94Vf2AkdtmCbQ';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(backgroundColor: AppColors.surface, surfaceTintColor: Colors.transparent, title: Row(children: [CircleAvatar(radius: 16, backgroundImage: NetworkImage(_avatarUrl)), const Spacer(), Text('Khidmat AI', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary)), const Spacer(), const Icon(Icons.location_on_outlined, color: AppColors.onSurfaceVariant)]), automaticallyImplyLeading: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          const SizedBox(height: 16),
          Stack(children: [CircleAvatar(radius: 48, backgroundImage: NetworkImage(_avatarUrl)), Positioned(bottom: 0, right: 0, child: Container(width: 24, height: 24, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.secondary), child: const Icon(Icons.check, size: 14, color: Colors.white)))]),
          const SizedBox(height: 12),
          Text('Ahmed', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700)),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.location_on_outlined, size: 16, color: AppColors.onSurfaceVariant), Text(' G-13, Islamabad', style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurfaceVariant))]),
          const SizedBox(height: 24),
          // Language
          _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [const Icon(Icons.language, size: 20, color: AppColors.primary), const SizedBox(width: 8), Text('Language Preference', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600))]),
            const SizedBox(height: 12),
            Wrap(spacing: 8, children: [_langChip('English', true), _langChip('Urdu', false), _langChip('Roman Urdu', false)]),
          ])),
          const SizedBox(height: 12),
          // Notifications
          _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [const Icon(Icons.notifications_outlined, size: 20, color: AppColors.primary), const SizedBox(width: 8), Text('Notifications', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600))]),
            const SizedBox(height: 12),
            _toggleRow('Push Alerts', true), _toggleRow('SMS Updates', false),
          ])),
          const SizedBox(height: 12),
          // Booking History
          _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [const Icon(Icons.history, size: 20, color: AppColors.primary), const SizedBox(width: 8), Text('Booking History', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600)), const Spacer(), Text('View All', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary))]),
            const SizedBox(height: 12),
            _historyItem(Icons.plumbing, AppColors.tertiaryFixedDim, 'Plumbing Service', 'Oct 24, 2023 • Completed'),
            const SizedBox(height: 8),
            _historyItem(Icons.home, AppColors.primary, 'Deep Cleaning', 'Sep 12, 2023 • Completed'),
          ])),
          const SizedBox(height: 12),
          // About
          _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('About Khidmat AI', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            RichText(text: TextSpan(style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurfaceVariant), children: [
              const TextSpan(text: 'Empowering connections through smart orchestration. Powered by advanced AI and integrated with '),
              TextSpan(text: 'Google Antigravity', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppColors.primary)),
              const TextSpan(text: ' technology for seamless service delivery.'),
            ])),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: () {}, style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.outlineVariant), minimumSize: const Size(0, 40)), child: Text('Learn More', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onSurface))),
          ])),
          const SizedBox(height: 24),
          TextButton.icon(onPressed: () => context.go('/'), icon: const Icon(Icons.logout, color: AppColors.error), label: Text('Sign Out', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.error)), style: TextButton.styleFrom(backgroundColor: AppColors.errorContainer.withValues(alpha: 0.3), padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)))),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }

  Widget _card(Widget child) => Container(width: double.infinity, padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: AppColors.surfaceContainerLowest, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.surfaceVariant)), child: child);
  Widget _langChip(String l, bool a) => Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), decoration: BoxDecoration(color: a ? AppColors.primary : AppColors.surfaceContainerLowest, borderRadius: BorderRadius.circular(9999), border: Border.all(color: a ? AppColors.primary : AppColors.outlineVariant)), child: Text(l, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: a ? Colors.white : AppColors.onSurface)));
  Widget _toggleRow(String l, bool v) => Padding(padding: const EdgeInsets.only(bottom: 4), child: Row(children: [Text(l, style: GoogleFonts.inter(fontSize: 16)), const Spacer(), Switch(value: v, onChanged: (_) {}, activeThumbColor: AppColors.primary)]));
  Widget _historyItem(IconData i, Color c, String t, String s) => Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(12)), child: Row(children: [Container(width: 36, height: 36, decoration: BoxDecoration(shape: BoxShape.circle, color: c.withValues(alpha: 0.2)), child: Icon(i, size: 18, color: c)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)), Text(s, style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant))])), const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant)]));
}
