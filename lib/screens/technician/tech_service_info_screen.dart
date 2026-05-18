import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../data/document_database.dart';

class TechServiceInfoScreen extends StatefulWidget {
  const TechServiceInfoScreen({super.key});

  @override
  State<TechServiceInfoScreen> createState() => _TechServiceInfoScreenState();
}

class _TechServiceInfoScreenState extends State<TechServiceInfoScreen> {
  String? _selectedCategory;
  String? _categoryError;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();

  static const List<Map<String, dynamic>> _categories = [
    {'name': 'Plumber', 'icon': Icons.plumbing, 'desc': 'Pipes, taps, leaks, bathroom fitting'},
    {'name': 'Electrician', 'icon': Icons.electrical_services, 'desc': 'Wiring, switches, fuse box, lighting'},
    {'name': 'AC Technician', 'icon': Icons.hvac, 'desc': 'AC repair, installation, gas refill'},
    {'name': 'Carpenter', 'icon': Icons.carpenter, 'desc': 'Furniture repair, doors, cabinets'},
    {'name': 'Painter', 'icon': Icons.format_paint, 'desc': 'Wall painting, polish, waterproofing'},
    {'name': 'Home Cleaning', 'icon': Icons.cleaning_services, 'desc': 'Deep cleaning, sofa wash, fumigation'},
    {'name': 'Beautician', 'icon': Icons.face_retouching_natural, 'desc': 'Home salon, bridal, skincare'},
    {'name': 'Tutor', 'icon': Icons.school, 'desc': 'Home tuition, test prep, language'},
    {'name': 'Mechanic', 'icon': Icons.build, 'desc': 'Car/bike repair, oil change, tyre'},
    {'name': 'Geyser Technician', 'icon': Icons.water_drop, 'desc': 'Geyser repair, thermostat, installation'},
    {'name': 'Welder', 'icon': Icons.construction, 'desc': 'Iron gates, grills, welding work'},
    {'name': 'Mason', 'icon': Icons.foundation, 'desc': 'Brick work, tiling, plastering'},
    {'name': 'CCTV Installer', 'icon': Icons.videocam, 'desc': 'Camera setup, DVR, wiring'},
    {'name': 'Pest Control', 'icon': Icons.bug_report, 'desc': 'Termite, cockroach, mosquito spray'},
    {'name': 'Appliance Repair', 'icon': Icons.kitchen, 'desc': 'Washing machine, fridge, microwave'},
    {'name': 'UPS / Solar Tech', 'icon': Icons.solar_power, 'desc': 'UPS, inverter, solar panel install'},
  ];

  void _handleContinue() {
    bool isCategoryValid = _selectedCategory != null;

    setState(() {
      if (!isCategoryValid) {
        _categoryError = 'Please search and select a service category';
      } else {
        _categoryError = null;
      }
    });

    if (_formKey.currentState!.validate() && isCategoryValid) {
      DocumentDatabase.currentCategory = _selectedCategory;
      DocumentDatabase.currentExperience = int.tryParse(_experienceController.text.trim()) ?? 3;
      DocumentDatabase.currentArea = _areaController.text.trim();
      DocumentDatabase.currentRate = int.tryParse(_rateController.text.trim()) ?? 1000;
      context.go('/technician/documents');
    } else {
      // Show failure message
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.white),
            const SizedBox(width: 8),
            Text('Please complete all service details first!', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ]),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  void dispose() {
    _experienceController.dispose();
    _areaController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        title: Text('Service Information', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Step indicator
            Row(children: [
              Expanded(child: Container(height: 4, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(width: 4),
              Expanded(child: Container(height: 4, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(width: 4),
              Expanded(child: Container(height: 4, decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(width: 4),
              Expanded(child: Container(height: 4, decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(2)))),
            ]),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Personal', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
              Text('Service', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
              Text('Verification', style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant)),
              Text('Done', style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant)),
            ]),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                const Icon(Icons.build, size: 24, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Tell us what you do', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
                  Text('This helps us match you with the right customer requests in your area.', style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurfaceVariant)),
                ])),
              ]),
            ),
            const SizedBox(height: 24),

            // Service Category with Autocomplete
            Text('Service Category', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Autocomplete<Map<String, dynamic>>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return _categories;
                }
                return _categories.where((cat) {
                  final name = (cat['name'] as String).toLowerCase();
                  final desc = (cat['desc'] as String).toLowerCase();
                  final query = textEditingValue.text.toLowerCase();
                  return name.contains(query) || desc.contains(query);
                });
              },
              displayStringForOption: (option) => option['name'] as String,
              onSelected: (selection) {
                setState(() {
                  _selectedCategory = selection['name'] as String;
                  _categoryError = null;
                });
              },
              fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
                return TextFormField(
                  controller: textController,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    hintText: 'Search or select your trade...',
                    errorText: _categoryError,
                    prefixIcon: _selectedCategory != null
                        ? Padding(
                            padding: const EdgeInsets.all(12),
                            child: Icon(
                              _categories.firstWhere((c) => c['name'] == _selectedCategory)['icon'] as IconData,
                              color: AppColors.primary,
                              size: 22,
                            ),
                          )
                        : const Padding(
                            padding: EdgeInsets.all(12),
                            child: Icon(Icons.search, color: AppColors.onSurfaceVariant, size: 22),
                          ),
                    suffixIcon: const Icon(Icons.expand_more, color: AppColors.onSurfaceVariant),
                  ),
                  onFieldSubmitted: (_) => onFieldSubmitted(),
                );
              },
              optionsViewBuilder: (context, onSelected, options) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(16),
                    color: AppColors.surfaceContainerLowest,
                    child: Container(
                      width: MediaQuery.of(context).size.width - 64,
                      constraints: const BoxConstraints(maxHeight: 320),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.surfaceVariant),
                      ),
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shrinkWrap: true,
                        itemCount: options.length,
                        separatorBuilder: (_, __) => const Divider(height: 1, indent: 16, endIndent: 16, color: AppColors.surfaceVariant),
                        itemBuilder: (context, index) {
                          final option = options.elementAt(index);
                          final isSelected = _selectedCategory == option['name'];
                          return InkWell(
                            onTap: () => onSelected(option),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primaryContainer.withValues(alpha: 0.2) : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40, height: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected ? AppColors.primaryContainer : AppColors.surfaceContainerLow,
                                    ),
                                    child: Icon(
                                      option['icon'] as IconData,
                                      size: 20,
                                      color: isSelected ? AppColors.onPrimaryContainer : AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          option['name'] as String,
                                          style: GoogleFonts.inter(
                                            fontSize: 15,
                                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                            color: isSelected ? AppColors.primary : AppColors.onSurface,
                                          ),
                                        ),
                                        Text(
                                          option['desc'] as String,
                                          style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    const Icon(Icons.check_circle, size: 20, color: AppColors.primary),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),

            // Selected category chip
            if (_selectedCategory != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      _categories.firstWhere((c) => c['name'] == _selectedCategory)['icon'] as IconData,
                      size: 20, color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Selected: $_selectedCategory',
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _selectedCategory = null),
                      child: const Icon(Icons.close, size: 18, color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),
            Text('Years of Experience', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _experienceController,
              decoration: InputDecoration(hintText: 'e.g. 5', suffixIcon: const Icon(Icons.work_history_outlined, color: AppColors.onSurfaceVariant)),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your years of experience';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            Text('Service Area', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _areaController,
              decoration: InputDecoration(hintText: 'Search city or neighborhood', prefixIcon: const Icon(Icons.location_on_outlined, color: AppColors.onSurfaceVariant)),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your service area';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            Text('Expected Hourly Rate', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _rateController,
              decoration: InputDecoration(hintText: '1000', prefixText: 'Rs.  '),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your expected rate';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            Row(children: [const Icon(Icons.info_outline, size: 14, color: AppColors.tertiaryFixedDim), const SizedBox(width: 4), Expanded(child: Text('This is a baseline. You can adjust your final quote per booking.', style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant)))]),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _handleContinue,
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text('Continue to Verification', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)), const SizedBox(width: 8), const Icon(Icons.arrow_forward, size: 20)]),
            ),
            const SizedBox(height: 16),
          ]),
        ),
      ),
    );
  }
}
