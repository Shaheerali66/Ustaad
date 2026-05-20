import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../data/bookings_repository.dart';
import '../../utils/google_maps_service.dart';
import '../../widgets/google_map_widget.dart';

class ProviderDetailsScreen extends StatefulWidget {
  final Map<String, dynamic>? technician;
  
  const ProviderDetailsScreen({
    super.key,
    this.technician,
  });

  @override
  State<ProviderDetailsScreen> createState() => _ProviderDetailsScreenState();
}

class _ProviderDetailsScreenState extends State<ProviderDetailsScreen> {
  int _selectedDayIndex = 0;
  String _selectedTimeSlot = '11:00 AM - 01:00 PM';
  
  final List<String> _timeSlots = [
    '09:00 AM - 11:00 AM',
    '11:00 AM - 01:00 PM',
    '02:00 PM - 04:00 PM',
    '04:00 PM - 06:00 PM',
  ];

  late final List<DateTime> _dates;
  double _centerLat = 30.3753; // Pakistan center
  double _centerLng = 69.3451;
  double _zoom = 5.0; // Country zoom
  List<Map<String, dynamic>> _markers = [];

  @override
  void initState() {
    super.initState();
    // Generate next 7 days for the visual slot picker
    _dates = List.generate(7, (i) => DateTime.now().add(Duration(days: i + 1)));
    _initMapCoordinates();
  }

  void _initMapCoordinates() async {
    final area = (widget.technician?['area'] ?? 'Sector G-13').toString();
    final city = (widget.technician?['city'] ?? 'Islamabad').toString();
    final addressText = '$area, $city';
    
    setState(() {
      _centerLat = 30.3753;
      _centerLng = 69.3451;
      _zoom = 5.0;
      _markers = [];
    });

    if (addressText.isNotEmpty && !addressText.toLowerCase().contains('select location')) {
      double fallbackLat = 33.6844;
      double fallbackLng = 73.0479;
      final lowerCity = city.toLowerCase();
      if (lowerCity.contains('lahore')) {
        fallbackLat = 31.5204;
        fallbackLng = 74.3587;
      } else if (lowerCity.contains('karachi')) {
        fallbackLat = 24.8607;
        fallbackLng = 67.0011;
      } else if (lowerCity.contains('hyderabad')) {
        fallbackLat = 25.3960;
        fallbackLng = 68.3578;
      } else if (lowerCity.contains('peshawar')) {
        fallbackLat = 34.0151;
        fallbackLng = 71.5249;
      } else if (lowerCity.contains('quetta')) {
        fallbackLat = 30.1798;
        fallbackLng = 66.9750;
      } else if (lowerCity.contains('multan')) {
        fallbackLat = 30.1575;
        fallbackLng = 71.5249;
      } else if (lowerCity.contains('faisalabad')) {
        fallbackLat = 31.4504;
        fallbackLng = 73.1350;
      }

      setState(() {
        _centerLat = fallbackLat;
        _centerLng = fallbackLng;
        _zoom = 14.0;
        _markers = [
          {'lat': fallbackLat, 'lng': fallbackLng, 'title': widget.technician?['name'] ?? 'Provider'}
        ];
      });

      final result = await GoogleMapsService.geocodeAddress(addressText);
      if (result != null && mounted) {
        setState(() {
          _centerLat = result['lat'] as double;
          _centerLng = result['lng'] as double;
          _zoom = 14.0;
          _markers = [
            {'lat': _centerLat, 'lng': _centerLng, 'title': widget.technician?['name'] ?? 'Provider'}
          ];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Crash-proof property mapping
    final name = (widget.technician?['name'] ?? 'Professional Provider').toString();
    final category = (widget.technician?['category'] ?? 'Home Services').toString();
    final subService = (widget.technician?['subService'] ?? 'General Service').toString();
    final city = (widget.technician?['city'] ?? 'Islamabad').toString();
    final area = (widget.technician?['area'] ?? 'Sector G-13').toString();
    final description = (widget.technician?['description'] ?? 'Expert service professional dedicated to high quality craftsmanship and reliable results.').toString();
    final languages = (widget.technician?['languages'] ?? 'Urdu, English').toString();
    final rating = double.tryParse(widget.technician?['rating']?.toString() ?? '') ?? 4.5;
    final experience = int.tryParse(widget.technician?['experience']?.toString() ?? '') ?? 3;
    final completedJobs = int.tryParse(widget.technician?['completedJobs']?.toString() ?? '') ?? 10;
    final hourlyRate = int.tryParse(widget.technician?['hourlyRate']?.toString() ?? '') ?? 1200;

    // Generate initials for avatar fallback
    String initials = 'W';
    if (name.trim().isNotEmpty) {
      final parts = name.trim().split(RegExp(r'\s+'));
      if (parts.isNotEmpty) {
        final firstChar = parts.first.isNotEmpty ? parts.first[0] : '';
        final secondChar = (parts.length > 1 && parts[1].isNotEmpty) ? parts[1][0] : '';
        initials = (firstChar + secondChar).toUpperCase();
      }
    }
    if (initials.isEmpty) {
      initials = 'W';
    }

    final avatarColor = Colors.primaries[name.length % Colors.primaries.length].shade400;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.only(left: 12, top: 8, bottom: 8),
          decoration: const BoxDecoration(
            color: AppColors.surfaceContainerLow,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, size: 20, color: AppColors.onSurface),
            onPressed: () => context.pop(),
          ),
        ),
        title: Text(
          'Provider Profile',
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.onSurface),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Profile Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                children: [
                  Hero(
                    tag: 'provider_avatar_${widget.technician?['id'] ?? name}',
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: avatarColor.withValues(alpha: 0.15),
                      backgroundImage: (widget.technician != null && widget.technician!['profilePhoto'] != null)
                          ? MemoryImage(base64Decode(widget.technician!['profilePhoto'].split(',').last))
                          : null,
                      child: (widget.technician == null || widget.technician!['profilePhoto'] == null)
                          ? Text(
                              initials,
                              style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w800, color: avatarColor),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                name,
                                style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.onSurface),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subService,
                          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 14, color: AppColors.onSurfaceVariant),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '$area, $city',
                                style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w500),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Verified | Fast Response | Top Rated Badges
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _badgeItem('Verified ✓', Colors.teal.shade700, Colors.teal.shade50),
                  const SizedBox(width: 8),
                  _badgeItem('Fast Response ⚡', Colors.blue.shade700, Colors.blue.shade50),
                  const SizedBox(width: 8),
                  _badgeItem('Top Rated ★', Colors.orange.shade800, Colors.orange.shade50),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Statistics Grid (Rating, Experience, Jobs)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _metricTile(Icons.star, 'RATING', '$rating', Colors.amber),
                  const SizedBox(width: 10),
                  _metricTile(Icons.work_history, 'EXPERIENCE', '$experience yrs', Colors.blue.shade600),
                  const SizedBox(width: 10),
                  _metricTile(Icons.task_alt, 'COMPLETED', '$completedJobs', Colors.green.shade600),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Pricing details Card showing Simulated Range
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [AppColors.primary.withValues(alpha: 0.04), AppColors.surfaceVariant.withValues(alpha: 0.05)]),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.sell_outlined, color: AppColors.primary, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Estimated Price Range',
                            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant, letterSpacing: 0.5),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Rs. ${hourlyRate - 200} - Rs. ${hourlyRate + 400} / visit',
                            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primary),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Based on standard hourly fee Rs. $hourlyRate/hr. Final scope depends on work diagnostic.',
                            style: GoogleFonts.inter(fontSize: 10, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Interactive Time Slot Calendar / Picker
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Date & Time Slot',
                    style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.onSurface),
                  ),
                  const SizedBox(height: 10),
                  
                  // Days Picker Scrollable
                  SizedBox(
                    height: 64,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: _dates.length,
                      itemBuilder: (context, idx) {
                        final date = _dates[idx];
                        final isSelected = _selectedDayIndex == idx;
                        final dayName = _getDayName(date.weekday);
                        final dateNum = date.day.toString();

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedDayIndex = idx;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 10),
                            width: 58,
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : AppColors.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
                                width: isSelected ? 1.5 : 1.0,
                              ),
                              boxShadow: [
                                if (isSelected)
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  )
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  dayName,
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: isSelected ? Colors.white.withValues(alpha: 0.9) : AppColors.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  dateNum,
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: isSelected ? Colors.white : AppColors.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Slots Picker Grid
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _timeSlots.map((slot) {
                      final isSelected = _selectedTimeSlot == slot;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedTimeSlot = slot;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primaryContainer : AppColors.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
                              width: isSelected ? 1.5 : 1.0,
                            ),
                          ),
                          child: Text(
                            slot,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? AppColors.onPrimaryContainer : AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // About Provider Bio
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About Provider',
                    style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.onSurface),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.surfaceVariant),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.format_quote, size: 24, color: AppColors.outlineVariant),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurfaceVariant, height: 1.5),
                        ),
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.translate, size: 16, color: AppColors.onSurfaceVariant),
                            const SizedBox(width: 8),
                            Text(
                              'Languages: ',
                              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant),
                            ),
                            Text(
                              languages,
                              style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurface, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Provider Location Mini Map
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Provider Work Radius',
                    style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.onSurface),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 300,
                    child: GoogleMapWidget(
                      centerLat: _centerLat,
                      centerLng: _centerLng,
                      zoom: _zoom,
                      markers: _markers,
                      height: 300,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Customer Reviews (2-3 shown)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Customer Reviews ($completedJobs)',
                    style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.onSurface),
                  ),
                  const SizedBox(height: 10),
                  _reviewTile('Zainab Ahmed', 5.0, 'Yesterday', 'Extremely professional and highly skilled. Solved our issue in less than 30 minutes. Strongly recommended!'),
                  const SizedBox(height: 10),
                  _reviewTile('Muhammad Ali', 4.8, '4 days ago', 'Arrived exactly on time and did clean work. Rate is very fair for high quality output.'),
                ],
              ),
            ),

            const SizedBox(height: 120),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            )
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Fully Functional Chat Navigation! Passes the active provider details to Screen 6B
                        context.push('/customer/provider-chat', extra: widget.technician);
                      },
                      icon: const Icon(Icons.chat_bubble_outline, size: 18, color: Color(0xFF00714C)),
                      label: Text('Chat with Provider', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 52),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: const BorderSide(color: Color(0xFF00714C), width: 1.5),
                        foregroundColor: const Color(0xFF00714C),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        IconData catIcon = Icons.build;
                        final catLower = category.toLowerCase();
                        if (catLower.contains('ac')) {
                          catIcon = Icons.hvac;
                        } else if (catLower.contains('plumb')) {
                          catIcon = Icons.plumbing;
                        } else if (catLower.contains('elect')) {
                          catIcon = Icons.electrical_services;
                        } else if (catLower.contains('paint')) {
                          catIcon = Icons.format_paint;
                        } else if (catLower.contains('clean')) {
                          catIcon = Icons.cleaning_services;
                        }

                        final selectedDateStr = '${_dates[_selectedDayIndex].day} ${_getMonthName(_dates[_selectedDayIndex].month)}';

                        BookingsRepository.addBooking(
                          BookingData(
                            title: category,
                            provider: 'Provider: $name',
                            date: '$selectedDateStr, $_selectedTimeSlot',
                            status: 'Confirmed',
                            statusColor: AppColors.primary,
                            action: 'Track',
                            icon: catIcon,
                          ),
                        );

                        context.go('/customer/bookings');
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 52),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        'Confirm Booking',
                        style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _badgeItem(String label, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(
        label,
        style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }

  Widget _metricTile(IconData icon, String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.surfaceVariant),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.onSurface),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant, letterSpacing: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _reviewTile(String name, double rating, String date, String comment) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
              Text(date, style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.star, size: 14, color: Colors.amber),
              const SizedBox(width: 4),
              Text('$rating', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
            ],
          ),
          const SizedBox(height: 6),
          Text(comment, style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant, height: 1.4)),
        ],
      ),
    );
  }

  String _getDayName(int day) {
    switch (day) {
      case 1: return 'Mon';
      case 2: return 'Tue';
      case 3: return 'Wed';
      case 4: return 'Thu';
      case 5: return 'Fri';
      case 6: return 'Sat';
      case 7: return 'Sun';
      default: return 'Day';
    }
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1: return 'Jan';
      case 2: return 'Feb';
      case 3: return 'Mar';
      case 4: return 'Apr';
      case 5: return 'May';
      case 6: return 'Jun';
      case 7: return 'Jul';
      case 8: return 'Aug';
      case 9: return 'Sep';
      case 10: return 'Oct';
      case 11: return 'Nov';
      case 12: return 'Dec';
      default: return 'Month';
    }
  }
}

class _LocationMapPainter extends CustomPainter {
  final String area;
  final String city;
  const _LocationMapPainter(this.area, this.city);

  @override
  void paint(Canvas canvas, Size size) {
    // Fill green map landscape background
    final paint = Paint()
      ..color = const Color(0xFFF1F6F2)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Offset.zero & size, paint);

    // Draw stylized secondary roads
    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(20, 20), Offset(size.width - 20, size.height - 20), roadPaint);
    canvas.drawLine(Offset(size.width - 20, 30), Offset(20, size.height - 30), roadPaint);
    canvas.drawLine(Offset(size.width / 2, 0), Offset(size.width / 2, size.height), roadPaint);

    // Draw stylized river/water body
    final riverPaint = Paint()
      ..color = const Color(0xFFD6E4FF)
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    final path = Path()
      ..moveTo(0, size.height * 0.2)
      ..quadraticBezierTo(size.width * 0.4, size.height * 0.8, size.width, size.height * 0.3);
    canvas.drawPath(path, riverPaint);

    // Draw centered provider GPS marker
    final center = Offset(size.width / 2, size.height / 2);
    final markerPaint = Paint()..color = const Color(0xFF00714C);
    
    // Pulse rings
    final pulsePaint = Paint()
      ..color = const Color(0xFF00714C).withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 28, pulsePaint);
    canvas.drawCircle(center, 14, Paint()..color = const Color(0xFF00714C).withValues(alpha: 0.3));

    // Core pin
    canvas.drawCircle(center, 8, markerPaint);
    canvas.drawCircle(center, 3, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
