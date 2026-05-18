import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../data/booking_state.dart';

class FollowUpScreen extends StatefulWidget {
  const FollowUpScreen({super.key});

  @override
  State<FollowUpScreen> createState() => _FollowUpScreenState();
}

class _FollowUpScreenState extends State<FollowUpScreen> {
  void _showChatSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _ChatSheet(),
    );
  }

  void _showCallDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.all(32),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 36,
              backgroundImage: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuA6J8H3IFcCnQDsmC1_SrBWwBBR5GIoTird5tboOp2TJxX-tn-q5n423dHIWf7AwhWOlPSTNaMPU6UBm1kyZGZRPQ7Xqnv8AfMWZCARsMrHlsOz4n2ZUCd5Wsawncuelzh5hIPIWyY_Gv_hMM1XSrGOi155LDlLqgtb5MTlDY_qCNkMLOCDHPGnBUF-TzEvSg-a5nrxlVP4BhkeW-7QXTwMnXIJt2lgdnix2kCc81wQPC5tj8grkYByU0RsPYCM8YXtQG2xeyHuAYE'),
            ),
            const SizedBox(height: 16),
            Text('Ali Raza', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700)),
            Text('Technician (Plumber/Electrician)', style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurfaceVariant)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/customer/bookings');
            }
          },
        ),
        title: Text('Khidmat AI Match', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.location_on_outlined, color: AppColors.onSurfaceVariant),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Track & Reminders', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('Manage your upcoming service booking', style: GoogleFonts.inter(fontSize: 16, color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 24),

            // Technician Contact Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surfaceVariant),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Your Technician', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 26,
                        backgroundImage: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuA6J8H3IFcCnQDsmC1_SrBWwBBR5GIoTird5tboOp2TJxX-tn-q5n423dHIWf7AwhWOlPSTNaMPU6UBm1kyZGZRPQ7Xqnv8AfMWZCARsMrHlsOz4n2ZUCd5Wsawncuelzh5hIPIWyY_Gv_hMM1XSrGOi155LDlLqgtb5MTlDY_qCNkMLOCDHPGnBUF-TzEvSg-a5nrxlVP4BhkeW-7QXTwMnXIJt2lgdnix2kCc81wQPC5tj8grkYByU0RsPYCM8YXtQG2xeyHuAYE'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Ali Raza', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
                            Row(
                              children: [
                                const Icon(Icons.star, size: 14, color: AppColors.tertiaryFixedDim),
                                Text(' 4.8 • Plumber & Electrician', style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurfaceVariant)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: BookingState.technicianArrived
                              ? AppColors.secondaryContainer.withValues(alpha: 0.25)
                              : BookingState.jobStarted
                                  ? AppColors.secondaryContainer.withValues(alpha: 0.15)
                                  : AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: Text(
                          BookingState.technicianArrived
                              ? 'Arrived ✓'
                              : BookingState.jobStarted
                                  ? 'On The Way'
                                  : 'Assigned',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: BookingState.technicianArrived
                                ? AppColors.secondary
                                : BookingState.jobStarted
                                    ? AppColors.secondary
                                    : AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showChatSheet(context),
                          icon: const Icon(Icons.chat_bubble_outline, size: 20, color: AppColors.primary),
                          label: Text('Chat', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.primary)),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 48),
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
                            minimumSize: const Size(0, 48),
                            side: const BorderSide(color: AppColors.secondary),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Timeline
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surfaceVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Booking Status Timeline', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  _timelineItem(Icons.check_circle, AppColors.secondary, 'Request Received', 'Today, 08:15 AM', true),
                  _timelineItem(Icons.check_circle, AppColors.secondary, 'Provider Matched', 'Today, 08:22 AM - Electrician Ali assigned', true),
                  _timelineItem(Icons.check_circle, AppColors.secondary, 'Booking Confirmed', 'Today, 08:30 AM - Initial payment processed', true),
                  if (BookingState.jobStarted)
                    _timelineItem(Icons.check_circle, AppColors.secondary, 'Technician On The Way', 'Ali started job and is coming', true)
                  else
                    _timelineItem(Icons.circle, AppColors.outlineVariant, 'Technician Starting Job', 'Waiting for start notification', false),
                  if (BookingState.technicianArrived)
                    _timelineItem(Icons.check_circle, AppColors.secondary, 'Technician Arrived', 'Ali Raza has arrived at your gate!', true)
                  else
                    _timelineItem(Icons.circle, AppColors.outlineVariant, 'Technician Arrival', 'Waiting for arrival confirmation', false),
                  Padding(
                    padding: const EdgeInsets.only(left: 36),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time, size: 18, color: AppColors.onSurfaceVariant),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Upcoming Reminder', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
                                Text('1 hour before arrival', style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant)),
                              ],
                            ),
                          ),
                          Text('9:00\nAM', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Text('Service In Progress\nEstimated: 10:00 AM', style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurfaceVariant)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Notification Channels
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surfaceVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.notifications_outlined, size: 20, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text('Notification Channels', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('How would you like to receive your upcoming reminders?', style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: 16),
                  _toggleRow(Icons.chat, 'WhatsApp Reminder', true, AppColors.secondary),
                  _toggleRow(Icons.sms, 'SMS Message', true, AppColors.primary),
                  _toggleRow(Icons.phone_android, 'Push Notification', false, AppColors.onSurfaceVariant),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Rate card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  const Icon(Icons.star_outline, size: 32, color: AppColors.tertiaryFixedDim),
                  const SizedBox(height: 12),
                  Text('Rate after completion', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text('Your feedback helps us maintain high quality Khidmat across the platform.', style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurfaceVariant), textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.primary)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Set Reminder to Rate', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)),
                        const SizedBox(width: 8),
                        const Icon(Icons.add_circle_outline, size: 18, color: AppColors.primary),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _timelineItem(IconData icon, Color color, String title, String subtitle, bool done) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
                Text(subtitle, style: GoogleFonts.inter(fontSize: 12, color: done ? AppColors.onSurfaceVariant : AppColors.primary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _toggleRow(IconData icon, String label, bool value, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: GoogleFonts.inter(fontSize: 16))),
          Switch(value: value, onChanged: (_) {}, activeThumbColor: AppColors.primary),
        ],
      ),
    );
  }
}

class _ChatSheet extends StatefulWidget {
  const _ChatSheet();

  @override
  State<_ChatSheet> createState() => _ChatSheetState();
}

class _ChatSheetState extends State<_ChatSheet> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> get _messages => BookingState.customerMessages;

  static const List<String> _autoReplies = [
    'Bilkul, main raste mein hoon, bas 5 minute tak pohnch jaunga! 🚗',
    'Main location follow kar rha hoon. GPS bilkul sahi guide kar rha hai.',
    'Kuch aur kaam bhi hai tou bata dein, main accessories sath le aunga.',
    'Jee, main pohnch gaya hoon. Main gate ke paas khara hoon.',
    'Sure! I will handle it properly. Don\'t worry.',
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

    // Auto-reply from technician after short delay
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() {
        _messages.add({
          'sender': 'Ali Raza',
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
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
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
                const CircleAvatar(
                  radius: 18,
                  backgroundImage: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuA6J8H3IFcCnQDsmC1_SrBWwBBR5GIoTird5tboOp2TJxX-tn-q5n423dHIWf7AwhWOlPSTNaMPU6UBm1kyZGZRPQ7Xqnv8AfMWZCARsMrHlsOz4n2ZUCd5Wsawncuelzh5hIPIWyY_Gv_hMM1XSrGOi155LDlLqgtb5MTlDY_qCNkMLOCDHPGnBUF-TzEvSg-a5nrxlVP4BhkeW-7QXTwMnXIJt2lgdnix2kCc81wQPC5tj8grkYByU0RsPYCM8YXtQG2xeyHuAYE'),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ali Raza', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
                    Row(
                      children: [
                        Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.secondary)),
                        const SizedBox(width: 4),
                        Text('Online & On The Way', style: GoogleFonts.inter(fontSize: 12, color: AppColors.secondary)),
                      ],
                    ),
                  ],
                ),
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
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
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
                        Text(
                          msg['message'] as String,
                          style: GoogleFonts.inter(fontSize: 14, color: isMe ? Colors.white : AppColors.onSurface),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              msg['time'] as String,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: isMe ? Colors.white.withValues(alpha: 0.7) : AppColors.onSurfaceVariant,
                              ),
                            ),
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
                      hintText: 'Type a message to Ali...',
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
