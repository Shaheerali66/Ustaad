import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../data/user_database.dart';

class QuickServiceFormScreen extends StatefulWidget {
  final String? category;

  const QuickServiceFormScreen({super.key, this.category});

  @override
  State<QuickServiceFormScreen> createState() => _QuickServiceFormScreenState();
}

class _QuickServiceFormScreenState extends State<QuickServiceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _workController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1)); // Default tomorrow
  String _selectedTimeSlot = 'Morning'; // Default slot
  bool _isLocating = false;

  final List<String> _timeSlots = ['Morning', 'Afternoon', 'Evening', 'Specific Slot'];

  @override
  void initState() {
    super.initState();
    // Pre-fill with customer's address from UserDatabase
    final user = UserDatabase.currentUser;
    if (user != null) {
      final address = user['address'] ?? '';
      final city = user['city'] ?? '';
      if (address.isNotEmpty && city.isNotEmpty) {
        _addressController.text = '$address, $city';
      } else if (address.isNotEmpty) {
        _addressController.text = address;
      } else if (city.isNotEmpty) {
        _addressController.text = city;
      }
    }

    _addressController.addListener(() {
      setState(() {});
    });
  }


  @override
  void dispose() {
    _addressController.dispose();
    _workController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _detectLocation() {
    setState(() => _isLocating = true);
    
    // Simulate high precision GPS delay
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _isLocating = false;
          // Random premium local cities for realistic demonstration
          final mockLocations = [
            'Sector F-10, Islamabad',
            'DHA Phase 5, Lahore',
            'Clifton Block 5, Karachi',
            'Latifabad Unit 6, Hyderabad'
          ];
          // Pick based on pre-selected category length to make it deterministic but diverse
          final idx = (widget.category?.length ?? 0) % mockLocations.length;
          _addressController.text = mockLocations[idx];
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.gps_fixed, color: Colors.white),
                const SizedBox(width: 8),
                Text('GPS Location auto-detected successfully!', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              ],
            ),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    });
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return 'Today';
    }
    final tomorrow = now.add(const Duration(days: 1));
    if (date.year == tomorrow.year && date.month == tomorrow.month && date.day == tomorrow.day) {
      return 'Tomorrow';
    }
    return '${date.day}/${date.month}/${date.year}';
  }

  void _handleSubmit() {
    if (_addressController.text.trim().isEmpty) return;

    final data = {
      'service': widget.category ?? 'AC Services',
      'work': _workController.text.trim().isEmpty ? '${widget.category} service requested' : _workController.text.trim(),
      'location': _addressController.text.trim(),
      'date': _formatDate(_selectedDate),
      'time': _selectedTimeSlot,
      'isFreeText': false, // Structured entry point indicator
    };

    context.go('/customer/ai-processing', extra: data);
  }

  @override
  Widget build(BuildContext context) {
    final serviceName = widget.category ?? 'AC Services';
    final isAddressFilled = _addressController.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Service Details',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 18, color: AppColors.onSurface),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => context.go('/customer/home'),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 40),
                child: IntrinsicHeight(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Text(
                          'Tell us what you need',
                          style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.onBackground, letterSpacing: -0.5),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Let\'s build your request for: $serviceName',
                          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary),
                        ),
                        const SizedBox(height: 24),

                        // Pre-filled locked Service Type
                        Text(
                          'Service Category',
                          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.onSurface),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.surfaceVariant),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.lock_outline, size: 18, color: AppColors.onSurfaceVariant),
                              const SizedBox(width: 10),
                              Text(
                                serviceName,
                                style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Location Address Field
                        Text(
                          'Your Address / Location *',
                          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.onSurface),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _addressController,
                          style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500),
                          decoration: InputDecoration(
                            hintText: 'Enter street, sector, area, or city...',
                            hintStyle: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurfaceVariant),
                            prefixIcon: const Icon(Icons.location_on_outlined, color: AppColors.primary),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.surfaceVariant),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.surfaceVariant),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        
                        // Use GPS button
                        ElevatedButton.icon(
                          onPressed: _isLocating ? null : _detectLocation,
                          icon: _isLocating 
                              ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
                              : const Icon(Icons.gps_fixed, size: 14),
                          label: Text(
                            _isLocating ? 'Detecting GPS...' : 'Use My Current Location',
                            style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 12),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryContainer,
                            foregroundColor: AppColors.onPrimaryContainer,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'We will only show providers available in your entered city or area',
                          style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.onSurfaceVariant),
                        ),
                        const SizedBox(height: 20),

                        // Date and Time Row
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Preferred Date',
                                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.onSurface),
                                  ),
                                  const SizedBox(height: 8),
                                  InkWell(
                                    onTap: () => _selectDate(context),
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: AppColors.surfaceVariant),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            _formatDate(_selectedDate),
                                            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
                                          ),
                                          const Icon(Icons.calendar_today, size: 16, color: AppColors.primary),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Preferred Time',
                                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.onSurface),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: AppColors.surfaceVariant),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: _selectedTimeSlot,
                                        isExpanded: true,
                                        icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
                                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onSurface),
                                        onChanged: (String? newValue) {
                                          if (newValue != null) {
                                            setState(() {
                                              _selectedTimeSlot = newValue;
                                            });
                                          }
                                        },
                                        items: _timeSlots.map<DropdownMenuItem<String>>((String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Work Details Field
                        Text(
                          'Work Details (Optional)',
                          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.onSurface),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _workController,
                          maxLines: 4,
                          minLines: 3,
                          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
                          decoration: InputDecoration(
                            hintText: 'Briefly describe the problem (e.g., pipe leakage in kitchen ceiling, fan making noise, split AC not cooling)...',
                            hintStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurfaceVariant),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.all(16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.surfaceVariant),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.surfaceVariant),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                            ),
                          ),
                        ),
                        
                        const Spacer(),
                        const SizedBox(height: 32),

                        // Find Providers button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: isAddressFilled ? _handleSubmit : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: AppColors.surfaceContainerHigh,
                              disabledForegroundColor: AppColors.onSurfaceVariant,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Find Providers',
                                  style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward, size: 18),
                              ],
                            ),
                          ),
                        ),
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
