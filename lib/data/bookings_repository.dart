import 'dart:convert';
import 'platform_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../theme/app_colors.dart';

class BookingData {
  final String id;
  final String title;
  final String provider;
  final String date;
  final String status;
  final Color statusColor;
  final String action;
  final IconData icon;

  // Rich metadata fields
  final String providerName;
  final String providerPhoto;
  final String providerPhone;
  final String time;
  final String location;
  final double amount;
  final double baseRate;
  final double hoursWorked;
  final double extraCharges;
  final String paymentMethod;
  final String duration;
  final String workDetails;
  final double? rating;
  final String? review;
  final String? cancellationReason;
  final String? cancellationNotes;

  const BookingData({
    this.id = '',
    required this.title,
    required this.provider,
    required this.date,
    required this.status,
    required this.statusColor,
    required this.action,
    required this.icon,
    this.providerName = 'Ali Ansari',
    this.providerPhoto = 'https://lh3.googleusercontent.com/aida-public/AB6AXuAvYftedLPCJAs_RUUhjyQ4hyPqRfIgNtibPXAtILOlM6X-wwqViIJ1mU8sDcA57992Wa_ZJZEkONXlNQyzOWnerO2pxuOy8KHiygva1BepTsjcuaF5yfEIAhU_7oSEmVOlsuMz6XoJnbW_HzV-lmB6CEhW7uI3Hc1AiF73la1R79VKg-WBwc8DQCSxgbor-D35ZcuRNEkoJqNrguGS6-9q3DYwVni7trO9avClJVMMoDlhmwA3c8YzIXfXs1Z3wd94Vf2AkdtmCbQ',
    this.providerPhone = '0300-1234567',
    this.time = '10:00 AM',
    this.location = 'House 12, Street 4, Sector G-13, Islamabad',
    this.amount = 3500.0,
    this.baseRate = 1200.0,
    this.hoursWorked = 2.5,
    this.extraCharges = 500.0,
    this.paymentMethod = 'Cash on Completion',
    this.duration = '2.5 Hours',
    this.workDetails = 'AC servicing and deep cleaning',
    this.rating,
    this.review,
    this.cancellationReason,
    this.cancellationNotes,
  });

  BookingData copyWith({
    String? id,
    String? title,
    String? provider,
    String? date,
    String? status,
    Color? statusColor,
    String? action,
    IconData? icon,
    String? providerName,
    String? providerPhoto,
    String? providerPhone,
    String? time,
    String? location,
    double? amount,
    double? baseRate,
    double? hoursWorked,
    double? extraCharges,
    String? paymentMethod,
    String? duration,
    String? workDetails,
    double? rating,
    String? review,
    String? cancellationReason,
    String? cancellationNotes,
  }) {
    return BookingData(
      id: id ?? this.id,
      title: title ?? this.title,
      provider: provider ?? this.provider,
      date: date ?? this.date,
      status: status ?? this.status,
      statusColor: statusColor ?? this.statusColor,
      action: action ?? this.action,
      icon: icon ?? this.icon,
      providerName: providerName ?? this.providerName,
      providerPhoto: providerPhoto ?? this.providerPhoto,
      providerPhone: providerPhone ?? this.providerPhone,
      time: time ?? this.time,
      location: location ?? this.location,
      amount: amount ?? this.amount,
      baseRate: baseRate ?? this.baseRate,
      hoursWorked: hoursWorked ?? this.hoursWorked,
      extraCharges: extraCharges ?? this.extraCharges,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      duration: duration ?? this.duration,
      workDetails: workDetails ?? this.workDetails,
      rating: rating ?? this.rating,
      review: review ?? this.review,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      cancellationNotes: cancellationNotes ?? this.cancellationNotes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'provider': provider,
      'date': date,
      'status': status,
      'statusColorValue': statusColor.value,
      'action': action,
      'iconName': _getStringFromIcon(icon),
      'providerName': providerName,
      'providerPhoto': providerPhoto,
      'providerPhone': providerPhone,
      'time': time,
      'location': location,
      'amount': amount,
      'baseRate': baseRate,
      'hoursWorked': hoursWorked,
      'extraCharges': extraCharges,
      'paymentMethod': paymentMethod,
      'duration': duration,
      'workDetails': workDetails,
      'rating': rating,
      'review': review,
      'cancellationReason': cancellationReason,
      'cancellationNotes': cancellationNotes,
    };
  }

  factory BookingData.fromJson(Map<String, dynamic> json) {
    return BookingData(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      provider: json['provider'] ?? '',
      date: json['date'] ?? '',
      status: json['status'] ?? '',
      statusColor: Color(json['statusColorValue'] ?? AppColors.primary.value),
      action: json['action'] ?? '',
      icon: _getIconFromString(json['iconName'] ?? ''),
      providerName: json['providerName'] ?? 'Ali Ansari',
      providerPhoto: json['providerPhoto'] ?? 'https://lh3.googleusercontent.com/aida-public/AB6AXuAvYftedLPCJAs_RUUhjyQ4hyPqRfIgNtibPXAtILOlM6X-wwqViIJ1mU8sDcA57992Wa_ZJZEkONXlNQyzOWnerO2pxuOy8KHiygva1BepTsjcuaF5yfEIAhU_7oSEmVOlsuMz6XoJnbW_HzV-lmB6CEhW7uI3Hc1AiF73la1R79VKg-WBwc8DQCSxgbor-D35ZcuRNEkoJqNrguGS6-9q3DYwVni7trO9avClJVMMoDlhmwA3c8YzIXfXs1Z3wd94Vf2AkdtmCbQ',
      providerPhone: json['providerPhone'] ?? '0300-1234567',
      time: json['time'] ?? '10:00 AM',
      location: json['location'] ?? 'House 12, Street 4, Sector G-13, Islamabad',
      amount: (json['amount'] as num?)?.toDouble() ?? 3500.0,
      baseRate: (json['baseRate'] as num?)?.toDouble() ?? 1200.0,
      hoursWorked: (json['hoursWorked'] as num?)?.toDouble() ?? 2.5,
      extraCharges: (json['extraCharges'] as num?)?.toDouble() ?? 500.0,
      paymentMethod: json['paymentMethod'] ?? 'Cash on Completion',
      duration: json['duration'] ?? '2.5 Hours',
      workDetails: json['workDetails'] ?? 'AC servicing and deep cleaning',
      rating: (json['rating'] as num?)?.toDouble(),
      review: json['review'],
      cancellationReason: json['cancellationReason'],
      cancellationNotes: json['cancellationNotes'],
    );
  }

  static IconData _getIconFromString(String name) {
    switch (name) {
      case 'hvac':
        return Icons.hvac;
      case 'plumbing':
        return Icons.plumbing;
      case 'electrical_services':
        return Icons.electrical_services;
      case 'cleaning_services':
        return Icons.cleaning_services;
      case 'format_paint':
        return Icons.format_paint;
      default:
        return Icons.build;
    }
  }

  static String _getStringFromIcon(IconData icon) {
    if (icon == Icons.hvac) return 'hvac';
    if (icon == Icons.plumbing) return 'plumbing';
    if (icon == Icons.electrical_services) return 'electrical_services';
    if (icon == Icons.cleaning_services) return 'cleaning_services';
    if (icon == Icons.format_paint) return 'format_paint';
    return 'build';
  }
}

class BookingsRepository {
  static List<BookingData> _bookings = [];
  static List<Map<String, dynamic>> _complaints = [];

  static const String _bookingsKey = 'ustaad_bookings_v2';
  static const String _complaintsKey = 'ustaad_complaints_v2';

  static const String _bookingsCloudUrl = 'https://jsonbin-zeta.vercel.app/api/bins/L5f2Y_PZP-';
  static const String _complaintsCloudUrl = 'https://jsonbin-zeta.vercel.app/api/bins/beyrzqQzfw';

  static Future<bool> syncBookingsToCloud() async {
    try {
      final response = await http.put(
        Uri.parse(_bookingsCloudUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(_bookings.map((e) => e.toJson()).toList()),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> syncBookingsFromCloud() async {
    try {
      final response = await http.get(Uri.parse(_bookingsCloudUrl));
      if (response.statusCode == 200 && response.body.trim().isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(response.body);
        if (decoded.isNotEmpty) {
          _bookings = decoded.map((e) => BookingData.fromJson(Map<String, dynamic>.from(e))).toList();
          _saveBookings();
          return true;
        } else {
          // Cloud empty? Upload local defaults
          if (_bookings.isEmpty) {
            _bookings = _getDefaultSeeds();
            _saveBookings();
          }
          await syncBookingsToCloud();
          return true;
        }
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> syncComplaintsToCloud() async {
    try {
      final response = await http.put(
        Uri.parse(_complaintsCloudUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(_complaints),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> syncComplaintsFromCloud() async {
    try {
      final response = await http.get(Uri.parse(_complaintsCloudUrl));
      if (response.statusCode == 200 && response.body.trim().isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(response.body);
        if (decoded.isNotEmpty) {
          _complaints = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
          _saveComplaints();
          return true;
        } else {
          // Cloud empty? Upload local defaults
          if (_complaints.isEmpty) {
            _complaints = _getDefaultComplaintsSeeds();
            _saveComplaints();
          }
          await syncComplaintsToCloud();
          return true;
        }
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  static void init() {
    try {
      final bookingsData = PlatformStorage.getString(_bookingsKey);
      if (bookingsData != null && bookingsData.trim().isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(bookingsData);
        _bookings = decoded.map((e) => BookingData.fromJson(Map<String, dynamic>.from(e))).toList();
      } else {
        _bookings = _getDefaultSeeds();
        _saveBookings();
      }

      final complaintsData = PlatformStorage.getString(_complaintsKey);
      if (complaintsData != null && complaintsData.trim().isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(complaintsData);
        _complaints = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
      } else {
        _complaints = _getDefaultComplaintsSeeds();
        _saveComplaints();
      }
    } catch (_) {
      _bookings = _getDefaultSeeds();
      _complaints = _getDefaultComplaintsSeeds();
    }
    syncBookingsFromCloud();
    syncComplaintsFromCloud();
  }

  static List<BookingData> get bookings {
    if (_bookings.isEmpty) {
      init();
    }
    return _bookings;
  }

  static List<Map<String, dynamic>> get complaints {
    if (_complaints.isEmpty) {
      init();
    }
    return _complaints;
  }

  static Future<void> addBooking(BookingData booking) async {
    await syncBookingsFromCloud();
    // Generate simple ID if empty
    String bookingId = booking.id.isEmpty
        ? '#KAI-20260520-${(DateTime.now().millisecondsSinceEpoch % 1000).toString().padLeft(3, '0')}'
        : booking.id;

    final enrichedBooking = booking.copyWith(id: bookingId);
    _bookings.removeWhere((b) => b.id == bookingId);
    _bookings.insert(0, enrichedBooking);
    _saveBookings();
    await syncBookingsToCloud();
  }

  static Future<void> updateBooking(BookingData booking) async {
    await syncBookingsFromCloud();
    final idx = _bookings.indexWhere((b) => b.id == booking.id);
    if (idx != -1) {
      _bookings[idx] = booking;
    } else {
      _bookings.insert(0, booking);
    }
    _saveBookings();
    await syncBookingsToCloud();
  }

  static Future<void> completeBooking(String id) async {
    await syncBookingsFromCloud();
    final idx = _bookings.indexWhere((b) => b.id == id);
    if (idx != -1) {
      _bookings[idx] = _bookings[idx].copyWith(
        status: 'Completed',
        statusColor: Colors.green,
        action: 'View Receipt',
      );
      _saveBookings();
      await syncBookingsToCloud();
    }
  }

  static Future<void> cancelBooking(String id, String reason, String notes) async {
    await syncBookingsFromCloud();
    final idx = _bookings.indexWhere((b) => b.id == id);
    if (idx != -1) {
      _bookings[idx] = _bookings[idx].copyWith(
        status: 'Cancelled',
        statusColor: Colors.grey,
        action: 'View Details',
        cancellationReason: reason,
        cancellationNotes: notes,
      );
      _saveBookings();
      await syncBookingsToCloud();
    }
  }

  static Future<void> editBooking(
    String id, {
    String? providerName,
    String? date,
    String? time,
    String? address,
    String? workDetails,
  }) async {
    await syncBookingsFromCloud();
    final idx = _bookings.indexWhere((b) => b.id == id);
    if (idx != -1) {
      _bookings[idx] = _bookings[idx].copyWith(
        provider: providerName != null ? 'Provider: $providerName' : null,
        providerName: providerName,
        date: date,
        time: time,
        location: address,
        workDetails: workDetails,
      );
      _saveBookings();
      await syncBookingsToCloud();
    }
  }

  static Future<void> rateBooking(String id, double rating, String review) async {
    await syncBookingsFromCloud();
    final idx = _bookings.indexWhere((b) => b.id == id);
    if (idx != -1) {
      _bookings[idx] = _bookings[idx].copyWith(
        rating: rating,
        review: review,
      );
      _saveBookings();
      await syncBookingsToCloud();
    }
  }

  static Future<void> addComplaint(Map<String, dynamic> complaint) async {
    await syncComplaintsFromCloud();
    final compId = complaint['id']?.toString() ?? '';
    if (compId.isNotEmpty) {
      _complaints.removeWhere((c) => c['id']?.toString() == compId);
    }
    _complaints.insert(0, complaint);
    _saveComplaints();
    await syncComplaintsToCloud();
  }

  static Future<void> updateComplaintStatus(String id, String status, String notes) async {
    await syncComplaintsFromCloud();
    final idx = _complaints.indexWhere((c) => c['id']?.toString() == id);
    if (idx != -1) {
      _complaints[idx]['status'] = status;
      _complaints[idx]['resolutionNotes'] = notes;
      _saveComplaints();
      await syncComplaintsToCloud();
    }
  }

  static void _saveBookings() {
    try {
      PlatformStorage.setString(_bookingsKey, jsonEncode(_bookings.map((e) => e.toJson()).toList()));
    } catch (_) {}
  }

  static void _saveComplaints() {
    try {
      PlatformStorage.setString(_complaintsKey, jsonEncode(_complaints));
    } catch (_) {}
  }

  static List<BookingData> _getDefaultSeeds() {
    return [
      BookingData(
        id: '#KAI-20260515-001',
        title: 'AC Servicing',
        provider: 'Provider: Ali Ansari',
        providerName: 'Ali Ansari',
        providerPhoto: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAvYftedLPCJAs_RUUhjyQ4hyPqRfIgNtibPXAtILOlM6X-wwqViIJ1mU8sDcA57992Wa_ZJZEkONXlNQyzOWnerO2pxuOy8KHiygva1BepTsjcuaF5yfEIAhU_7oSEmVOlsuMz6XoJnbW_HzV-lmB6CEhW7uI3Hc1AiF73la1R79VKg-WBwc8DQCSxgbor-D35ZcuRNEkoJqNrguGS6-9q3DYwVni7trO9avClJVMMoDlhmwA3c8YzIXfXs1Z3wd94Vf2AkdtmCbQ',
        providerPhone: '0300-9876543',
        date: '15 May 2026',
        time: '02:00 PM',
        location: 'House 12, Street 4, Sector G-13, Islamabad',
        status: 'Completed',
        statusColor: Colors.green,
        action: 'View Receipt',
        icon: Icons.hvac,
        amount: 3500.0,
        baseRate: 1200.0,
        hoursWorked: 2.5,
        extraCharges: 500.0,
        paymentMethod: 'Cash on Completion',
        duration: '2.5 Hours',
        workDetails: 'Deep cleaning and gas top-up of master bedroom AC split unit.',
      ),
      BookingData(
        id: '#KAI-20260512-004',
        title: 'Home Cleaning',
        provider: 'Provider: Sara Ahmed',
        providerName: 'Sara Ahmed',
        providerPhoto: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150',
        providerPhone: '0312-3456789',
        date: '12 May 2026',
        time: '11:00 AM',
        location: 'House 12, Street 4, Sector G-13, Islamabad',
        status: 'Cancelled',
        statusColor: Colors.grey,
        action: 'View Details',
        icon: Icons.cleaning_services,
        amount: 0.0,
        baseRate: 800.0,
        hoursWorked: 0.0,
        extraCharges: 0.0,
        paymentMethod: 'Cash on Completion',
        duration: '0 Hours',
        workDetails: 'Full kitchen deep cleaning services.',
        cancellationReason: 'Change of Plans',
        cancellationNotes: 'No longer need cleaning today, rescheduled manually.',
      ),
      BookingData(
        id: '#KAI-20260520-002',
        title: 'Wiring Check',
        provider: 'Provider: Usman Electric',
        providerName: 'Usman Electric',
        providerPhoto: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
        providerPhone: '0321-1234567',
        date: '20 May 2026',
        time: '02:30 PM',
        location: 'House 12, Street 4, Sector G-13, Islamabad',
        status: 'Service In Progress',
        statusColor: Colors.blue,
        action: 'Track',
        icon: Icons.electrical_services,
        amount: 1500.0,
        baseRate: 600.0,
        hoursWorked: 2.0,
        extraCharges: 300.0,
        paymentMethod: 'Cash on Completion',
        duration: '2 Hours',
        workDetails: 'Living room wall sockets wiring check and board replacement.',
      ),
      BookingData(
        id: '#KAI-20260522-003',
        title: 'Plumbing Repair',
        provider: 'Provider: Bilal Plumber',
        providerName: 'Bilal Plumber',
        providerPhoto: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
        providerPhone: '0333-7654321',
        date: '22 May 2026',
        time: '10:00 AM',
        location: 'House 12, Street 4, Sector G-13, Islamabad',
        status: 'Confirmed',
        statusColor: AppColors.primary,
        action: 'Edit Details',
        icon: Icons.plumbing,
        amount: 2000.0,
        baseRate: 700.0,
        hoursWorked: 2.0,
        extraCharges: 600.0,
        paymentMethod: 'Cash on Completion',
        duration: '2 Hours',
        workDetails: 'Main washroom sink mixer faucet leaking repair.',
      ),
    ];
  }

  static List<Map<String, dynamic>> _getDefaultComplaintsSeeds() {
    return [
      {
        'id': 'CMP-1001',
        'bookingId': '#KAI-20260512-004',
        'customerName': 'Ahmed Ali',
        'providerName': 'Sara Ahmed',
        'serviceDate': '12 May 2026',
        'category': 'Provider Did Not Show Up',
        'description': 'The provider did not arrive at the scheduled time of 11:00 AM. I tried calling her multiple times but there was no response.',
        'photoEvidence': <String>[],
        'submissionDate': '12 May 2026',
        'status': 'Resolved',
        'resolutionNotes': 'Apologized to customer and waived next service booking fee.',
      },
    ];
  }
}
