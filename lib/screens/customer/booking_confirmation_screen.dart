import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../data/bookings_repository.dart';
import '../../utils/google_maps_service.dart';
import '../../widgets/google_map_widget.dart';

class BookingConfirmationScreen extends StatefulWidget {
  const BookingConfirmationScreen({super.key});

  @override
  State<BookingConfirmationScreen> createState() => _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  double _centerLat = 33.6844;
  double _centerLng = 73.0479;
  List<Map<String, dynamic>> _markers = [];

  @override
  void initState() {
    super.initState();
    _initMapCoordinates();
  }

  void _initMapCoordinates() async {
    final latest = BookingsRepository.bookings.isNotEmpty 
        ? BookingsRepository.bookings.first 
        : null;
    final addressText = latest?.location ?? 'House 12, Street 4, Sector G-13, Islamabad';
    
    // Default fallback coordinates: Islamabad
    double initLat = 33.6844;
    double initLng = 73.0479;
    final lower = addressText.toLowerCase();
    if (lower.contains('lahore')) {
      initLat = 31.5204;
      initLng = 74.3587;
    } else if (lower.contains('karachi')) {
      initLat = 24.8607;
      initLng = 67.0011;
    } else if (lower.contains('hyderabad')) {
      initLat = 25.3960;
      initLng = 68.3578;
    }

    setState(() {
      _centerLat = initLat;
      _centerLng = initLng;
      _markers = [
        {'lat': initLat, 'lng': initLng, 'title': 'Service Location'}
      ];
    });

    final result = await GoogleMapsService.geocodeAddress(addressText);
    if (result != null && mounted) {
      setState(() {
        _centerLat = result['lat'] as double;
        _centerLng = result['lng'] as double;
        _markers = [
          {'lat': _centerLat, 'lng': _centerLng, 'title': 'Service Location'}
        ];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final latest = BookingsRepository.bookings.isNotEmpty 
        ? BookingsRepository.bookings.first 
        : null;
    
    final receiptId = latest?.id ?? '#KAI-20240517-001';
    final serviceTitle = latest?.title ?? 'AC Technician';
    final providerName = latest?.provider ?? 'Ali AC Services';
    final serviceTime = latest?.time ?? 'Tomorrow, 10:00 AM';
    final amount = latest?.amount ?? 3500.0;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            const SizedBox(height: 40),
            Container(width: 80, height: 80, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.secondaryContainer.withValues(alpha: 0.3)), child: const Icon(Icons.check_circle, size: 48, color: AppColors.secondary)),
            const SizedBox(height: 16),
            Text('Booking Confirmed!', style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.secondary)),
            const SizedBox(height: 8),
            Text('Booking logged to system — Provider notified', style: GoogleFonts.inter(fontSize: 16, color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 24),
            // AI Orchestration
            Container(
              width: double.infinity, padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppColors.surfaceContainerLowest, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.surfaceVariant)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('AI Orchestration', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                _step('Assigning provider', 'Done'), _step('Scheduling slot', 'Done', sub: serviceTime), _step('Creating booking record', 'Done'), _step('Sending confirmation', 'Done'),
              ]),
            ),
            const SizedBox(height: 16),
            // Receipt
            Container(
              width: double.infinity, padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.primary, width: 2)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('RECEIPT ID', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.onSurfaceVariant, letterSpacing: 1)),
                    Text(receiptId, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700)),
                  ]),
                  const Spacer(),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: AppColors.secondaryContainer.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(9999)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.secondary)), const SizedBox(width: 6), Text('CONFIRMED', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.secondary))])),
                ]),
                const SizedBox(height: 16),
                _infoRow(Icons.ac_unit, 'Service', serviceTitle, AppColors.primary),
                const SizedBox(height: 12),
                _infoRow(Icons.circle, 'Provider', providerName, AppColors.tertiary, trailing: '★ 4.8'),
                const SizedBox(height: 12),
                _infoRow(Icons.access_time, 'Time', serviceTime, AppColors.onSurfaceVariant),
              ]),
            ),
            const SizedBox(height: 16),
            // Real Google Map
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surfaceVariant),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: GoogleMapWidget(
                  centerLat: _centerLat,
                  centerLng: _centerLng,
                  zoom: 14,
                  markers: _markers,
                  height: 180,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(onPressed: () => context.go('/customer/bookings'), icon: const Icon(Icons.event_note), label: Text('View My Bookings', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600))),
            const SizedBox(height: 12),
            OutlinedButton.icon(onPressed: () => context.go('/customer/home'), icon: const Icon(Icons.home, color: AppColors.primary), label: Text('Back to Home', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primary)), style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.primary))),
            const SizedBox(height: 24),
          ]),
        ),
      ),
    );
  }

  Widget _step(String title, String status, {String? sub}) {
    return Padding(padding: const EdgeInsets.only(bottom: 16), child: Row(children: [
      const Icon(Icons.check_circle, size: 24, color: AppColors.secondary),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
        if (sub != null) Text(sub, style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant)),
      ])),
      Text(status, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.secondary)),
    ]));
  }

  Widget _infoRow(IconData icon, String label, String value, Color iconColor, {String? trailing}) {
    return Row(children: [
      Container(width: 40, height: 40, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.surfaceContainerHigh), child: Icon(icon, size: 20, color: iconColor)),
      const SizedBox(width: 12),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant)),
        Text(value, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
      ]),
      if (trailing != null) ...[const Spacer(), Text(trailing, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.tertiaryFixedDim))],
    ]);
  }
}
