import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../data/technicians_data.dart';
import '../../data/bookings_repository.dart';
import '../../data/document_database.dart';

class ProviderDiscoveryScreen extends StatefulWidget {
  final Map<String, dynamic>? bookingDetails;

  const ProviderDiscoveryScreen({super.key, this.bookingDetails});

  @override
  State<ProviderDiscoveryScreen> createState() => _ProviderDiscoveryScreenState();
}

class _ProviderDiscoveryScreenState extends State<ProviderDiscoveryScreen> {
  String _selectedSort = 'Rating'; // Options: 'Distance', 'Rating', 'Availability', 'Price'
  bool _expandSearch = false; // Set to true when user gives explicit consent to expand search
  
  @override
  Widget build(BuildContext context) {
    final selectedCategory = (widget.bookingDetails?['service'] ?? 'AC Services').toString();
    final locationText = (widget.bookingDetails?['location'] ?? 'Sector G-13, Islamabad').toString();
    final workText = (widget.bookingDetails?['work'] ?? 'AC servicing and cleaning').toString();
    final timeText = (widget.bookingDetails?['time'] ?? 'Tomorrow Morning (~10:00 AM)').toString();

    final lowerLoc = locationText.toLowerCase();
    final lowerWork = workText.toLowerCase();
    
    String targetCity = 'Islamabad';
    
    // Scan BOTH locationText and workText for spelling variations of target cities
    if (lowerLoc.contains('lahore') || lowerLoc.contains('lhr') ||
        lowerWork.contains('lahore') || lowerWork.contains('lhr')) {
      targetCity = 'Lahore';
    } else if (lowerLoc.contains('karachi') || lowerLoc.contains('khi') ||
               lowerWork.contains('karachi') || lowerWork.contains('khi')) {
      targetCity = 'Karachi';
    } else if (lowerLoc.contains('hyderabad') || lowerLoc.contains('hyd') ||
               lowerWork.contains('hyderabad') || lowerWork.contains('hyd')) {
      targetCity = 'Hyderabad';
    } else if (lowerLoc.contains('islamabad') || lowerLoc.contains('isb') ||
               lowerWork.contains('islamabad') || lowerWork.contains('isb')) {
      targetCity = 'Islamabad';
    } else {
      // Fallback area based detection
      if (lowerLoc.contains('gulberg') || lowerLoc.contains('model') || lowerLoc.contains('johar')) {
        targetCity = 'Lahore';
      } else if (lowerLoc.contains('clifton') || lowerLoc.contains('gulshan') || lowerLoc.contains('saddar')) {
        targetCity = 'Karachi';
      } else if (lowerLoc.contains('latifabad')) {
        targetCity = 'Hyderabad';
      } else if (lowerLoc.contains('g-13') || lowerLoc.contains('f-10') || lowerLoc.contains('f-8')) {
        targetCity = 'Islamabad';
      }
    }

    // Filter technicians STRICTLY based on the targeted City first (Mandatory)
    List<Map<String, dynamic>> allTechs = [];
    
    // Add default seeds from Excel
    allTechs.addAll(TechnicianDataset.technicians.map((t) => Map<String, dynamic>.from(t)));

    // Add Approved Dynamic Cloud Onboarded Technicians!
    final dynamicTechs = DocumentDatabase.onboardedTechnicians.where((tech) {
      final isApproved = tech['status'] == 'Approved';
      return isApproved;
    }).map((t) => {
      'id': int.tryParse(t['id']?.toString() ?? '1000') ?? 1000,
      'name': t['name'],
      'category': t['category'],
      'matchCategory': t['category']?.toString().toLowerCase(),
      'subService': t['category'],
      'phone': t['phone'],
      'city': t['city'] ?? 'Islamabad',
      'area': t['area'] ?? 'Sector G-13',
      'experience': t['experience'] ?? 3,
      'rating': 4.8, 
      'completedJobs': 12,
      'availability': 'Available',
      'hourlyRate': t['hourlyRate'] ?? 1200,
      'languages': 'Urdu, English',
      'cnicVerified': 'Yes',
      'bgVerified': 'Yes',
      'emergencyService': 'Yes',
      'gender': 'Male',
      'description': '${t['name']} is a verified ${t['category']} with ${t['experience']} years experience.',
      'profilePhoto': t['profilePhoto'],
    });

    allTechs.addAll(dynamicTechs);

    // Apply strict city filtering unless search is explicitly expanded with user consent
    List<Map<String, dynamic>> filteredTechs = allTechs.where((tech) {
      final city = (tech['city'] ?? '').toString().toLowerCase();
      
      if (_expandSearch) {
        // Broaden search parameters (user gave explicit consent)
        return true;
      }
      // Strict location filter
      return city == targetCity.toLowerCase();
    }).toList();

    // Among those city-filtered technicians, filter strictly by Category / SubService
    filteredTechs = filteredTechs.where((tech) {
      final techCat = (tech['category'] ?? '').toString().toLowerCase();
      final targetCat = selectedCategory.toLowerCase();
      final matchCat = (tech['matchCategory'] ?? '').toString().toLowerCase();
      
      return techCat == targetCat || matchCat == targetCat || techCat.contains(targetCat) || targetCat.contains(techCat);
    }).toList();

    // Deterministic distance generator based on whether the tech area matches locationText
    for (var tech in filteredTechs) {
      final techArea = (tech['area'] ?? '').toString().toLowerCase();
      final techCity = (tech['city'] ?? '').toString().toLowerCase();
      final isSameCity = techCity == targetCity.toLowerCase();
      
      if (!isSameCity) {
        // Far away because it's another city (regional search expansion)
        tech['distance'] = 22.0 + (tech['name'].toString().length % 5) * 4.5;
      } else if (lowerLoc.contains(techArea) || techArea.contains(lowerLoc)) {
        tech['distance'] = 0.5 + (tech['name'].toString().length % 3) * 0.3;
      } else {
        tech['distance'] = 1.8 + (tech['name'].toString().length % 6) * 0.4;
      }
    }

    // Sort technicians based on active sort selector
    if (_selectedSort == 'Rating') {
      filteredTechs.sort((a, b) {
        final aRating = double.tryParse(a['rating']?.toString() ?? '') ?? 0.0;
        final bRating = double.tryParse(b['rating']?.toString() ?? '') ?? 0.0;
        return bRating.compareTo(aRating);
      });
    } else if (_selectedSort == 'Distance') {
      filteredTechs.sort((a, b) {
        final aDist = double.tryParse(a['distance']?.toString() ?? '') ?? 999.0;
        final bDist = double.tryParse(b['distance']?.toString() ?? '') ?? 999.0;
        return aDist.compareTo(bDist);
      });
    } else if (_selectedSort == 'Availability') {
      filteredTechs.sort((a, b) {
        final aAvail = a['availability']?.toString() == 'Available' ? 1 : 0;
        final bAvail = b['availability']?.toString() == 'Available' ? 1 : 0;
        return bAvail.compareTo(aAvail);
      });
    } else if (_selectedSort == 'Price') {
      filteredTechs.sort((a, b) {
        final aRate = double.tryParse(a['hourlyRate']?.toString() ?? '') ?? 9999.0;
        final bRate = double.tryParse(b['hourlyRate']?.toString() ?? '') ?? 9999.0;
        return aRate.compareTo(bRate);
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
              onPressed: () => context.go('/customer/home'),
            ),
            const Spacer(),
            Text(
              'Top Providers in $targetCity',
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.refresh, color: AppColors.primary),
              onPressed: () {
                setState(() {});
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter HUD summary card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.primary, AppColors.surfaceTint]),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 8, offset: const Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'ACTIVE ISOLATED SEARCH FILTER',
                        style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white.withOpacity(0.8), letterSpacing: 0.8),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Service: $selectedCategory', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Location: $locationText ($targetCity region)',
                          style: GoogleFonts.inter(fontSize: 12, color: Colors.white.withOpacity(0.9)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.access_time, color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text('Schedule: $timeText', style: GoogleFonts.inter(fontSize: 12, color: Colors.white.withOpacity(0.9))),
                    ],
                  ),
                ],
              ),
            ),

            if (_expandSearch)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.amber, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Search boundaries expanded to other cities per your consent.',
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.amber.shade900),
                      ),
                    ),
                  ],
                ),
              ),

            Text('Verified AI Recommendations', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.onBackground)),
            const SizedBox(height: 4),
            Text(
              'Found ${filteredTechs.length} certified $selectedCategory professionals matching your query.',
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            
            if (filteredTechs.isEmpty)
              _buildNoResultsState(targetCity)
            else ...[
              // Simulated map restricting coordinates strictly inside targetCity
              Container(
                height: 180,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: AppColors.surfaceContainerLow,
                  border: Border.all(color: AppColors.surfaceVariant),
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: CustomPaint(
                        size: const Size(double.infinity, 180),
                        painter: _MiniMapPainter(filteredTechs),
                      ),
                    ),
                    Positioned(
                      top: 12, right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
                        child: Text(
                          '$targetCity Isolated Map',
                          style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 12, left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.surfaceVariant)),
                        child: Row(
                          children: [
                            const Icon(Icons.gps_fixed, size: 14, color: AppColors.primary),
                            const SizedBox(width: 6),
                            Text('Radar: ${filteredTechs.length} pins loaded', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),

              // Interactive sorting tabs
              _buildInteractiveSortBar(),

              // Provider list
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredTechs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, idx) {
                  final tech = filteredTechs[idx];
                  final rating = double.tryParse(tech['rating']?.toString() ?? '') ?? 4.0;
                  final exp = int.tryParse(tech['experience']?.toString() ?? '') ?? 2;
                  final jobs = int.tryParse(tech['completedJobs']?.toString() ?? '') ?? 0;
                  final rate = int.tryParse(tech['hourlyRate']?.toString() ?? '') ?? 1000;
                  final dist = tech['distance'] ?? 1.5;
                  
                  final isAvailable = tech['availability']?.toString() == 'Available';
                  final isBgVerified = tech['bgVerified']?.toString() == 'Yes';
                  final isCnicVerified = tech['cnicVerified']?.toString() == 'Yes';
                  final isEmergency = tech['emergencyService']?.toString() == 'Yes';

                  return _providerCard(
                    context: context,
                    tech: tech,
                    name: (tech['name'] ?? '').toString(),
                    rating: rating,
                    experience: exp,
                    jobs: jobs,
                    rate: rate,
                    distance: dist,
                    city: (tech['city'] ?? '').toString(),
                    area: (tech['area'] ?? '').toString(),
                    subService: (tech['subService'] ?? '').toString(),
                    languages: (tech['languages'] ?? '').toString(),
                    available: isAvailable,
                    bgVerified: isBgVerified,
                    cnicVerified: isCnicVerified,
                    emergency: isEmergency,
                    gender: (tech['gender'] ?? '').toString(),
                    desc: (tech['description'] ?? '').toString(),
                    isBestMatch: idx == 0,
                  );
                },
              ),
            ],
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildInteractiveSortBar() {
    final sortOptions = [
      ('Rating', Icons.star_border),
      ('Distance', Icons.directions_run),
      ('Availability', Icons.check_circle_outline),
      ('Price', Icons.payments_outlined),
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sort Matches By:',
            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: sortOptions.map((opt) {
                final isSelected = _selectedSort == opt.$1;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedSort = opt.$1;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primaryContainer : AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.outlineVariant,
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(opt.$2, size: 14, color: isSelected ? AppColors.onPrimaryContainer : AppColors.onSurfaceVariant),
                        const SizedBox(width: 6),
                        Text(
                          opt.$1,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? AppColors.onPrimaryContainer : AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _providerCard({
    required BuildContext context,
    required Map<String, dynamic> tech,
    required String name,
    required double rating,
    required int experience,
    required int jobs,
    required int rate,
    required double distance,
    required String city,
    required String area,
    required String subService,
    required String languages,
    required bool available,
    required bool bgVerified,
    required bool cnicVerified,
    required bool emergency,
    required String gender,
    required String desc,
    bool isBestMatch = false,
  }) {
    String initials = 'W';
    if (name.trim().isNotEmpty) {
      final parts = name.trim().split(RegExp(r'\s+'));
      if (parts.isNotEmpty) {
        final firstChar = parts.first.isNotEmpty ? parts.first[0] : '';
        final secondChar = (parts.length > 1 && parts[1].isNotEmpty) ? parts[1][0] : '';
        initials = (firstChar + secondChar).toUpperCase();
      }
    }

    final avatarColor = Colors.primaries[name.length % Colors.primaries.length].shade400;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isBestMatch ? AppColors.primaryContainer.withOpacity(0.04) : AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isBestMatch ? AppColors.primary : AppColors.surfaceVariant,
          width: isBestMatch ? 2.0 : 1.0,
        ),
        boxShadow: [
          if (isBestMatch)
            BoxShadow(
              color: AppColors.primary.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          else
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (isBestMatch) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, size: 12, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        'BEST MATCH',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${distance.toStringAsFixed(1)} km away',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondary,
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: avatarColor.withOpacity(0.15),
                backgroundImage: tech['profilePhoto'] != null
                    ? MemoryImage(base64Decode(tech['profilePhoto']!.split(',').last))
                    : null,
                child: tech['profilePhoto'] == null
                    ? Text(
                        initials,
                        style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: avatarColor, fontSize: 18),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 2),
                        Text('$rating', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
                        Text(' • ', style: GoogleFonts.inter(color: AppColors.onSurfaceVariant)),
                        Text('$experience yrs exp', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
                        Text(' • ', style: GoogleFonts.inter(color: AppColors.onSurfaceVariant)),
                        Text('$jobs jobs completed', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.secondary)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 14, color: AppColors.onSurfaceVariant),
                        const SizedBox(width: 2),
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
          
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              if (cnicVerified)
                _verifBadge('CNIC Verified ✓', Colors.blue.shade700, Colors.blue.shade50),
              if (bgVerified)
                _verifBadge('Background Clear ✓', Colors.teal.shade700, Colors.teal.shade50),
              if (emergency)
                _verifBadge('24/7 Emergency', Colors.red.shade700, Colors.red.shade50),
              if (available)
                _verifBadge('Available Today', AppColors.primary, AppColors.primaryContainer.withOpacity(0.12)),
            ],
          ),

          // WHY RECOMMENDED Badge
          const SizedBox(height: 12),
          _WhyRecommendedWidget(
            name: name,
            subService: subService,
            rating: rating,
            jobs: jobs,
            distance: distance,
          ),

          const Divider(height: 24, color: AppColors.surfaceVariant),

          // Price & Buttons Row
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('HOURLY RATE', style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant, letterSpacing: 0.5)),
                  Text(
                    'Rs. $rate / hr',
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primary),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          IconData catIcon = Icons.build;
                          final catLower = subService.toLowerCase();
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

                          BookingsRepository.addBooking(
                            BookingData(
                              title: subService,
                              provider: 'Provider: $name',
                              date: '${widget.bookingDetails?['date'] ?? 'Tomorrow'}, ${widget.bookingDetails?['time'] ?? '10:00 AM'}',
                              status: 'Confirmed',
                              statusColor: AppColors.primary,
                              action: 'Track',
                              icon: catIcon,
                            ),
                          );

                          context.go('/customer/bookings');
                        },
                        icon: const Icon(Icons.calendar_month, size: 14, color: Colors.white),
                        label: Text('Book Now', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 11)),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context.push('/customer/provider-details', extra: tech),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: Color(0xFF00714C), width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text(
                          'View Profile',
                          style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 11, color: const Color(0xFF00714C)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _verifBadge(String label, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(
        label,
        style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }

  Widget _buildNoResultsState(String city) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
      margin: const EdgeInsets.only(top: 10, bottom: 40),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.surfaceVariant, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.errorContainer.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              size: 48,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No Providers in $city',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.onBackground,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'We currently do not have any registered service providers for this service in the $city area. Would you like to expand your search area to find regional service providers?',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.onSurfaceVariant,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _expandSearch = true;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: Text(
                'Expand Search Area',
                style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => context.go('/customer/home'),
            child: Text(
              'Back to Dashboard',
              style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppColors.primary, fontSize: 13),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), offset: const Offset(0, -2), blurRadius: 4)],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(Icons.home_rounded, 'Home', true, () => context.go('/customer/home')),
              _navItem(Icons.event_note_rounded, 'My Bookings', false, () => context.go('/customer/bookings')),
              _navItem(Icons.query_stats_rounded, 'Track', false, () => context.go('/customer/track')),
              _navItem(Icons.person_rounded, 'Profile', false, () => context.go('/customer/profile')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: active ? 16 : 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppColors.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(9999),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24, color: active ? AppColors.onPrimaryContainer : AppColors.onSurfaceVariant),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 10, fontWeight: active ? FontWeight.w700 : FontWeight.w400, color: active ? AppColors.onPrimaryContainer : AppColors.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

class _WhyRecommendedWidget extends StatefulWidget {
  final String name;
  final String subService;
  final double rating;
  final int jobs;
  final double distance;

  const _WhyRecommendedWidget({
    required this.name,
    required this.subService,
    required this.rating,
    required this.jobs,
    required this.distance,
  });

  @override
  State<_WhyRecommendedWidget> createState() => _WhyRecommendedWidgetState();
}

class _WhyRecommendedWidgetState extends State<_WhyRecommendedWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F7FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline, size: 16, color: Colors.amber),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurface),
                        children: [
                          TextSpan(
                            text: 'Why Recommended: ',
                            style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppColors.primary),
                          ),
                          TextSpan(
                            text: widget.distance < 1.0
                                ? 'Closest verified ${widget.subService.toLowerCase()} near you...'
                                : 'Highly qualified match for ${widget.subService.toLowerCase()}...',
                            style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 16,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
              child: Text(
                '${widget.name} ranks #1 based on proximity (${widget.distance.toStringAsFixed(1)} km) and a pristine ${widget.rating} rating from ${widget.jobs} bookings. Highly recommended for efficient, top-tier ${widget.subService.toLowerCase()} support without delays.',
                style: GoogleFonts.inter(fontSize: 11, height: 1.4, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w500),
              ),
            ),
        ],
      ),
    );
  }
}

class _MiniMapPainter extends CustomPainter {
  final List<Map<String, dynamic>> techs;
  const _MiniMapPainter(this.techs);

  @override
  void paint(Canvas canvas, Size size) {
    // Draw map background
    final paint = Paint()
      ..color = const Color(0xFFE8F1E9)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Offset.zero & size, paint);

    // Draw route grids
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..strokeWidth = 2.0;

    for (double i = 0; i < size.width; i += 30) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);
    }
    for (double i = 0; i < size.height; i += 30) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), gridPaint);
    }

    // Draw stylized highway roads
    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(30, 20), Offset(size.width - 30, size.height - 20), roadPaint);
    canvas.drawLine(Offset(size.width - 30, 20), Offset(30, size.height - 20), roadPaint);

    final roadBorderPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeWidth = 16
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(30, 20), Offset(size.width - 30, size.height - 20), roadBorderPaint);
    canvas.drawLine(Offset(size.width - 30, 20), Offset(30, size.height - 20), roadBorderPaint);

    // Draw primary blue user GPS pin in center
    final centerPin = Paint()..color = AppColors.primary;
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 12, centerPin);
    
    final pulsePaint = Paint()
      ..color = AppColors.primary.withOpacity(0.25)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 24, pulsePaint);

    final centerCore = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 5, centerCore);

    // Draw nearby technician pins based on count
    final techPin = Paint()..color = AppColors.secondary;
    final pinOffsets = [
      Offset(size.width / 2 - 70, size.height / 2 - 40),
      Offset(size.width / 2 + 80, size.height / 2 + 30),
      Offset(size.width / 2 - 40, size.height / 2 + 50),
      Offset(size.width / 2 + 60, size.height / 2 - 60),
    ];

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    for (int i = 0; i < techs.length.clamp(0, 4); i++) {
      final offset = pinOffsets[i];
      final tech = techs[i];
      final name = tech['name'].toString().split(' ').first;
      final dist = tech['distance'] as double? ?? 1.5;

      // Draw pin marker
      canvas.drawCircle(offset, 9, techPin);
      canvas.drawCircle(offset, 3, centerCore);

      // Draw dynamic distance label on map next to pin
      textPainter.text = TextSpan(
        text: '$name (${dist.toStringAsFixed(1)}km)',
        style: GoogleFonts.inter(
          fontSize: 8,
          fontWeight: FontWeight.w800,
          color: AppColors.onSurface,
          backgroundColor: Colors.white.withOpacity(0.85),
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(offset.dx - textPainter.width / 2, offset.dy - 20));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
