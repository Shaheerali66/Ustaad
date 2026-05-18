import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';

class TechPerformanceScreen extends StatelessWidget {
  const TechPerformanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop()),
        title: Text('Khidmat AI', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary)),
        actions: [IconButton(icon: const Icon(Icons.location_on_outlined), onPressed: () {})],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text('My Performance Insights', style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w700))),
            const Icon(Icons.auto_awesome, color: AppColors.tertiaryFixedDim),
          ]),
          Text('Insights to help you grow your business', style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.download), label: const Text('Download Report'), style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.outlineVariant), minimumSize: const Size(0, 48)))),
          const SizedBox(height: 24),
          // Timeline entries
          _logEntry(Icons.handshake, AppColors.surfaceContainerLow, '08:30:00', 'Customer Match Found', null, false),
          _logEntry(Icons.route, AppColors.surfaceContainerLow, '08:30:02', 'Route Optimized', null, false),
          _logEntry(Icons.settings, AppColors.primaryContainer.withValues(alpha: 0.2), '08:30:10', 'Performance Breakdown',
            'Your Rating: 4.8\nResponse Speed: Very Fast\nDistance from Customer: 1.2 km\nWhy you were selected: High rating and close proximity.', true),
          const SizedBox(height: 40),
        ]),
      ),
    );
  }

  Widget _logEntry(IconData icon, Color iconBg, String time, String title, String? details, bool expanded) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 36, height: 36, decoration: BoxDecoration(shape: BoxShape.circle, color: iconBg), child: Icon(icon, size: 18, color: expanded ? AppColors.primary : AppColors.onSurfaceVariant)),
        const SizedBox(width: 12),
        Expanded(child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: expanded ? AppColors.surfaceContainerLow : AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
            border: expanded ? Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 2) : Border.all(color: AppColors.surfaceVariant),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(time, style: GoogleFonts.inter(fontSize: 12, color: expanded ? AppColors.primary : AppColors.onSurfaceVariant)),
            const SizedBox(height: 4),
            Row(children: [Expanded(child: Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600))), Icon(expanded ? Icons.expand_less : Icons.expand_more, color: expanded ? AppColors.primary : AppColors.onSurfaceVariant)]),
            if (details != null) ...[
              const SizedBox(height: 12),
              ...details.split('\n').map((line) {
                final parts = line.split(': ');
                if (parts.length == 2) {
                  return Padding(padding: const EdgeInsets.only(bottom: 4), child: Row(children: [
                    Text('${parts[0]}: ', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700)),
                    Expanded(child: Text(parts[1], style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurface))),
                  ]));
                }
                return Padding(padding: const EdgeInsets.only(bottom: 4), child: Text(line, style: GoogleFonts.inter(fontSize: 14)));
              }),
            ],
          ]),
        )),
      ]),
    );
  }
}
