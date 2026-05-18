import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';

class RequestSummaryScreen extends StatefulWidget {
  final String? queryText;

  const RequestSummaryScreen({super.key, this.queryText});

  @override
  State<RequestSummaryScreen> createState() => _RequestSummaryScreenState();
}

class _RequestSummaryScreenState extends State<RequestSummaryScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _workController;
  late TextEditingController _locationController;
  late TextEditingController _timeController;
  String? _selectedCategory;

  final List<String> _categories = [
    'AC Services',
    'Refrigerator Services',
    'Washing Machine Services',
    'Electrician',
    'Plumber',
    'Carpenter',
    'Cleaning Services',
    'Pest Control',
    'Beauty Services',
    'Healthcare',
    'Moving Services',
    'Automotive',
    'Digital Services',
    'Event Services',
    'Security Services',
    'Tutoring',
    'Gardening',
  ];

  @override
  void initState() {
    super.initState();
    
    // Auto detect from query text
    final parsed = _parseQuery(widget.queryText);
    
    _selectedCategory = parsed['service'];
    _workController = TextEditingController(text: widget.queryText ?? 'AC servicing and cleaning required');
    _locationController = TextEditingController(text: parsed['location']);
    _timeController = TextEditingController(text: parsed['time']);

    // Real-time listener to sync location when user edits Actual Work Details
    _workController.addListener(_syncLocationFromWorkQuery);
  }

  void _syncLocationFromWorkQuery() {
    final text = _workController.text.toLowerCase();
    if (text.contains('hyderabad') || text.contains('hyd') || text.contains('latifabad')) {
      if (!_locationController.text.contains('Hyderabad')) {
        _locationController.text = 'Latifabad, Hyderabad';
      }
    } else if (text.contains('karachi') || text.contains('khi') || text.contains('clifton') || text.contains('gulshan')) {
      if (!_locationController.text.contains('Karachi')) {
        _locationController.text = 'Clifton, Karachi';
      }
    } else if (text.contains('lahore') || text.contains('lhr') || text.contains('gulberg') || text.contains('model')) {
      if (!_locationController.text.contains('Lahore')) {
        _locationController.text = 'Gulberg III, Lahore';
      }
    } else if (text.contains('islamabad') || text.contains('isb') || text.contains('g-13') || text.contains('f-10')) {
      if (!_locationController.text.contains('Islamabad')) {
        _locationController.text = 'Sector G-13, Islamabad';
      }
    }
  }

  Map<String, String> _parseQuery(String? query) {
    if (query == null || query.trim().isEmpty) {
      return {
        'service': 'AC Services',
        'location': 'G-13, Islamabad',
        'time': 'Tomorrow Morning (~10:00 AM)'
      };
    }

    final lower = query.toLowerCase();
    String service = 'AC Services';

    if (lower.contains('ac') || lower.contains('cool') || lower.contains('garmi')) {
      service = 'AC Services';
    } else if (lower.contains('fridge') || lower.contains('refrig')) {
      service = 'Refrigerator Services';
    } else if (lower.contains('wash') || lower.contains('machine') || lower.contains('dryer')) {
      service = 'Washing Machine Services';
    } else if (lower.contains('electric') || lower.contains('wiring') || lower.contains('fan') || lower.contains('switch') || lower.contains('short') || lower.contains('board') || lower.contains('bijli') || lower.contains('bulb')) {
      service = 'Electrician';
    } else if (lower.contains('plumb') || lower.contains('water') || lower.contains('leak') || lower.contains('pipe') || lower.contains('tap') || lower.contains('sink') || lower.contains('flush') || lower.contains('geyser') || lower.contains('tanki')) {
      service = 'Plumber';
    } else if (lower.contains('wood') || lower.contains('carpenter') || lower.contains('sofa') || lower.contains('door') || lower.contains('table') || lower.contains('chair')) {
      service = 'Carpenter';
    } else if (lower.contains('clean') || lower.contains('dust') || lower.contains('safai') || lower.contains('broom') || lower.contains('wash')) {
      service = 'Cleaning Services';
    } else if (lower.contains('pest') || lower.contains('bug') || lower.contains('spray') || lower.contains('termite')) {
      service = 'Pest Control';
    } else if (lower.contains('beaut') || lower.contains('salon') || lower.contains('make') || lower.contains('makeup') || lower.contains('hair') || lower.contains('facial')) {
      service = 'Beauty Services';
    } else if (lower.contains('health') || lower.contains('doctor') || lower.contains('nurse') || lower.contains('clinic')) {
      service = 'Healthcare';
    } else if (lower.contains('move') || lower.contains('shift') || lower.contains('pack')) {
      service = 'Moving Services';
    } else if (lower.contains('auto') || lower.contains('car') || lower.contains('bike') || lower.contains('mechanic')) {
      service = 'Automotive';
    } else if (lower.contains('digital') || lower.contains('cctv') || lower.contains('camera')) {
      service = 'Digital Services';
    } else if (lower.contains('event') || lower.contains('party') || lower.contains('wedding') || lower.contains('catering')) {
      service = 'Event Services';
    } else if (lower.contains('secur') || lower.contains('guard') || lower.contains('lock')) {
      service = 'Security Services';
    } else if (lower.contains('tutor') || lower.contains('study') || lower.contains('math') || lower.contains('teach') || lower.contains('class') || lower.contains('parha')) {
      service = 'Tutoring';
    } else if (lower.contains('garden') || lower.contains('grass') || lower.contains('plant')) {
      service = 'Gardening';
    }

    String location = 'DHA Phase 5, Lahore';
    if (lower.contains('lahore') || lower.contains('lhr')) {
      location = 'Gulberg III, Lahore';
    } else if (lower.contains('karachi') || lower.contains('khi')) {
      location = 'Clifton, Karachi';
    } else if (lower.contains('hyderabad') || lower.contains('hyd')) {
      location = 'Latifabad, Hyderabad';
    } else if (lower.contains('islamabad') || lower.contains('isb')) {
      location = 'Sector G-13, Islamabad';
    } else if (lower.contains('g-13') || lower.contains('f-10') || lower.contains('f-8')) {
      location = 'Sector G-13, Islamabad';
    } else if (lower.contains('clifton') || lower.contains('gulshan') || lower.contains('saddar') || lower.contains('dha')) {
      location = 'Clifton, Karachi';
    } else if (lower.contains('gulberg') || lower.contains('johar') || lower.contains('model')) {
      location = 'Gulberg III, Lahore';
    } else if (lower.contains('latifabad')) {
      location = 'Latifabad, Hyderabad';
    }

    String time = 'Immediately (Urgent)';
    if (lower.contains('tomorrow') || lower.contains('kal') || lower.contains('subha') || lower.contains('morning')) {
      time = 'Tomorrow Morning (~10:00 AM)';
    } else if (lower.contains('evening') || lower.contains('sham') || lower.contains('night') || lower.contains('raat')) {
      time = 'Tonight (~8:00 PM)';
    } else if (lower.contains('weekend') || lower.contains('saturday') || lower.contains('sunday')) {
      time = 'This Weekend (Saturday, 11:00 AM)';
    }

    return {
      'service': service,
      'location': location,
      'time': time,
    };
  }

  void _handleContinue() {
    if (_formKey.currentState!.validate()) {
      final data = {
        'service': _selectedCategory ?? 'AC Services',
        'work': _workController.text.trim(),
        'location': _locationController.text.trim(),
        'time': _timeController.text.trim(),
      };
      // Pass form data to processing screen!
      context.go('/customer/ai-processing', extra: data);
    }
  }

  @override
  void dispose() {
    _workController.removeListener(_syncLocationFromWorkQuery);
    _workController.dispose();
    _locationController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/customer/home'),
        ),
        title: Text('Verify Request Details', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 32),
                child: IntrinsicHeight(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // AI Header Badge
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(9999),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.auto_awesome, size: 20, color: AppColors.tertiaryFixedDim),
                                const SizedBox(width: 8),
                                Text('AI Request Verification', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: Text('Review and Edit Your Request', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: Text('Please verify or adjust the details detected by our AI.', style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurfaceVariant), textAlign: TextAlign.center),
                        ),
                        const SizedBox(height: 24),

                        // Form Fields Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.surfaceVariant),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Service Category Dropdown
                              Text('Service Category', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                value: _selectedCategory,
                                items: _categories.map((c) => DropdownMenuItem(
                                  value: c,
                                  child: Text(c, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500)),
                                )).toList(),
                                onChanged: (val) {
                                  setState(() => _selectedCategory = val);
                                },
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.handyman_outlined, color: AppColors.primary),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                                validator: (val) => val == null ? 'Please select a category' : null,
                              ),
                              const SizedBox(height: 16),

                              // Work details
                              Text('Actual Work Details', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _workController,
                                maxLines: 3,
                                style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500),
                                decoration: InputDecoration(
                                  hintText: 'Describe the issue...',
                                  prefixIcon: const Padding(
                                    padding: EdgeInsets.only(bottom: 36),
                                    child: Icon(Icons.assignment_outlined, color: AppColors.onSurfaceVariant),
                                  ),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  contentPadding: const EdgeInsets.all(16),
                                ),
                                validator: (val) => val == null || val.trim().isEmpty ? 'Please enter work details' : null,
                              ),
                              const SizedBox(height: 16),

                              // Location
                              Text('Location Address', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _locationController,
                                style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500),
                                decoration: InputDecoration(
                                  hintText: 'e.g. Sector G-13, Islamabad',
                                  prefixIcon: const Icon(Icons.location_on_outlined, color: AppColors.primary),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                                validator: (val) => val == null || val.trim().isEmpty ? 'Please enter address' : null,
                              ),
                              const SizedBox(height: 16),

                              // Time
                              Text('Preferred Service Time', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _timeController,
                                style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500),
                                decoration: InputDecoration(
                                  hintText: 'e.g. Tomorrow Morning (~10:00 AM)',
                                  prefixIcon: const Icon(Icons.access_time_outlined, color: AppColors.onSurfaceVariant),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                                validator: (val) => val == null || val.trim().isEmpty ? 'Please enter preferred time' : null,
                              ),
                            ],
                          ),
                        ),

                        const Spacer(),
                        const SizedBox(height: 24),
                        // Buttons
                        ElevatedButton(
                          onPressed: _handleContinue,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 54),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Confirm & Continue', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward, size: 20),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: () => context.go('/customer/home'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 54),
                            side: const BorderSide(color: AppColors.secondary),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.close, size: 18, color: AppColors.secondary),
                              const SizedBox(width: 8),
                              Text('Cancel', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.secondary)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.auto_awesome, size: 14, color: AppColors.tertiaryFixedDim),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                'Powered by Khidmat AI Orchestration.',
                                style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurfaceVariant),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
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
