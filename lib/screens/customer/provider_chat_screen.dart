import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../data/bookings_repository.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final String timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class ProviderChatScreen extends StatefulWidget {
  final Map<String, dynamic>? technician;

  const ProviderChatScreen({super.key, this.technician});

  @override
  State<ProviderChatScreen> createState() => _ProviderChatScreenState();
}

class _ProviderChatScreenState extends State<ProviderChatScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;
  late final bool _isOnline;

  @override
  void initState() {
    super.initState();
    // Deterministic online status: online if name length is even, offline if odd
    final name = widget.technician?['name']?.toString() ?? 'Provider';
    _isOnline = name.length % 2 == 0;

    // 1. Initial automated greeting message from the provider
    _messages.add(
      ChatMessage(
        text: "Hello! I am $name. How can I help you today?",
        isUser: false,
        timestamp: _getFormattedTime(DateTime.now()),
      ),
    );

    // 2. Pre-fill suggested message in the input field based on technician services
    final service = widget.technician?['category'] ?? 'Home Services';
    final area = widget.technician?['area'] ?? 'Sector G-13';
    final city = widget.technician?['city'] ?? 'Islamabad';
    
    _inputController.text = "Hi, I need help with $service. My location is $area, $city. Preferred time: Tomorrow, 10:00 AM. Details: Routine inspection and servicing.";
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
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

  String _getFormattedTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final minute = dt.minute < 10 ? '0${dt.minute}' : dt.minute.toString();
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $ampm';
  }

  void _sendMessage() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(
          text: text,
          isUser: true,
          timestamp: _getFormattedTime(DateTime.now()),
        ),
      );
      _inputController.clear();
      _isTyping = true;
    });
    _scrollToBottom();

    // 3. Simulated response behavior with dynamic timing
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _isTyping = false;
        
        final techName = widget.technician?['name'] ?? 'Provider';
        final rate = widget.technician?['hourlyRate'] ?? 1200;
        
        String replyText = "Thank you for reaching out! I am $techName and I am available at your mentioned time. Shall I confirm the booking?";
        final lowerText = text.toLowerCase();
        
        if (lowerText.contains('price') || lowerText.contains('rate') || lowerText.contains('cost') || lowerText.contains('charge')) {
          replyText = "My standard rate is Rs. $rate/hr plus base visitation charges. The final diagnosis will be done on-site. Would you like to confirm?";
        } else if (lowerText.contains('photo') || lowerText.contains('pic') || lowerText.contains('image')) {
          replyText = "I have reviewed the pictures, looks straightforward. I will bring all necessary replacement tools. Ready to book?";
        } else if (lowerText.contains('urgent') || lowerText.contains('emergency') || lowerText.contains('now')) {
          replyText = "I offer emergency support as well! I can head over to your location immediately. Please click the Book button below to generate a tracking ID.";
        }

        _messages.add(
          ChatMessage(
            text: replyText,
            isUser: false,
            timestamp: _getFormattedTime(DateTime.now()),
          ),
        );
      });
      _scrollToBottom();
    });
  }

  @override
  Widget build(BuildContext context) {
    final name = (widget.technician?['name'] ?? 'Professional Provider').toString();
    final category = (widget.technician?['category'] ?? 'Home Services').toString();
    
    // Fallback initials
    String initials = 'W';
    if (name.trim().isNotEmpty) {
      final parts = name.trim().split(RegExp(r'\s+'));
      initials = parts.first.isNotEmpty ? parts.first[0] : 'W';
    }

    final avatarColor = Colors.primaries[name.length % Colors.primaries.length].shade400;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: avatarColor.withValues(alpha: 0.15),
              backgroundImage: widget.technician?['profilePhoto'] != null
                  ? MemoryImage(base64Decode(widget.technician!['profilePhoto'].split(',').last))
                  : null,
              child: widget.technician?['profilePhoto'] == null
                  ? Text(
                      initials,
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: avatarColor),
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.onSurface),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      Container(
                        width: 7, height: 7,
                        decoration: BoxDecoration(
                          color: _isOnline ? Colors.green : Colors.grey.shade400,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _isOnline ? 'Online' : 'Offline',
                        style: GoogleFonts.inter(fontSize: 10, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.onSurface),
            surfaceTintColor: AppColors.surface,
            onSelected: (val) {
              if (val == 'clear') {
                setState(() {
                  _messages.clear();
                });
              } else if (val == 'view') {
                context.pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Report has been registered with Khidmat-AI security teams.')),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'view', child: Text('View Profile')),
              const PopupMenuItem(value: 'report', child: Text('Report Provider')),
              const PopupMenuItem(value: 'clear', child: Text('Clear Chat')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // 4. Offline warning banner at the top if provider is offline
          if (!_isOnline)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: Colors.grey.shade100,
              child: Row(
                children: [
                  Icon(Icons.wifi_off_rounded, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Provider is currently offline. Your message will be delivered when they are back online. You can still proceed to book.',
                      style: GoogleFonts.inter(fontSize: 11, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),

          // Message bubble area
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: _messages.length,
              itemBuilder: (context, idx) {
                final msg = _messages[idx];
                return _buildChatBubble(msg);
              },
            ),
          ),

          // Typing status indicator
          if (_isTyping)
            Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 8),
              child: Row(
                children: [
                  Text(
                    '$name is typing',
                    style: GoogleFonts.inter(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(width: 4),
                  const SizedBox(
                    width: 10, height: 10,
                    child: CircularProgressIndicator(strokeWidth: 1.5, color: AppColors.primary),
                  ),
                ],
              ),
            ),

          // 5. "Book Now" floating banner above input bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withValues(alpha: 0.15),
              border: const Border(
                top: BorderSide(color: AppColors.outlineVariant, width: 0.5),
                bottom: BorderSide(color: AppColors.outlineVariant, width: 0.5),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Ready to book $name?',
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    IconData catIcon = Icons.build;
                    final catLower = category.toLowerCase();
                    if (catLower.contains('ac')) {
                      catIcon = Icons.hvac;
                    } else if (catLower.contains('plumb')) {
                      catIcon = Icons.plumbing;
                    } else if (catLower.contains('elect')) {
                      catIcon = Icons.electrical_services;
                    }

                    BookingsRepository.addBooking(
                      BookingData(
                        title: category,
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
                  icon: const Icon(Icons.bolt, size: 16, color: Colors.white),
                  label: Text('Book Now', style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 11)),
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Input Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Attachment Icon
                  IconButton(
                    icon: const Icon(Icons.add_photo_alternate_outlined, color: AppColors.primary),
                    onPressed: () {
                      setState(() {
                        _messages.add(
                          ChatMessage(
                            text: "📷 Shared a photo of the service issue for diagnostic.",
                            isUser: true,
                            timestamp: _getFormattedTime(DateTime.now()),
                          ),
                        );
                        _isTyping = true;
                      });
                      _scrollToBottom();
                      
                      Future.delayed(const Duration(milliseconds: 2500), () {
                        if (!mounted) return;
                        setState(() {
                          _isTyping = false;
                          _messages.add(
                            ChatMessage(
                              text: "Received the photo! I can see the alignment looks off. Let me bring specific replacements. Ready to proceed with booking?",
                              isUser: false,
                              timestamp: _getFormattedTime(DateTime.now()),
                            ),
                          );
                        });
                        _scrollToBottom();
                      });
                    },
                  ),
                  
                  // Text Input
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      style: GoogleFonts.inter(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        hintStyle: GoogleFonts.inter(color: AppColors.onSurfaceVariant.withValues(alpha: 0.6)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        filled: true,
                        fillColor: AppColors.surfaceContainerLow,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 4),

                  // Simulated Microphone / Voice icon
                  IconButton(
                    icon: const Icon(Icons.mic_none_rounded, color: AppColors.onSurfaceVariant),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Voice message simulation started...'), duration: Duration(seconds: 1)),
                      );
                    },
                  ),

                  // Send Button
                  Container(
                    decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(ChatMessage msg) {
    final bg = msg.isUser ? AppColors.primary : AppColors.surfaceContainerHighest;
    final textStyle = GoogleFonts.inter(
      fontSize: 13,
      color: msg.isUser ? Colors.white : AppColors.onSurface,
      fontWeight: FontWeight.w500,
    );

    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        child: Column(
          crossAxisAlignment: msg.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(msg.isUser ? 16 : 4),
                  bottomRight: Radius.circular(msg.isUser ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  )
                ],
              ),
              child: Text(msg.text, style: textStyle),
            ),
            const SizedBox(height: 3),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                msg.timestamp,
                style: GoogleFonts.inter(fontSize: 9, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
