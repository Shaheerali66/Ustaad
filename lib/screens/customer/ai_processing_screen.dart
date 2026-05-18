import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';

class AiProcessingScreen extends StatefulWidget {
  final Map<String, dynamic>? bookingDetails;

  const AiProcessingScreen({super.key, this.bookingDetails});

  @override
  State<AiProcessingScreen> createState() => _AiProcessingScreenState();
}

class _AiProcessingScreenState extends State<AiProcessingScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        context.go('/customer/provider-discovery', extra: widget.bookingDetails);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Read passed fields or fallback to default
    final service = widget.bookingDetails?['service'] ?? 'AC Services';
    final work = widget.bookingDetails?['work'] ?? 'AC servicing and repair';
    final location = widget.bookingDetails?['location'] ?? 'Sector G-13, Islamabad';
    final time = widget.bookingDetails?['time'] ?? 'Tomorrow Morning (~10:00 AM)';

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: const NetworkImage(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuAvYftedLPCJAs_RUUhjyQ4hyPqRfIgNtibPXAtILOlM6X-wwqViIJ1mU8sDcA57992Wa_ZJZEkONXlNQyzOWnerO2pxuOy8KHiygva1BepTsjcuaF5yfEIAhU_7oSEmVOlsuMz6XoJnbW_HzV-lmB6CEhW7uI3Hc1AiF73la1R79VKg-WBwc8DQCSxgbor-D35ZcuRNEkoJqNrguGS6-9q3DYwVni7trO9avClJVMMoDlhmwA3c8YzIXfXs1Z3wd94Vf2AkdtmCbQ'
              ),
            ),
            const Spacer(),
            Text('Khidmat AI', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary)),
            const Spacer(),
            const Icon(Icons.location_on_outlined, color: AppColors.onSurfaceVariant),
          ],
        ),
        automaticallyImplyLeading: false,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight - 32),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: const LinearProgressIndicator(
                        value: 0.7,
                        minHeight: 4,
                        backgroundColor: AppColors.surfaceVariant,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // AI thinking icon
                    Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.surfaceContainerLow),
                      child: const Icon(Icons.auto_awesome, size: 36, color: AppColors.tertiaryFixedDim),
                    ),
                    const SizedBox(height: 24),
                    Text('AI is thinking...', style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.onBackground)),
                    const SizedBox(height: 8),
                    Text('Orchestrating the perfect service match\nfor your needs.', style: GoogleFonts.inter(fontSize: 16, color: AppColors.onSurfaceVariant), textAlign: TextAlign.center),
                    const SizedBox(height: 32),
                    
                    // Your Request card displaying dynamic inputs
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.surfaceVariant),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.record_voice_over, size: 18, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Text('YOUR VERIFIED REQUEST', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary, letterSpacing: 0.5)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text('"$work"', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Live Process steps displaying dynamic inputs
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.surfaceVariant),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Live Process', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
                          const SizedBox(height: 16),
                          _processStep(Icons.check_circle, AppColors.secondaryContainer, 'Understanding your request...', null, true),
                          _processStep(Icons.check_circle, AppColors.secondaryContainer, 'Detecting service type:', service, true),
                          _processStep(Icons.check_circle, AppColors.secondaryContainer, 'Extracting location:', location, true),
                          _processStep(Icons.check_circle, AppColors.secondaryContainer, 'Extracting time:', time, true),
                          _processStep(Icons.sync, AppColors.primary, 'Searching nearby providers...', 'Querying Excel technician database...', false),
                          _processStep(Icons.more_horiz, AppColors.surfaceDim, 'Ranking by experience, rating, and availability...', null, false),
                        ],
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(height: 24),
                    // Cancel button
                    OutlinedButton(
                      onPressed: () => context.go('/customer/home'),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.outlineVariant),
                        foregroundColor: AppColors.onSurface,
                      ),
                      child: Text('Cancel Request', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _processStep(IconData icon, Color iconColor, String title, String? subtitle, bool done) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: done ? AppColors.secondary : iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: done ? AppColors.onSurface : AppColors.primary)),
                if (subtitle != null)
                  Text(subtitle, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: done ? AppColors.secondary : AppColors.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
