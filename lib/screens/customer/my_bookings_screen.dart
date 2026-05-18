import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../data/bookings_repository.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(backgroundColor: AppColors.surface, surfaceTintColor: Colors.transparent, title: Row(children: [const CircleAvatar(radius: 16, backgroundImage: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuAvYftedLPCJAs_RUUhjyQ4hyPqRfIgNtibPXAtILOlM6X-wwqViIJ1mU8sDcA57992Wa_ZJZEkONXlNQyzOWnerO2pxuOy8KHiygva1BepTsjcuaF5yfEIAhU_7oSEmVOlsuMz6XoJnbW_HzV-lmB6CEhW7uI3Hc1AiF73la1R79VKg-WBwc8DQCSxgbor-D35ZcuRNEkoJqNrguGS6-9q3DYwVni7trO9avClJVMMoDlhmwA3c8YzIXfXs1Z3wd94Vf2AkdtmCbQ')), const Spacer(), Text('Khidmat AI', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary)), const Spacer(), const Icon(Icons.location_on_outlined, color: AppColors.onSurfaceVariant)]), automaticallyImplyLeading: false),
      body: DefaultTabController(
        length: 3,
        child: Column(children: [
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 16),
            Text('My Bookings', style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            TabBar(
              labelColor: AppColors.primary, unselectedLabelColor: AppColors.onSurfaceVariant,
              indicatorColor: AppColors.primary, indicatorWeight: 3,
              labelStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
              tabs: const [Tab(text: 'All'), Tab(text: 'Active'), Tab(text: 'Completed')],
            ),
          ])),
          Expanded(child: TabBarView(children: [
            _bookingsList(), _bookingsList(filter: 'active'), _bookingsList(filter: 'completed'),
          ])),
        ]),
      ),
    );
  }

  Widget _bookingsList({String? filter}) {
    final bookings = BookingsRepository.bookings;
    final filtered = filter == 'active'
        ? bookings.where((b) => b.status == 'Confirmed' || b.status == 'Pending').toList()
        : filter == 'completed'
            ? bookings.where((b) => b.status == 'Completed').toList()
            : bookings;
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (context, i) => _bookingCard(context, filtered[i]),
    );
  }

  Widget _bookingCard(BuildContext context, BookingData b) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surfaceContainerLowest, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.surfaceVariant)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(b.title, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600))),
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: b.statusColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(9999)), child: Text(b.status, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: b.statusColor))),
        ]),
        const SizedBox(height: 4),
        Row(children: [const Icon(Icons.person_outline, size: 16, color: AppColors.onSurfaceVariant), const SizedBox(width: 4), Text(b.provider, style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurfaceVariant))]),
        const SizedBox(height: 8),
        Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(8)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.calendar_today, size: 14, color: AppColors.onSurfaceVariant), const SizedBox(width: 6), Text(b.date, style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurfaceVariant))])),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              if (b.action == 'Track') {
                context.go('/customer/track');
              } else if (b.action == 'View Receipt') {
                context.go('/customer/booking-confirmed');
              }
            },
            style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.primary), minimumSize: const Size(0, 44)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (b.action == 'Track') ...[
                  const Icon(Icons.my_location, size: 18, color: AppColors.primary),
                  const SizedBox(width: 8),
                ],
                Text(b.action, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}

