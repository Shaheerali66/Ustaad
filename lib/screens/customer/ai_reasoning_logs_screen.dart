import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';

class AiReasoningLogsScreen extends StatelessWidget {
  const AiReasoningLogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()), title: Text('USTAAD', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary)), actions: [IconButton(icon: const Icon(Icons.location_on_outlined), onPressed: () {})]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Text('AI Reasoning Logs', style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w700)), const SizedBox(width: 8), const Icon(Icons.auto_awesome, color: AppColors.tertiaryFixedDim)]),
          Text('Orchestrated by Google Antigravity', style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.download), label: const Text('Export Log'), style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.outlineVariant)))),
          const SizedBox(height: 24),
          _logEntry(Icons.translate, AppColors.surfaceContainerLow, '08:30:00', 'User Intent Analyzed (Roman Urdu)', null, false),
          _logEntry(Icons.settings, AppColors.surfaceContainerLow, '08:30:02', 'Tool Call: Google Maps API (Query: G-13 Islamabad)', null, false),
          _logEntry(Icons.search, AppColors.surfaceContainerLow, '08:30:05', 'Searching Providers (Found 12 in 5km radius)', null, false),
          _logEntry(Icons.check_circle, AppColors.primaryContainer.withValues(alpha: 0.2), '08:30:10', 'Ranking: Ali AC Services selected as Best Match (Availability + Rating)',
            '{\n  "selected_provider": {\n    "id": "PRV-8492",\n    "name": "Ali AC Services",\n    "distance": "1.2 km",\n    "rating": 4.8,\n    "reviews": 124\n  },\n  "ranking_factors": {\n    "availability_score": 0.95,\n    "rating_weight": 0.88,\n    "distance_weight": 0.92\n  },\n  "decision_rationale":\n  "Highest combined score for evening availability and close proximity in G-13."\n}', true),
          const SizedBox(height: 40),
        ]),
      ),
    );
  }

  Widget _logEntry(IconData icon, Color iconBg, String time, String title, String? json, bool expanded) {
    return Padding(padding: const EdgeInsets.only(bottom: 16), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(width: 36, height: 36, decoration: BoxDecoration(shape: BoxShape.circle, color: iconBg), child: Icon(icon, size: 18, color: expanded ? AppColors.primary : AppColors.onSurfaceVariant)),
      const SizedBox(width: 12),
      Expanded(child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: expanded ? AppColors.surfaceContainerLow : AppColors.surfaceContainerLowest, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.surfaceVariant)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(time, style: GoogleFonts.inter(fontSize: 12, color: expanded ? AppColors.primary : AppColors.onSurfaceVariant)),
          const SizedBox(height: 4),
          Row(children: [Expanded(child: Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600))), Icon(expanded ? Icons.expand_less : Icons.expand_more, color: expanded ? AppColors.primary : AppColors.onSurfaceVariant)]),
          if (json != null) ...[const SizedBox(height: 12), Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.surfaceContainerLowest, borderRadius: BorderRadius.circular(8)), child: Text(json, style: const TextStyle(fontSize: 12, fontFamily: 'monospace', color: AppColors.onSurface)))],
        ]),
      )),
    ]));
  }
}
