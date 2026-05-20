import 'dart:async';
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
  int _activeStepIndex = 0;
  Timer? _stepTimer;
  final List<String> _timestamps = [];

  // 7 detailed agentic reasoning steps
  final List<String> _stepTitles = [
    'Parsing request intent',
    'Analyzing service category',
    'Location extraction and city isolation',
    'Schedule and timing parsing',
    'Cross-referencing work specifications',
    'Querying local technician registry',
    'AI matching optimization and ranking',
  ];

  @override
  void initState() {
    super.initState();
    
    // Generate simulated timestamps for steps
    final now = DateTime.now();
    for (int i = 0; i < 7; i++) {
      final time = now.add(Duration(milliseconds: i * 650));
      final minutesStr = time.minute.toString().padLeft(2, '0');
      final secondsStr = time.second.toString().padLeft(2, '0');
      final millisStr = (time.millisecond ~/ 10).toString().padLeft(2, '0');
      _timestamps.add('$minutesStr:$secondsStr.$millisStr');
    }

    // Step progression timer
    _stepTimer = Timer.periodic(const Duration(milliseconds: 650), (timer) {
      if (!mounted) return;
      if (_activeStepIndex < 6) {
        setState(() {
          _activeStepIndex++;
        });
      } else {
        _stepTimer?.cancel();
        // Complete processing and navigate to discovery
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            context.go('/customer/provider-discovery', extra: widget.bookingDetails);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _stepTimer?.cancel();
    super.dispose();
  }

  String _getCityName(String location) {
    final lower = location.toLowerCase();
    if (lower.contains('lahore') || lower.contains('lhr')) return 'Lahore';
    if (lower.contains('karachi') || lower.contains('khi')) return 'Karachi';
    if (lower.contains('hyderabad') || lower.contains('hyd')) return 'Hyderabad';
    return 'Islamabad';
  }

  @override
  Widget build(BuildContext context) {
    final isFreeText = widget.bookingDetails?['isFreeText'] ?? true;
    final service = widget.bookingDetails?['service'] ?? 'AC Services';
    final work = widget.bookingDetails?['work'] ?? 'AC servicing and repair';
    final location = widget.bookingDetails?['location'] ?? 'Sector G-13, Islamabad';
    final time = widget.bookingDetails?['time'] ?? 'Tomorrow Morning (~10:00 AM)';
    final date = widget.bookingDetails?['date'] ?? 'Tomorrow';

    final targetCity = _getCityName(location);

    // List of dynamic details to show under each step
    final List<String> stepSubtitles = [
      'Ingesting search string and extracting entities...',
      'Detected requirement: "$service"',
      'Strict filter isolated to: "$targetCity" (No cross-city matches allowed)',
      'Parsed execution date: $date, timing: $time',
      'Scanning problem description: "$work"',
      'Querying database for onboarded and verified professionals in $targetCity...',
      'Ranking by ratings, distance, and historical performance indexes...',
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
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
            Text('USTAAD Engine', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary)),
            const Spacer(),
            const Icon(Icons.auto_awesome, color: AppColors.primary),
          ],
        ),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Pipeline Pipeline Progress Visualization (Planning - Decision - Action - Follow-up)
              _buildPipelineProgress(),
              const SizedBox(height: 24),

              // AI thinking animation circle
              Center(
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 80, height: 80,
                          child: CircularProgressIndicator(
                            value: (_activeStepIndex + 1) / 7,
                            strokeWidth: 4,
                            backgroundColor: AppColors.surfaceContainerHigh,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                          ),
                        ),
                        Container(
                          width: 64, height: 64,
                          decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.surfaceContainerLowest),
                          child: const Icon(Icons.auto_awesome, size: 28, color: Colors.amber),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _activeStepIndex < 6 ? 'Analyzing & Matchmaking...' : 'Perfect Matches Found!',
                      style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.onBackground),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'AI Orchestrator is running high-fidelity decision loops',
                      style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // request summary card (Conditional based on entry point)
              _buildRequestSummaryCard(isFreeText, service, location, date, time, work),
              const SizedBox(height: 20),

              // Step-by-Step Reasoning Trace (Animated)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.surfaceVariant),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.insights, size: 20, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Agentic Reasoning Trace',
                          style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.onBackground),
                        ),
                      ],
                    ),
                    const Divider(height: 24, color: AppColors.surfaceVariant),
                    
                    // Steps loop
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 7,
                      itemBuilder: (context, index) {
                        final isCompleted = index < _activeStepIndex;
                        final isActive = index == _activeStepIndex;
                        final isPending = index > _activeStepIndex;

                        Color indicatorColor = AppColors.surfaceContainerHigh;
                        Widget indicatorIcon = const SizedBox(width: 8, height: 8);

                        if (isCompleted) {
                          indicatorColor = Colors.teal.shade50;
                          indicatorIcon = const Icon(Icons.check, size: 12, color: Colors.teal);
                        } else if (isActive) {
                          indicatorColor = AppColors.primaryContainer;
                          indicatorIcon = const SizedBox(
                            width: 12, height: 12,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                          );
                        } else {
                          indicatorColor = AppColors.surfaceContainerLow;
                          indicatorIcon = Icon(Icons.circle, size: 6, color: AppColors.onSurfaceVariant.withOpacity(0.3));
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Timestamp
                              SizedBox(
                                width: 55,
                                child: Text(
                                  _timestamps[index],
                                  style: GoogleFonts.robotoMono(
                                    fontSize: 11,
                                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                                    color: isActive 
                                        ? AppColors.primary 
                                        : isCompleted 
                                            ? AppColors.onSurfaceVariant.withOpacity(0.6) 
                                            : AppColors.onSurfaceVariant.withOpacity(0.3),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              
                              // Indicator bullet
                              Container(
                                width: 22, height: 22,
                                decoration: BoxDecoration(
                                  color: indicatorColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isActive ? AppColors.primary : Colors.transparent,
                                    width: 1,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: indicatorIcon,
                              ),
                              const SizedBox(width: 12),

                              // Text details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _stepTitles[index],
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                                        color: isActive 
                                            ? AppColors.primary 
                                            : isCompleted 
                                                ? AppColors.onSurface 
                                                : AppColors.onSurfaceVariant.withOpacity(0.4),
                                      ),
                                    ),
                                    if (!isPending) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        stepSubtitles[index],
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: isActive 
                                              ? AppColors.onSurfaceVariant 
                                              : AppColors.onSurfaceVariant.withOpacity(0.7),
                                        ),
                                      ),
                                    ]
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Cancel button
              OutlinedButton(
                onPressed: () {
                  _stepTimer?.cancel();
                  context.go('/customer/home');
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.outlineVariant),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  foregroundColor: AppColors.onSurface,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text('Cancel AI Routine', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPipelineProgress() {
    // Current state mappings
    int activeIdx = 0; // 0 = Planning, 1 = Decision, 2 = Action, 3 = Follow-up
    if (_activeStepIndex >= 2 && _activeStepIndex < 5) {
      activeIdx = 1; // Decision State
    } else if (_activeStepIndex >= 5) {
      activeIdx = 2; // Action State
    }

    final phases = ['Planning', 'Decision', 'Action', 'Follow-up'];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(phases.length, (idx) {
          final title = phases[idx];
          final isDone = idx < activeIdx;
          final isCurrent = idx == activeIdx;

          Color txtColor = AppColors.onSurfaceVariant.withOpacity(0.4);
          Color bulletColor = AppColors.surfaceContainerHigh;
          if (isDone) {
            txtColor = Colors.teal;
            bulletColor = Colors.teal;
          } else if (isCurrent) {
            txtColor = AppColors.primary;
            bulletColor = AppColors.primary;
          }

          return Row(
            children: [
              Container(
                width: 8, height: 8,
                decoration: BoxDecoration(color: bulletColor, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: isCurrent || isDone ? FontWeight.w700 : FontWeight.w500,
                  color: txtColor,
                ),
              ),
              if (idx < phases.length - 1) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right,
                  size: 14,
                  color: AppColors.onSurfaceVariant.withOpacity(0.3),
                ),
                const SizedBox(width: 8),
              ]
            ],
          );
        }),
      ),
    );
  }

  Widget _buildRequestSummaryCard(
    bool isFreeText,
    String service,
    String location,
    String date,
    String time,
    String work,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
              Icon(
                isFreeText ? Icons.chat_bubble_outline : Icons.assignment_outlined,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                isFreeText ? 'YOUR VERIFIED REQUEST' : 'FORM DETAILS SUMMARY',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (isFreeText)
            Text(
              '"$work"',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
                height: 1.4,
              ),
            )
          else ...[
            _summaryItem(Icons.category_outlined, 'Service', service),
            _summaryItem(Icons.location_on_outlined, 'Location', location),
            _summaryItem(Icons.calendar_today_outlined, 'Schedule', '$date ($time)'),
            if (work.isNotEmpty && work != '$service service requested')
              _summaryItem(Icons.description_outlined, 'Details', work),
          ],
        ],
      ),
    );
  }

  Widget _summaryItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: AppColors.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}
