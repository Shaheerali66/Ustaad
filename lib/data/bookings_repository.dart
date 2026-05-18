import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class BookingData {
  final String title;
  final String provider;
  final String date;
  final String status;
  final Color statusColor;
  final String action;
  final IconData icon;

  const BookingData({
    required this.title,
    required this.provider,
    required this.date,
    required this.status,
    required this.statusColor,
    required this.action,
    required this.icon,
  });
}

class BookingsRepository {
  static final List<BookingData> bookings = [
    BookingData(
      title: 'AC Servicing',
      provider: 'Provider: Ali Ansari',
      date: 'Today, 2:00 PM',
      status: 'Confirmed',
      statusColor: AppColors.primary,
      action: 'Track',
      icon: Icons.hvac,
    ),
    BookingData(
      title: 'Wiring Check',
      provider: 'Provider: Usman Electric',
      date: 'Monday',
      status: 'Completed',
      statusColor: AppColors.onSurfaceVariant,
      action: 'View Receipt',
      icon: Icons.electrical_services,
    ),
    BookingData(
      title: 'Home Cleaning',
      provider: 'Finding Provider...',
      date: 'Wednesday',
      status: 'Pending',
      statusColor: AppColors.tertiary,
      action: 'Edit Details',
      icon: Icons.cleaning_services,
    ),
  ];

  static void addBooking(BookingData booking) {
    bookings.insert(0, booking);
  }
}
