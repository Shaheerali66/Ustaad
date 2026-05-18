import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../data/technicians_data.dart';
import '../../data/bookings_repository.dart';
import '../../data/document_database.dart';

class ProviderDiscoveryScreen extends StatelessWidget {
  final Map<String, dynamic>? bookingDetails;

  const ProviderDiscoveryScreen({super.key, this.bookingDetails});

  @override
  Widget build(BuildContext context) {
    final selectedCategory = (bookingDetails?['service'] ?? 'AC Services').toString();
    final locationText = (bookingDetails?['location'] ?? 'Sector G-13, Islamabad').toString();
    final workText = (bookingDetails?['work'] ?? 'AC servicing and cleaning').toString();
    final timeText = (bookingDetails?['time'] ?? 'Tomorrow Morning (~10:00 AM)').toString();

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
      // Fallback area based detection in location/work texts
      if (lowerLoc.contains('gulberg') || lowerLoc.contains('model') || lowerLoc.contains('johar') ||
          lowerWork.contains('gulberg') || lowerWork.contains('model') || lowerWork.contains('johar')) {
        targetCity = 'Lahore';
      } else if (lowerLoc.contains('clifton') || lowerLoc.contains('gulshan') || lowerLoc.contains('saddar') ||
                 lowerWork.contains('clifton') || lowerWork.contains('gulshan') || lowerWork.contains('saddar')) {
        targetCity = 'Karachi';
      } else if (lowerLoc.contains('latifabad') || lowerWork.contains('latifabad')) {
        targetCity = 'Hyderabad';
      } else if (lowerLoc.contains('g-13') || lowerLoc.contains('f-10') || lowerLoc.contains('f-8') ||
                 lowerWork.contains('g-13') || lowerWork.contains('f-10') || lowerWork.contains('f-8')) {
        targetCity = 'Islamabad';
      }
    }

    // Filter technicians STRICTLY based on the targeted City first (Mandatory)
    List<Map<String, dynamic>> filteredTechs = [];
    
    // Add default seeds from Excel
    filteredTechs.addAll(TechnicianDataset.technicians.where((tech) {
      final city = (tech['city'] ?? '').toString().toLowerCase();
      return city == targetCity.toLowerCase();
    }));

    // Add Approved Dynamic Cloud Onboarded Technicians!
    final dynamicTechs = DocumentDatabase.onboardedTechnicians.where((tech) {
      final city = (tech['city'] ?? 'Islamabad').toString().toLowerCase();
      final isApproved = tech['status'] == 'Approved';
      return isApproved && city == targetCity.toLowerCase();
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

    filteredTechs.addAll(dynamicTechs);

    // Among those strictly in this city, filter strictly by Category or SubService
    filteredTechs = filteredTechs.where((tech) {
      final techCat = (tech['category'] ?? '').toString().toLowerCase();
      final targetCat = selectedCategory.toLowerCase();
      final matchCat = (tech['matchCategory'] ?? '').toString().toLowerCase();
      
      return techCat == targetCat || matchCat == targetCat || techCat.contains(targetCat) || targetCat.contains(techCat);
    }).toList();

    // Sort technicians based on AI ranking: ratings (highest first), completed jobs (highest first), experience (highest first), then hourlyRate (lowest first)
    filteredTechs.sort((a, b) {
      final aRating = double.tryParse(a['rating']?.toString() ?? '') ?? 0.0;
      final bRating = double.tryParse(b['rating']?.toString() ?? '') ?? 0.0;
      if (aRating != bRating) {
        return bRating.compareTo(aRating);
      }

      final aJobs = int.tryParse(a['completedJobs']?.toString() ?? '') ?? 0;
      final bJobs = int.tryParse(b['completedJobs']?.toString() ?? '') ?? 0;
      if (aJobs != bJobs) {
        return bJobs.compareTo(aJobs);
      }

      final aExp = int.tryParse(a['experience']?.toString() ?? '') ?? 0;
      final bExp = int.tryParse(b['experience']?.toString() ?? '') ?? 0;
      if (aExp != bExp) {
        return bExp.compareTo(aExp);
      }

      final aRate = double.tryParse(a['hourlyRate']?.toString() ?? '') ?? 1000.0;
      final bRate = double.tryParse(b['hourlyRate']?.toString() ?? '') ?? 1000.0;
      return aRate.compareTo(bRate);
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.onSurfaceVariant),
              onPressed: () => context.go('/customer/home'),
            ),
            const Spacer(),
            Text('Khidmat AI Matches', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary)),
            const Spacer(),
            const Icon(Icons.location_on_outlined, color: AppColors.onSurfaceVariant),
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
                gradient: LinearGradient(colors: [AppColors.primary, AppColors.surfaceTint]),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 8, offset: const Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'AI MATCH CRITERIA',
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white.withValues(alpha: 0.8), letterSpacing: 1.0),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Service: $selectedCategory', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text(locationText, style: GoogleFonts.inter(fontSize: 13, color: Colors.white.withValues(alpha: 0.9))),
                      const Spacer(),
                      const Icon(Icons.access_time, color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text(timeText, style: GoogleFonts.inter(fontSize: 13, color: Colors.white.withValues(alpha: 0.9))),
                    ],
                  ),
                ],
              ),
            ),

            Text('Verified AI Recommendations', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.onBackground)),
            const SizedBox(height: 4),
            Text(
              'Found ${filteredTechs.length} certified ${selectedCategory.toLowerCase()} professionals in $targetCity area.',
              style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            
            if (filteredTechs.isEmpty)
              _buildNoResultsState(targetCity)
            else ...[
              // Map location visualization
              Container(
                height: 160,
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
                        size: const Size(double.infinity, 160),
                        painter: _MiniMapPainter(filteredTechs.length),
                      ),
                    ),
                    Positioned(
                      bottom: 12, left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.surfaceVariant)),
                        child: Row(
                          children: [
                            const Icon(Icons.gps_fixed, size: 14, color: AppColors.primary),
                            const SizedBox(width: 6),
                            Text('Simulated GPS Radar Active', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),

              // Horizontal Scrollable Filter Bar matching the HTML mockup design
              _buildFilterBar(),

              // Provider cards
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

  Widget _providerCard({
    required BuildContext context,
    required Map<String, dynamic> tech,
    required String name,
    required double rating,
    required int experience,
    required int jobs,
    required int rate,
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
    // Generate initials for avatar fallback (extremely crash-proof)
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

    // Beautiful matching avatar color depending on name
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
          if (isBestMatch) ...[
            Row(
              children: [
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
                const Spacer(),
              ],
            ),
            const SizedBox(height: 12),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: avatarColor.withValues(alpha: 0.15),
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
                    Text(name, style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 15, color: Colors.amber),
                        const SizedBox(width: 2),
                        Text('$rating', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
                        Text(' • ', style: GoogleFonts.inter(color: AppColors.onSurfaceVariant)),
                        Text('$experience yrs exp', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
                        Text(' • ', style: GoogleFonts.inter(color: AppColors.onSurfaceVariant)),
                        Text('$jobs jobs completed', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.secondary)),
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
                            style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w500),
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
          
          // Badge row
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
                _verifBadge('Available Today', AppColors.primary, AppColors.primaryContainer.withValues(alpha: 0.15)),
            ],
          ),

          // Dynamic AI Recommendation Box ("Why Recommended") from the mockup
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F7FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withOpacity(0.08)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lightbulb_outline, size: 18, color: Colors.amber),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.inter(fontSize: 12, height: 1.4, color: AppColors.onSurface),
                      children: [
                        TextSpan(
                          text: 'Why Recommended: ',
                          style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppColors.primary),
                        ),
                        TextSpan(
                          text: name.contains("Ali")
                              ? "Highly rated for punctuality and specializes in split AC maintenance. $jobs successful jobs in your area this month."
                              : name.contains("Bilal")
                                  ? "Recognized for rapid response and specialized diagnostic tools. $jobs successful jobs completed in Lahore."
                                  : "Highly rated for premium $subService. $jobs successful jobs completed with $rating star average.",
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 24, color: AppColors.surfaceVariant),

          // Price & Full-Width Action Buttons Row side-by-side
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('HOURLY RATE', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant, letterSpacing: 0.5)),
                  Text(
                    'Rs. $rate / hr',
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primary),
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
                          final catLower = (tech['category'] ?? '').toString().toLowerCase();
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
                              title: tech['category']?.toString() ?? 'Service Match',
                              provider: 'Provider: $name',
                              date: 'Tomorrow, 10:00 AM',
                              status: 'Confirmed',
                              statusColor: AppColors.primary,
                              action: 'Track',
                              icon: catIcon,
                            ),
                          );

                          context.go('/customer/bookings');
                        },
                        icon: const Icon(Icons.calendar_month, size: 14, color: Colors.white),
                        label: Text('Book Now', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 12)),
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
                          style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 12, color: const Color(0xFF00714C)),
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
        style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }

  Widget _buildFilterBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          children: [
            _filterChip(Icons.tune, 'Filters', active: true),
            const SizedBox(width: 8),
            _filterChip(Icons.expand_more, 'Distance', trailing: true),
            const SizedBox(width: 8),
            _filterChip(null, 'Rating 4.0+'),
            const SizedBox(width: 8),
            _filterChip(Icons.expand_more, 'Availability', trailing: true),
            const SizedBox(width: 8),
            _filterChip(Icons.expand_more, 'Price', trailing: true),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(IconData? icon, String label, {bool active = false, bool trailing = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: active ? AppColors.primaryContainer.withOpacity(0.15) : AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: active ? AppColors.primary : AppColors.outlineVariant,
          width: active ? 1.5 : 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null && !trailing) ...[
            Icon(icon, size: 16, color: active ? AppColors.primary : AppColors.onSurfaceVariant),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: active ? AppColors.primary : AppColors.onSurfaceVariant,
            ),
          ),
          if (icon != null && trailing) ...[
            const SizedBox(width: 4),
            Icon(icon, size: 16, color: AppColors.onSurfaceVariant),
          ],
        ],
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
            color: Colors.black.withValues(alpha: 0.02),
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
              color: AppColors.errorContainer.withValues(alpha: 0.15),
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
            'No Results Found in $city',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.onBackground,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'We currently do not have any registered service providers for this service in the $city area. Please try a different service or check back later.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.onSurfaceVariant,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), offset: const Offset(0, -2), blurRadius: 4)],
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

class _MiniMapPainter extends CustomPainter {
  final int count;
  const _MiniMapPainter(this.count);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.surfaceContainerLowest
      ..style = PaintingStyle.fill;
    canvas.drawRect(Offset.zero & size, paint);

    // Draw route grids
    final linePaint = Paint()
      ..color = AppColors.surfaceVariant
      ..strokeWidth = 1.0;

    for (double i = 0; i < size.width; i += 40) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), linePaint);
    }
    for (double i = 0; i < size.height; i += 40) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), linePaint);
    }

    // Draw secondary map roads
    final roadPaint = Paint()
      ..color = AppColors.surfaceVariant.withValues(alpha: 0.7)
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(20, 20), Offset(size.width - 20, size.height - 20), roadPaint);
    canvas.drawLine(Offset(size.width - 20, 20), Offset(20, size.height - 20), roadPaint);

    // Draw primary blue match pin
    final centerPin = Paint()..color = AppColors.primary;
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 12, centerPin);
    final centerCore = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 5, centerCore);

    // Draw nearby technician pins based on count
    final techPin = Paint()..color = AppColors.secondary;
    final pinOffsets = [
      Offset(size.width / 2 - 50, size.height / 2 - 30),
      Offset(size.width / 2 + 60, size.height / 2 + 20),
      Offset(size.width / 2 - 30, size.height / 2 + 40),
      Offset(size.width / 2 + 40, size.height / 2 - 50),
    ];

    for (int i = 0; i < count.clamp(1, 4); i++) {
      canvas.drawCircle(pinOffsets[i], 8, techPin);
      canvas.drawCircle(pinOffsets[i], 3, centerCore);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
