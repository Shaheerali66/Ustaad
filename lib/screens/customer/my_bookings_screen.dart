import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../data/bookings_repository.dart';
import '../../data/technicians_data.dart';
import '../../data/user_database.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Timer? _refreshTimer;

  String _currentView = 'list'; // 'list', 'receipt', 'complaint', 'edit', 'cancel'
  BookingData? _selectedBooking;

  // Complaint submission form state
  final _complaintFormKey = GlobalKey<FormState>();
  String _complaintCategory = 'Poor Service Quality';
  final _complaintDescriptionController = TextEditingController();
  final List<String> _attachedPhotos = [];

  // Edit booking form state
  String? _editedProviderName;
  String? _editedProviderPhoto;
  String? _editedProviderPhone;
  String? _editedDate;
  String? _editedTime;
  final _editedAddressController = TextEditingController();
  final _editedWorkController = TextEditingController();

  // Cancel booking state
  String _cancellationReason = 'Change of Plans';
  final _cancellationNotesController = TextEditingController();

  // Rating state
  double _ratingStars = 5.0;
  final _ratingReviewController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    BookingsRepository.init();
    _refreshTimer = Timer.periodic(const Duration(seconds: 8), (_) async {
      final bSuccess = await BookingsRepository.syncBookingsFromCloud();
      final cSuccess = await BookingsRepository.syncComplaintsFromCloud();
      if ((bSuccess || cSuccess) && mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _tabController.dispose();
    _complaintDescriptionController.dispose();
    _editedAddressController.dispose();
    _editedWorkController.dispose();
    _cancellationNotesController.dispose();
    _ratingReviewController.dispose();
    super.dispose();
  }

  void _backToList() {
    setState(() {
      _currentView = 'list';
      _selectedBooking = null;
    });
  }

  String _calculateCountdown(String dateStr, String timeStr) {
    try {
      final months = {
        'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'may': 5, 'jun': 6,
        'jul': 7, 'aug': 8, 'sep': 9, 'oct': 10, 'nov': 11, 'dec': 12
      };
      final parts = dateStr.replaceAll(',', '').split(' ');
      if (parts.length >= 3) {
        int day = int.parse(parts[0]);
        int month = months[parts[1].substring(0, 3).toLowerCase()] ?? 5;
        int year = int.parse(parts[2]);

        final timeParts = timeStr.split(' ');
        final hm = timeParts[0].split(':');
        int hour = int.parse(hm[0]);
        int minute = int.parse(hm[1]);
        if (timeParts.length > 1 && timeParts[1].toLowerCase() == 'pm' && hour < 12) {
          hour += 12;
        } else if (timeParts.length > 1 && timeParts[1].toLowerCase() == 'am' && hour == 12) {
          hour = 0;
        }

        final bookingDate = DateTime(year, month, day, hour, minute);
        final now = DateTime.now();
        final diff = bookingDate.difference(now);
        if (diff.isNegative) {
          return "Service starting soon";
        }
        final days = diff.inDays;
        final hours = diff.inHours % 24;
        return "Service in $days days, $hours hours";
      }
    } catch (_) {}
    return "Service in 2 days, 4 hours";
  }

  @override
  Widget build(BuildContext context) {
    if (_currentView == 'receipt' && _selectedBooking != null) {
      return _buildReceiptView(_selectedBooking!);
    } else if (_currentView == 'complaint' && _selectedBooking != null) {
      return _buildComplaintView(_selectedBooking!);
    } else if (_currentView == 'edit' && _selectedBooking != null) {
      return _buildEditView(_selectedBooking!);
    } else if (_currentView == 'cancel' && _selectedBooking != null) {
      return _buildCancelView(_selectedBooking!);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuAvYftedLPCJAs_RUUhjyQ4hyPqRfIgNtibPXAtILOlM6X-wwqViIJ1mU8sDcA57992Wa_ZJZEkONXlNQyzOWnerO2pxuOy8KHiygva1BepTsjcuaF5yfEIAhU_7oSEmVOlsuMz6XoJnbW_HzV-lmB6CEhW7uI3Hc1AiF73la1R79VKg-WBwc8DQCSxgbor-D35ZcuRNEkoJqNrguGS6-9q3DYwVni7trO9avClJVMMoDlhmwA3c8YzIXfXs1Z3wd94Vf2AkdtmCbQ'),
            ),
            const Spacer(),
            Text(
              'Khidmat AI',
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary),
            ),
            const Spacer(),
            const Icon(Icons.location_on_outlined, color: AppColors.onSurfaceVariant),
          ],
        ),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Text('My Bookings', style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: Colors.white,
                    unselectedLabelColor: AppColors.onSurfaceVariant,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    dividerColor: Colors.transparent,
                    labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700),
                    tabs: const [
                      Tab(text: 'Past'),
                      Tab(text: 'Current'),
                      Tab(text: 'Upcoming'),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPastBookingsList(),
                _buildCurrentBookingsList(),
                _buildUpcomingBookingsList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- PAST BOOKINGS ---
  Widget _buildPastBookingsList() {
    final list = BookingsRepository.bookings
        .where((b) => b.status == 'Completed' || b.status == 'Cancelled')
        .toList();

    if (list.isEmpty) {
      return _buildEmptyState('No past bookings');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, idx) {
        final b = list[idx];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.surfaceVariant),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: Icon(b.icon, color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(b.title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
                            _buildStatusBadge(b.status),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(b.providerName, style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 12, color: AppColors.onSurfaceVariant),
                            const SizedBox(width: 4),
                            Text('${b.date} • ${b.time}', style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(color: AppColors.surfaceVariant),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Amount Charged', style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(
                        b.status == 'Cancelled' ? 'Rs. 0' : 'Rs. ${b.amount.toStringAsFixed(0)}',
                        style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.onBackground),
                      ),
                    ],
                  ),
                  if (b.rating != null)
                    Row(
                      children: List.generate(5, (i) {
                        return Icon(
                          i < b.rating! ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 18,
                        );
                      }),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _selectedBooking = b;
                          _currentView = 'receipt';
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: Text('View Receipt', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _selectedBooking = b;
                          _currentView = 'complaint';
                          _complaintDescriptionController.clear();
                          _attachedPhotos.clear();
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.error),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: Text('File Complaint', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.error)),
                    ),
                  ),
                  if (b.status == 'Completed' && b.rating == null) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _showRatingDialog(b),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber.shade700,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: Text('Rate Service', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showRatingDialog(BookingData b) {
    _ratingStars = 5.0;
    _ratingReviewController.clear();
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text('Rate Service — ${b.title}', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('How was your service with ${b.providerName}?', style: GoogleFonts.inter(fontSize: 14)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (idx) {
                        final starVal = idx + 1.0;
                        return IconButton(
                          icon: Icon(
                            _ratingStars >= starVal ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 32,
                          ),
                          onPressed: () {
                            setDialogState(() {
                              _ratingStars = starVal;
                            });
                          },
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _ratingReviewController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Write a review (optional)...',
                        hintStyle: GoogleFonts.inter(fontSize: 13),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
                ),
                ElevatedButton(
                  onPressed: () {
                    BookingsRepository.rateBooking(b.id, _ratingStars, _ratingReviewController.text.trim());
                    Navigator.pop(context);
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Thank you for rating!', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('Submit', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // --- CURRENT BOOKINGS ---
  Widget _buildCurrentBookingsList() {
    final list = BookingsRepository.bookings
        .where((b) =>
            b.status == 'Provider Assigned' ||
            b.status == 'Provider On The Way' ||
            b.status == 'Service In Progress' ||
            b.status == 'Awaiting Completion Confirmation')
        .toList();

    if (list.isEmpty) {
      return _buildEmptyState('No active bookings');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, idx) {
        final b = list[idx];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.surfaceVariant),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundImage: NetworkImage(b.providerPhoto),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(b.title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
                            _buildStatusBadge(b.status),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(b.providerName, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Calling ${b.providerName} (${b.providerPhone})...')),
                            );
                          },
                          child: Row(
                            children: [
                              const Icon(Icons.phone, size: 12, color: AppColors.primary),
                              const SizedBox(width: 4),
                              Text(b.providerPhone, style: GoogleFonts.inter(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Timeline Tracker
              _buildTimelineTracker(b.status),
              const SizedBox(height: 16),
              const Divider(color: AppColors.surfaceVariant),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 14, color: AppColors.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(b.location, style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => context.go('/customer/track'),
                      icon: const Icon(Icons.map_outlined, size: 16),
                      label: Text('Track', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary),
                        foregroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Navigate to Chat
                        context.go('/customer/provider-chat', extra: {
                          'id': '101',
                          'name': b.providerName,
                          'category': b.title,
                        });
                      },
                      icon: const Icon(Icons.chat_bubble_outline, size: 16),
                      label: Text('Chat', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary),
                        foregroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (b.status == 'Service In Progress')
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _confirmCompleteBooking(b),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text('Mark as Complete', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  if (b.status == 'Provider Assigned' || b.status == 'Provider On The Way')
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedBooking = b;
                            _currentView = 'cancel';
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text('Emergency Cancel', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700)),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimelineTracker(String status) {
    final steps = [
      'Confirmed',
      'Assigned',
      'On The Way',
      'In Progress',
      'Completed'
    ];

    int activeIdx = 0;
    if (status == 'Confirmed') activeIdx = 0;
    if (status == 'Provider Assigned') activeIdx = 1;
    if (status == 'Provider On The Way') activeIdx = 2;
    if (status == 'Service In Progress') activeIdx = 3;
    if (status == 'Awaiting Completion Confirmation' || status == 'Completed') activeIdx = 4;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Live Status Tracker', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: steps.length,
            itemBuilder: (context, i) {
              final isActive = i <= activeIdx;
              final isLast = i == steps.length - 1;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isActive ? AppColors.primary : Colors.grey.shade300,
                          border: Border.all(
                            color: isActive ? AppColors.primary : Colors.grey.shade400,
                            width: 2,
                          ),
                        ),
                        child: isActive
                            ? const Icon(Icons.check, size: 10, color: Colors.white)
                            : null,
                      ),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: 24,
                          color: isActive && (i < activeIdx) ? AppColors.primary : Colors.grey.shade300,
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        steps[i],
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                          color: isActive ? AppColors.onBackground : AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  void _confirmCompleteBooking(BookingData b) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Confirm Completion', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
          content: Text('Are you sure the service has been completed by ${b.providerName}?', style: GoogleFonts.inter(fontSize: 14)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
            ),
            ElevatedButton(
              onPressed: () {
                BookingsRepository.completeBooking(b.id);
                Navigator.pop(context);
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Service marked as completed!', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Confirm', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
            ),
          ],
        );
      },
    );
  }

  // --- UPCOMING BOOKINGS ---
  Widget _buildUpcomingBookingsList() {
    final list = BookingsRepository.bookings
        .where((b) => b.status == 'Confirmed')
        .toList();

    if (list.isEmpty) {
      return _buildEmptyState('No upcoming bookings');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, idx) {
        final b = list[idx];
        final countdown = _calculateCountdown(b.date, b.time);

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.surfaceVariant),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: NetworkImage(b.providerPhoto),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(b.title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
                            _buildStatusBadge(b.status),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(b.providerName, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.onSurfaceVariant)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.timer_outlined, size: 14, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Text(countdown, style: GoogleFonts.inter(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: AppColors.surfaceVariant),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 14, color: AppColors.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Text('${b.date} at ${b.time}', style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 14, color: AppColors.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(b.location, style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        context.go('/customer/provider-details', extra: {
                          'id': '101',
                          'name': b.providerName,
                          'category': b.title,
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: Text('View Profile', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _selectedBooking = b;
                          _currentView = 'edit';
                          _editedProviderName = b.providerName;
                          _editedProviderPhoto = b.providerPhoto;
                          _editedProviderPhone = b.providerPhone;
                          _editedDate = b.date;
                          _editedTime = b.time;
                          _editedAddressController.text = b.location;
                          _editedWorkController.text = b.workDetails;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: Text('Edit Booking', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedBooking = b;
                          _currentView = 'cancel';
                          _cancellationReason = 'Change of Plans';
                          _cancellationNotesController.clear();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: Text('Cancel', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // --- SUB-SCREEN: DIGITAL RECEIPT ---
  Widget _buildReceiptView(BookingData b) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text('Receipt Details', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _backToList,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 5))
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Receipt Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Service Receipt', style: GoogleFonts.inter(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 4),
                        Text('Khidmat AI', style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.8), fontSize: 13, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const Icon(Icons.receipt_long, color: Colors.white, size: 36),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Booking ID', style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w600)),
                        Text(b.id, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.onBackground)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Service Category', style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w600)),
                        Text(b.title, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Service Provider', style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w600)),
                        Text(b.providerName, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Date & Time', style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w600)),
                        Text('${b.date} at ${b.time}', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Location', style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w600)),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Text(b.location, textAlign: TextAlign.right, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Dashed line
                    _buildDashedLine(),
                    const SizedBox(height: 20),
                    Text('Cost Breakdown', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Base Hourly Rate', style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurfaceVariant)),
                        Text('Rs. ${b.baseRate.toStringAsFixed(0)} / hr', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Duration Worked', style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurfaceVariant)),
                        Text(b.duration, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Additional Charges', style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurfaceVariant)),
                        Text('Rs. ${b.extraCharges.toStringAsFixed(0)}', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildDashedLine(),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Paid', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800)),
                        Text('Rs. ${b.amount.toStringAsFixed(0)}', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.primary)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Payment Method', style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurfaceVariant)),
                        Text(b.paymentMethod, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Payment Status', style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurfaceVariant)),
                        Text('PAID', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.green)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildDashedLine(),
                    const SizedBox(height: 20),
                    Center(
                      child: Column(
                        children: [
                          Text('Thank you for choosing Khidmat AI!', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
                          const SizedBox(height: 4),
                          Text('Smart Service, Delivered.', style: GoogleFonts.inter(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Receipt PDF saved to Downloads successfully!', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                                  backgroundColor: Colors.green,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            icon: const Icon(Icons.download, size: 18),
                            label: Text('Download', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Sharing receipt via WhatsApp...', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                                  backgroundColor: AppColors.primary,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            icon: const Icon(Icons.share, size: 18),
                            label: Text('Share', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.primary),
                              foregroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: _backToList,
                        child: Text('Close Receipt', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashedLine() {
    return Row(
      children: List.generate(
        30,
        (index) => Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            height: 1,
            color: Colors.grey.shade300,
          ),
        ),
      ),
    );
  }

  // --- SUB-SCREEN: COMPLAINT SUBMISSION ---
  Widget _buildComplaintView(BookingData b) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('File a Complaint', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _backToList,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _complaintFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Booking summary block
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Booking Reference', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.onSurfaceVariant)),
                    const SizedBox(height: 6),
                    Text('${b.title} (${b.id})', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text('Provider: ${b.providerName}', style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w600)),
                    Text('Service Date: ${b.date}', style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Select Complaint Category *'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _complaintCategory,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: [
                  'Poor Service Quality',
                  'Provider Did Not Show Up',
                  'Overcharging',
                  'Unprofessional Behavior',
                  'Property Damage',
                  'Other'
                ].map((category) {
                  return DropdownMenuItem(value: category, child: Text(category, style: GoogleFonts.inter(fontSize: 14)));
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _complaintCategory = val;
                    });
                  }
                },
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Describe Your Issue *'),
              const SizedBox(height: 4),
              Text(
                'Please provide a detailed description (minimum 20 characters).',
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _complaintDescriptionController,
                maxLines: 5,
                minLines: 3,
                maxLength: 500,
                decoration: InputDecoration(
                  hintText: 'Please describe your issue in detail...',
                  hintStyle: GoogleFonts.inter(fontSize: 13),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter a description';
                  }
                  if (val.trim().length < 20) {
                    return 'Description must be at least 20 characters long';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Photo Evidence (Optional, max 3)'),
              const SizedBox(height: 12),
              Row(
                children: [
                  ...List.generate(_attachedPhotos.length, (idx) {
                    return Container(
                      width: 72,
                      height: 72,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                        image: DecorationImage(
                          image: NetworkImage(_attachedPhotos[idx]),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _attachedPhotos.removeAt(idx);
                            });
                          },
                          child: Container(
                            decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                            padding: const EdgeInsets.all(4),
                            child: const Icon(Icons.close, size: 12, color: Colors.white),
                          ),
                        ),
                      ),
                    );
                  }),
                  if (_attachedPhotos.length < 3)
                    InkWell(
                      onTap: () {
                        // Simulate attaching photo evidence
                        final mocks = [
                          'https://images.unsplash.com/photo-1581092921461-eab62e97a780?w=150',
                          'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=150',
                          'https://images.unsplash.com/photo-1504328345606-18bbc8c9d7d1?w=150'
                        ];
                        setState(() {
                          _attachedPhotos.add(mocks[_attachedPhotos.length % mocks.length]);
                        });
                      },
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                        ),
                        child: const Icon(Icons.add_a_photo_outlined, color: AppColors.primary),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 36),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    if (_complaintFormKey.currentState?.validate() ?? false) {
                      final newComp = {
                        'id': 'CMP-${(DateTime.now().millisecondsSinceEpoch % 10000).toString()}',
                        'bookingId': b.id,
                        'customerName': UserDatabase.currentUser?['fullName'] ?? 'Ahmed Ali',
                        'providerName': b.providerName,
                        'serviceDate': b.date,
                        'category': _complaintCategory,
                        'description': _complaintDescriptionController.text.trim(),
                        'photoEvidence': List<String>.from(_attachedPhotos),
                        'submissionDate': '20 May 2026',
                        'status': 'Under Review',
                        'resolutionNotes': '',
                      };
                      BookingsRepository.addComplaint(newComp);
                      _backToList();
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          title: Text('Complaint Submitted', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                          content: Text('Your complaint has been submitted. Our team will review it within 24 hours and get back to you.', style: GoogleFonts.inter(fontSize: 14, height: 1.4)),
                          actions: [
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                              ),
                              child: Text('OK', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Submit Complaint', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: _backToList,
                  child: Text('Cancel', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- SUB-SCREEN: EDIT BOOKING ---
  Widget _buildEditView(BookingData b) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Edit Your Booking', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _backToList,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current booking info block
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Current Booking', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: 4),
                  Text('${b.title} (${b.id})', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700)),
                  Text('Assigned: ${_editedProviderName ?? b.providerName}', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Change Service Provider'),
            const SizedBox(height: 8),
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage(_editedProviderPhoto ?? b.providerPhoto),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_editedProviderName ?? b.providerName, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700)),
                      Text('Assigned Technician', style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant)),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _showAlternativeProvidersDialog(b),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('Change', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Change Date'),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () async {
                          final selected = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now().add(const Duration(days: 1)),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 30)),
                          );
                          if (selected != null) {
                            final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                            setState(() {
                              _editedDate = '${selected.day} ${monthNames[selected.month - 1]} ${selected.year}';
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade400),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_editedDate ?? b.date, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
                              const Icon(Icons.calendar_month, color: AppColors.primary, size: 20),
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
                      _buildSectionTitle('Change Time'),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () async {
                          final selected = await showTimePicker(
                            context: context,
                            initialTime: const TimeOfDay(hour: 10, minute: 0),
                          );
                          if (selected != null) {
                            setState(() {
                              _editedTime = selected.format(context);
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade400),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_editedTime ?? b.time, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
                              const Icon(Icons.access_time, color: AppColors.primary, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Update Service Location Address'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _editedAddressController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Update Work Details'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _editedWorkController,
              maxLines: 3,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 36),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  BookingsRepository.editBooking(
                    b.id,
                    providerName: _editedProviderName,
                    date: _editedDate,
                    time: _editedTime,
                    address: _editedAddressController.text.trim(),
                    workDetails: _editedWorkController.text.trim(),
                  );
                  // Update current selected booking reference photo/phone if changed
                  if (_editedProviderName != null) {
                    final index = BookingsRepository.bookings.indexWhere((item) => item.id == b.id);
                    if (index != -1) {
                      BookingsRepository.updateBooking(
                        BookingsRepository.bookings[index].copyWith(
                          providerPhoto: _editedProviderPhoto,
                          providerPhone: _editedProviderPhone,
                        ),
                      );
                    }
                  }
                  _backToList();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Your booking has been updated successfully. Provider has been notified.', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Save Changes', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: _backToList,
                child: Text('Cancel', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAlternativeProvidersDialog(BookingData b) {
    // Fetch some alternate technicians matching the category
    final alternates = TechnicianDataset.technicians
        .where((t) => t['category'].toString().toLowerCase().contains(b.title.toLowerCase().split(' ')[0]))
        .take(5)
        .toList();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Select Alternative Provider', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text('Choosing a different technician will re-assign this service booking.', style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant)),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: alternates.length,
                  itemBuilder: (context, idx) {
                    final t = alternates[idx];
                    final name = t['name'].toString();
                    final rating = t['rating'].toString();
                    final rate = t['hourlyRate'].toString();

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 4),
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage('https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150'),
                      ),
                      title: Text(name, style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                      subtitle: Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 14),
                          const SizedBox(width: 2),
                          Text('$rating • Rs. $rate / hr', style: GoogleFonts.inter(fontSize: 12)),
                        ],
                      ),
                      trailing: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _editedProviderName = name;
                            _editedProviderPhoto = 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150';
                            _editedProviderPhone = t['phone'] ?? '0345-1122334';
                          });
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text('Select', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700)),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- SUB-SCREEN: CANCEL BOOKING ---
  Widget _buildCancelView(BookingData b) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Cancel Booking', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _backToList,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Booking summary
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Booking Reference', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: 6),
                  Text('${b.title} (${b.id})', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700)),
                  Text('Provider: ${b.providerName}', style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w600)),
                  Text('Scheduled: ${b.date} at ${b.time}', style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Select Cancellation Reason *'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _cancellationReason,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: [
                'Change of Plans',
                'Found Another Provider',
                'Service No Longer Needed',
                'Wrong Booking Details',
                'Provider Requested Cancellation',
                'Other'
              ].map((reason) {
                return DropdownMenuItem(value: reason, child: Text(reason, style: GoogleFonts.inter(fontSize: 14)));
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _cancellationReason = val;
                  });
                }
              },
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Additional Comments (Optional)'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _cancellationNotesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Provide additional details...',
                hintStyle: GoogleFonts.inter(fontSize: 13),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
            // Policy box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.errorContainer.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, color: AppColors.error, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Cancellation Policy', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.error)),
                        const SizedBox(height: 4),
                        Text(
                          'Cancellations made more than 2 hours before the scheduled time are free. Cancellations made less than 2 hours before may result in a cancellation fee. (Simulated)',
                          style: GoogleFonts.inter(fontSize: 12, height: 1.4, color: AppColors.error, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  BookingsRepository.cancelBooking(
                    b.id,
                    _cancellationReason,
                    _cancellationNotesController.text.trim(),
                  );
                  _backToList();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Your booking has been cancelled. Provider has been notified.', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                      backgroundColor: Colors.grey.shade800,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Confirm Cancellation', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: _backToList,
                child: Text('Go Back', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- COMMON WIDGETS ---
  Widget _buildEmptyState(String text) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(text, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg = AppColors.primary.withValues(alpha: 0.15);
    Color fg = AppColors.primary;

    if (status == 'Completed') {
      bg = Colors.green.withValues(alpha: 0.15);
      fg = Colors.green;
    } else if (status == 'Cancelled') {
      bg = Colors.grey.withValues(alpha: 0.15);
      fg = Colors.grey.shade700;
    } else if (status == 'Service In Progress') {
      bg = Colors.blue.withValues(alpha: 0.15);
      fg = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: fg),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.onBackground),
    );
  }
}
