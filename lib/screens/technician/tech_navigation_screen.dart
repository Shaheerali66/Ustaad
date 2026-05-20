import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../data/booking_state.dart';
import '../../data/bookings_repository.dart';
import '../../utils/google_maps_service.dart';
import '../../widgets/google_map_widget.dart';

class TechNavigationScreen extends StatefulWidget {
  const TechNavigationScreen({super.key});

  @override
  State<TechNavigationScreen> createState() => _TechNavigationScreenState();
}

class _TechNavigationScreenState extends State<TechNavigationScreen> {
  double _centerLat = 31.5204; // Lahore center fallback
  double _centerLng = 74.3587;
  double _zoom = 12.0;
  String _providerOrigin = 'Gulberg III, Lahore';
  String _customerDestination = 'House 42, Street 10, DHA Phase 5, Lahore';
  String _customerName = 'Sara Ahmed';
  String _jobTitle = 'Emergency Plumbing Repair';
  String _distance = '2.5 km';
  String _eta = '8 min';
  String _traffic = 'Low';

  @override
  void initState() {
    super.initState();
    _initRoute();
  }

  void _initRoute() async {
    final latest = BookingsRepository.bookings.isNotEmpty
        ? BookingsRepository.bookings.firstWhere(
            (b) => b.status.toLowerCase().contains('progress') || b.status.toLowerCase().contains('confirm'),
            orElse: () => BookingsRepository.bookings.first,
          )
        : null;

    final customerAddress = (latest != null && latest.location.isNotEmpty && !latest.location.toLowerCase().contains('select location'))
        ? latest.location
        : 'House 42, Street 10, DHA Phase 5, Lahore';

    final customerName = (latest != null && latest.providerName.isNotEmpty)
        ? latest.providerName
        : 'Sara Ahmed';

    final jobTitle = (latest != null && latest.title.isNotEmpty)
        ? latest.title
        : 'Emergency Plumbing Repair';

    // Determine initial center based on city name in the address
    final lowerAddress = customerAddress.toLowerCase();
    double initLat = 31.5204; // Lahore
    double initLng = 74.3587;
    double initZoom = 12.0;
    String origin = 'Gulberg, Lahore';

    if (lowerAddress.contains('islamabad')) {
      initLat = 33.6844;
      initLng = 73.0479;
      origin = 'Center, Islamabad';
    } else if (lowerAddress.contains('karachi')) {
      initLat = 24.8607;
      initLng = 67.0011;
      origin = 'Clifton, Karachi';
    } else if (lowerAddress.contains('rawalpindi')) {
      initLat = 33.5984;
      initLng = 73.0441;
      origin = 'Saddar, Rawalpindi';
    } else if (lowerAddress.contains('hyderabad')) {
      initLat = 25.3960;
      initLng = 68.3578;
      origin = 'Latifabad, Hyderabad';
    } else if (lowerAddress.contains('peshawar')) {
      initLat = 34.0151;
      initLng = 71.5249;
      origin = 'University Road, Peshawar';
    } else if (lowerAddress.contains('multan')) {
      initLat = 30.1575;
      initLng = 71.5249;
      origin = 'Boson Road, Multan';
    } else if (lowerAddress.contains('faisalabad')) {
      initLat = 31.4504;
      initLng = 73.1350;
      origin = 'People\'s Colony, Faisalabad';
    }

    setState(() {
      _centerLat = initLat;
      _centerLng = initLng;
      _zoom = initZoom;
      _providerOrigin = origin;
      _customerDestination = customerAddress;
      _customerName = customerName;
      _jobTitle = jobTitle;
    });

    final result = await GoogleMapsService.geocodeAddress(customerAddress);
    if (result != null && mounted) {
      setState(() {
        _centerLat = result['lat'] as double;
        _centerLng = result['lng'] as double;
        _zoom = 13.0;
      });
    }

    final matrix = await GoogleMapsService.getDistanceMatrix(_providerOrigin, _customerDestination);
    if (matrix != null && mounted) {
      setState(() {
        _distance = matrix['distanceText'] as String? ?? '2.5 km';
        _eta = matrix['durationText'] as String? ?? '8 min';
        _traffic = 'Low';
      });
    }
  }

  double get _workerLat {
    double workerLat = 31.5204;
    final lowerAddress = _customerDestination.toLowerCase();
    if (lowerAddress.contains('islamabad')) {
      workerLat = 33.6844;
    } else if (lowerAddress.contains('karachi')) {
      workerLat = 24.8607;
    } else if (lowerAddress.contains('rawalpindi')) {
      workerLat = 33.5984;
    } else if (lowerAddress.contains('hyderabad')) {
      workerLat = 25.3960;
    } else if (lowerAddress.contains('peshawar')) {
      workerLat = 34.0151;
    } else if (lowerAddress.contains('multan')) {
      workerLat = 30.1575;
    } else if (lowerAddress.contains('faisalabad')) {
      workerLat = 31.4504;
    }
    return workerLat;
  }

  double get _workerLng {
    double workerLng = 74.3587;
    final lowerAddress = _customerDestination.toLowerCase();
    if (lowerAddress.contains('islamabad')) {
      workerLng = 73.0479;
    } else if (lowerAddress.contains('karachi')) {
      workerLng = 67.0011;
    } else if (lowerAddress.contains('rawalpindi')) {
      workerLng = 73.0441;
    } else if (lowerAddress.contains('hyderabad')) {
      workerLng = 68.3578;
    } else if (lowerAddress.contains('peshawar')) {
      workerLng = 71.5249;
    } else if (lowerAddress.contains('multan')) {
      workerLng = 71.5249;
    } else if (lowerAddress.contains('faisalabad')) {
      workerLng = 73.1350;
    }
    return workerLng;
  }

  List<Map<String, dynamic>> get _markers {
    return [
      {
        'lat': _workerLat,
        'lng': _workerLng,
        'title': 'Your Location',
        'color': 'blue',
      },
      {
        'lat': _centerLat,
        'lng': _centerLng,
        'title': 'Customer Location',
        'color': 'red',
      }
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Full screen real Google Map
          Positioned.fill(
            child: GoogleMapWidget(
              centerLat: _centerLat,
              centerLng: _centerLng,
              zoom: _zoom,
              markers: _markers,
              route: {
                'origin': {
                  'lat': _workerLat,
                  'lng': _workerLng,
                },
                'destination': {
                  'lat': _centerLat,
                  'lng': _centerLng,
                },
              },
              height: MediaQuery.of(context).size.height < 400 ? 400 : MediaQuery.of(context).size.height,
            ),
          ),

          // Top bar
          Positioned(
            top: 0, left: 0, right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    _circleButton(Icons.arrow_back, () => context.pop()),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(9999),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2))],
                      ),
                      child: Row(
                        children: [
                          Container(width: 10, height: 10, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.secondary)),
                          const SizedBox(width: 8),
                          Text('Live Tracking', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.secondary)),
                        ],
                      ),
                    ),
                    const Spacer(),
                    _circleButton(Icons.my_location, () {
                      // Center map back to current location
                      setState(() {
                        _zoom = 13.0;
                      });
                    }),
                  ],
                ),
              ),
            ),
          ),

          // Route info overlay
          Positioned(
            top: MediaQuery.of(context).padding.top + 64,
            left: 16, right: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 12, height: 12,
                        decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Your Location', style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant)),
                            Text(_providerOrigin, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: Column(
                      children: List.generate(3, (_) => Container(
                        width: 2, height: 6,
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        color: AppColors.primary.withValues(alpha: 0.3),
                      )),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 12, height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.error,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Customer Location', style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant)),
                            Text(_customerDestination, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: AppColors.surfaceVariant),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _routeInfoChip(Icons.route, _distance, 'Distance'),
                      Container(width: 1, height: 32, color: AppColors.surfaceVariant),
                      _routeInfoChip(Icons.access_time, _eta, 'ETA'),
                      Container(width: 1, height: 32, color: AppColors.surfaceVariant),
                      _routeInfoChip(Icons.traffic, _traffic, 'Traffic'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Bottom sheet
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 16, offset: const Offset(0, -4))],
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Handle bar
                      Container(
                        width: 40, height: 4,
                        decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(2)),
                      ),
                      const SizedBox(height: 16),
                      // Customer info
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: AppColors.primaryContainer,
                            child: Text(
                              _customerName.split(' ').map((e) => e.isNotEmpty ? e[0].toUpperCase() : '').take(2).join(),
                              style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.onPrimaryContainer),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_customerName, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600)),
                                Row(
                                  children: [
                                    const Icon(Icons.star, size: 14, color: AppColors.tertiaryFixedDim),
                                    Text(' 4.9 Customer', style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurfaceVariant)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryContainer.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(9999),
                            ),
                            child: Text('In Progress', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.secondary)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Job details
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.plumbing, size: 18, color: AppColors.primary),
                                const SizedBox(width: 8),
                                Text(_jobTitle, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(_customerDestination, style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurfaceVariant)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Chat & Call buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _showChatSheet(context),
                              icon: const Icon(Icons.chat_bubble_outline, size: 20, color: AppColors.primary),
                              label: Text('Chat', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.primary)),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(0, 50),
                                side: const BorderSide(color: AppColors.primary),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _showCallDialog(context),
                              icon: const Icon(Icons.phone, size: 20, color: AppColors.secondary),
                              label: Text('Call', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.secondary)),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(0, 50),
                                side: const BorderSide(color: AppColors.secondary),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Arrived button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            BookingState.technicianArrived = true;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(children: [
                                  const Icon(Icons.check_circle, color: Colors.white, size: 20),
                                  const SizedBox(width: 8),
                                  Text('Customer notified — You have arrived!', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                                ]),
                                backgroundColor: AppColors.secondary,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            );
                          },
                          icon: const Icon(Icons.location_on, size: 20),
                          label: Text("I've Arrived", style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(0, 52),
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.surfaceContainerLowest,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Icon(icon, color: AppColors.onSurface),
      ),
    );
  }

  Widget _routeInfoChip(IconData icon, String value, String label) {
    return Column(
      children: [
        Row(children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(value, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
        ]),
        Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant)),
      ],
    );
  }

  void _showChatSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ChatSheet(customerName: _customerName),
    );
  }

  void _showCallDialog(BuildContext context) {
    final initials = _customerName.split(' ').map((e) => e.isNotEmpty ? e[0].toUpperCase() : '').take(2).join();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.all(32),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(radius: 36, backgroundColor: AppColors.primaryContainer, child: Text(initials, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.onPrimaryContainer))),
            const SizedBox(height: 16),
            Text(_customerName, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700)),
            Text('Customer', style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _callActionButton(Icons.phone, AppColors.secondary, 'Call', () => Navigator.pop(ctx)),
                const SizedBox(width: 24),
                _callActionButton(Icons.videocam, AppColors.primary, 'Video', () => Navigator.pop(ctx)),
                const SizedBox(width: 24),
                _callActionButton(Icons.close, AppColors.error, 'Cancel', () => Navigator.pop(ctx)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _callActionButton(IconData icon, Color color, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 6),
          Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
        ],
      ),
    );
  }
}

class _ChatSheet extends StatefulWidget {
  final String customerName;
  const _ChatSheet({required this.customerName});

  @override
  State<_ChatSheet> createState() => _ChatSheetState();
}

class _ChatSheetState extends State<_ChatSheet> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> get _messages => BookingState.technicianMessages;

  static const List<String> _autoReplies = [
    'Okay, thank you! 😊',
    'Please hurry, it\'s urgent.',
    'Should I keep the tools ready?',
    'How much will it cost approximately?',
    'Alright, I\'ll be waiting at the gate.',
    'Can you bring extra parts just in case?',
    'Thanks for the update! 👍',
  ];
  int _replyIndex = 0;

  String _currentTime() {
    final now = TimeOfDay.now();
    final hour = now.hourOfPeriod == 0 ? 12 : now.hourOfPeriod;
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'sender': 'You', 'message': text, 'isMe': true, 'time': _currentTime()});
    });
    _controller.clear();
    _scrollToBottom();

    // Auto-reply after a short delay
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() {
        _messages.add({
          'sender': widget.customerName,
          'message': _autoReplies[_replyIndex % _autoReplies.length],
          'isMe': false,
          'time': _currentTime(),
        });
        _replyIndex++;
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final initials = widget.customerName.split(' ').map((e) => e.isNotEmpty ? e[0].toUpperCase() : '').take(2).join();
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(2))),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(radius: 18, backgroundColor: AppColors.primaryContainer, child: Text(initials, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.onPrimaryContainer))),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(widget.customerName, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
                  Row(children: [
                    Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.secondary)),
                    const SizedBox(width: 4),
                    Text('Online', style: GoogleFonts.inter(fontSize: 12, color: AppColors.secondary)),
                  ]),
                ]),
                const Spacer(),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.surfaceVariant),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isMe = msg['isMe'] as bool;
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isMe ? AppColors.primary : AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isMe ? 16 : 4),
                        bottomRight: Radius.circular(isMe ? 4 : 16),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Text(msg['message'] as String, style: GoogleFonts.inter(fontSize: 14, color: isMe ? Colors.white : AppColors.onSurface)),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(msg['time'] as String, style: GoogleFonts.inter(fontSize: 11, color: isMe ? Colors.white.withValues(alpha: 0.7) : AppColors.onSurfaceVariant)),
                            if (isMe) ...[
                              const SizedBox(width: 4),
                              Icon(Icons.done_all, size: 14, color: Colors.white.withValues(alpha: 0.7)),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1, color: AppColors.surfaceVariant),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).viewInsets.bottom + 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: (_) => _sendMessage(),
                    textInputAction: TextInputAction.send,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      filled: true,
                      fillColor: AppColors.surfaceContainerLow,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    width: 48, height: 48,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primary),
                    child: const Icon(Icons.send, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
