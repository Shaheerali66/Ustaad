import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../data/user_database.dart';
import '../../widgets/google_places_autocomplete.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _errorMessage;

  String _extractCity(String address) {
    final List<String> cities = [
      'Islamabad', 'Lahore', 'Karachi', 'Rawalpindi', 'Peshawar', 
      'Multan', 'Faisalabad', 'Sialkot', 'Hyderabad', 'Quetta', 'Gujranwala'
    ];
    for (var city in cities) {
      if (address.toLowerCase().contains(city.toLowerCase())) {
        return city;
      }
    }
    final parts = address.split(',');
    if (parts.isNotEmpty) {
      return parts.last.trim();
    }
    return 'Islamabad';
  }

  static const _avatarUrl = 'https://lh3.googleusercontent.com/aida-public/AB6AXuAvYftedLPCJAs_RUUhjyQ4hyPqRfIgNtibPXAtILOlM6X-wwqViIJ1mU8sDcA57992Wa_ZJZEkONXlNQyzOWnerO2pxuOy8KHiygva1BepTsjcuaF5yfEIAhU_7oSEmVOlsuMz6XoJnbW_HzV-lmB6CEhW7uI3Hc1AiF73la1R79VKg-WBwc8DQCSxgbor-D35ZcuRNEkoJqNrguGS6-9q3DYwVni7trO9avClJVMMoDlhmwA3c8YzIXfXs1Z3wd94Vf2AkdtmCbQ';
  static const _providerUrl = 'https://lh3.googleusercontent.com/aida-public/AB6AXuA6J8H3IFcCnQDsmC1_SrBWwBBR5GIoTird5tboOp2TJxX-tn-q5n423dHIWf7AwhWOlPSTNaMPU6UBm1kyZGZRPQ7Xqnv8AfMWZCARsMrHlsOz4n2ZUCd5Wsawncuelzh5hIPIWyY_Gv_hMM1XSrGOi155LDlLqgtb5MTlDY_qCNkMLOCDHPGnBUF-TzEvSg-a5nrxlVP4BhkeW-7QXTwMnXIJt2lgdnix2kCc81wQPC5tj8grkYByU0RsPYCM8YXtQG2xeyHuAYE';

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      setState(() {
        _errorMessage = 'Please type a service request / Kuch type karein pehle!';
      });
      // Also show a beautiful floating snackbar warning
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Please describe what service you need first! / Pehle apni service likhein!',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    setState(() {
      _errorMessage = null;
    });

    // Navigate to request-summary passing the typed query!
    context.go('/customer/request-summary', extra: text);
  }

  void _showCityChangeSheet() {
    final List<String> cities = [
      'Islamabad',
      'Lahore',
      'Karachi',
      'Rawalpindi',
      'Peshawar',
      'Multan',
      'Faisalabad',
      'Sialkot',
      'Hyderabad',
      'Quetta',
      'Gujranwala'
    ];

    final TextEditingController manualLocationController = TextEditingController(
      text: UserDatabase.temporaryLocation ?? ''
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            final hasTemp = UserDatabase.temporaryLocation != null;
            final currentSavedCity = UserDatabase.currentUser?['city'] ?? 'Islamabad';
            final activeLocText = UserDatabase.temporaryLocation ?? currentSavedCity;

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Search Location',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurface,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Temporary locations only apply to the current session.',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  if (hasTemp) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withAlpha(38),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.primary.withAlpha(76)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Temporary Active:',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                Text(
                                  activeLocText,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.onSurface,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              UserDatabase.clearTemporaryLocation();
                              setState(() {});
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Location reset to permanent: $currentSavedCity',
                                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                                  ),
                                  backgroundColor: AppColors.primary,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              );
                            },
                            child: Text(
                              'Reset',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Manual location autocomplete field
                  Text(
                    'Enter Location Manually',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GooglePlacesAutocompleteField(
                    controller: manualLocationController,
                    hintText: 'Search sector, street, or city...',
                    prefixIcon: Icons.edit_location_alt_outlined,
                    onSelected: (val) {
                      final inputLoc = val.trim();
                      if (inputLoc.isNotEmpty) {
                        UserDatabase.temporaryLocation = inputLoc;
                        UserDatabase.temporaryCity = _extractCity(inputLoc);
                        setState(() {});
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Session search location set to $inputLoc!',
                              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                            ),
                            backgroundColor: AppColors.primary,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  
                  const Divider(),
                  const SizedBox(height: 12),
                  
                  Text(
                    'Or Select a City',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Flexible(
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: cities.length,
                        itemBuilder: (context, index) {
                          final city = cities[index];
                          final isSelected = !hasTemp 
                              ? city.toLowerCase() == currentSavedCity.toLowerCase()
                              : city.toLowerCase() == UserDatabase.temporaryLocation!.toLowerCase();

                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              city,
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected ? AppColors.primary : AppColors.onSurface,
                              ),
                            ),
                            trailing: isSelected ? const Icon(Icons.check_circle, color: AppColors.primary) : null,
                            onTap: () {
                              UserDatabase.temporaryLocation = city;
                              UserDatabase.temporaryCity = city;
                              setState(() {});
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Session search location set to $city!',
                                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                                  ),
                                  backgroundColor: AppColors.primary,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = UserDatabase.currentUser;
    final fullName = user?['fullName'] ?? 'Ahmed';
    final firstName = fullName.split(' ').first;
    final isFirst = UserDatabase.isFirstLogin;
    final greetingText = isFirst ? 'Welcome, $firstName!' : 'Welcome back, $firstName!';

    if (isFirst) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        UserDatabase.clearFirstLoginFlag();
      });
    }

    final currentCity = UserDatabase.activeCity;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Top App Bar
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.surface,
            surfaceTintColor: Colors.transparent,
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primaryContainer,
                  child: Text(
                    firstName.substring(0, firstName.length > 1 ? 2 : 1).toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onPrimaryContainer,
                    ),
                  ),
                ),
                const Spacer(),
                Text('Khidmat AI', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.primary)),
                const Spacer(),
                InkWell(
                  onTap: _showCityChangeSheet,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: UserDatabase.temporaryLocation != null
                          ? AppColors.primaryContainer.withAlpha(25)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: UserDatabase.temporaryLocation != null
                            ? AppColors.primary.withAlpha(76)
                            : Colors.transparent,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          UserDatabase.temporaryLocation != null ? Icons.location_on : Icons.location_on_outlined,
                          color: UserDatabase.temporaryLocation != null ? AppColors.primary : AppColors.onSurfaceVariant,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          UserDatabase.activeCity,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: UserDatabase.temporaryLocation != null ? AppColors.primary : AppColors.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Greeting
                Text(greetingText, style: GoogleFonts.inter(fontSize: 16, color: AppColors.onSurfaceVariant)),
                const SizedBox(height: 4),
                // Location Indicator below greeting
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      'Your location: $currentCity',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: _showCityChangeSheet,
                      child: const Icon(
                        Icons.edit,
                        size: 13,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text('What service do you need today?', style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.onBackground, letterSpacing: -0.52)),
                const SizedBox(height: 24),
                // AI Chat Input Card
                _buildAiInput(context),
                const SizedBox(height: 24),
                // Quick Services
                Text('QUICK SERVICES', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant, letterSpacing: 1.2)),
                const SizedBox(height: 8),
                _buildQuickServices(context),
                const SizedBox(height: 24),
                // Recent Bookings
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Recent Bookings', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.onBackground)),
                    GestureDetector(
                      onTap: () => context.go('/customer/bookings'),
                      child: Text('View All', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildBookingCard(
                  icon: Icons.hvac,
                  iconBg: AppColors.primaryContainer,
                  iconColor: AppColors.onPrimaryContainer,
                  title: 'AC Servicing',
                  date: 'Today, 2:00 PM',
                  status: 'CONFIRMED',
                  statusColor: AppColors.onSecondaryContainer,
                  statusBg: AppColors.secondaryContainer.withValues(alpha: 0.2),
                  providerName: 'Usman Tech',
                  providerImage: _providerUrl,
                  price: 'Rs. 1,500',
                  priceColor: AppColors.primary,
                  context: context,
                ),
                const SizedBox(height: 12),
                _buildBookingCard(
                  icon: Icons.electrical_services,
                  iconBg: AppColors.surfaceContainerHigh,
                  iconColor: AppColors.onSurfaceVariant,
                  title: 'Wiring Check',
                  date: 'Mon, 10:00 AM',
                  status: 'COMPLETED',
                  statusColor: AppColors.onSurfaceVariant,
                  statusBg: AppColors.surfaceVariant,
                  providerName: 'Ali Electric',
                  providerImage: null,
                  price: 'Rs. 800',
                  priceColor: AppColors.onSurfaceVariant,
                  context: context,
                ),
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiInput(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _errorMessage != null ? AppColors.error.withValues(alpha: 0.5) : AppColors.surfaceVariant),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [AppColors.primaryContainer, AppColors.surfaceTint]),
                  ),
                  child: const Icon(Icons.auto_awesome, size: 16, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _controller,
                        maxLines: null,
                        minLines: 1,
                        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.onSurface),
                        decoration: InputDecoration(
                          hintText: 'Type or speak your service request here...\n(Supports Roman Urdu, Urdu, English)',
                          hintStyle: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurfaceVariant),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                        onChanged: (val) {
                          if (val.trim().isNotEmpty && _errorMessage != null) {
                            setState(() => _errorMessage = null);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 44),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, size: 14, color: AppColors.error),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: GoogleFonts.inter(fontSize: 12, color: AppColors.error, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            const Divider(color: AppColors.surfaceVariant, height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.auto_awesome, size: 14, color: AppColors.onSurfaceVariant),
                const SizedBox(width: 4),
                Text('Powered by Khidmat AI', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.onSurfaceVariant)),
                const Spacer(),
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.surfaceContainerHigh),
                  child: const Icon(Icons.mic, color: AppColors.primary),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _handleSend,
                  child: Container(
                    width: 40, height: 40,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primary),
                    child: const Icon(Icons.send, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickServices(BuildContext context) {
    final services = [
      ('Plumber', Icons.plumbing),
      ('Electrician', Icons.electrical_services),
      ('AC Tech', Icons.hvac),
      ('Tutor', Icons.school),
      ('Beautician', Icons.face_retouching_natural),
      ('Home Svcs', Icons.cleaning_services),
    ];

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: services.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          return GestureDetector(
            onTap: () {
              final label = services[i].$1;
              String cat = 'AC Services';
              if (label == 'Plumber') cat = 'Plumber';
              else if (label == 'Electrician') cat = 'Electrician';
              else if (label == 'Tutor') cat = 'Tutoring';
              else if (label == 'Beautician') cat = 'Beauty Services';
              else if (label == 'Home Svcs') cat = 'Cleaning Services';

              context.go('/customer/quick-service-form', extra: cat);
            },
            child: Container(
              width: 80,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.surfaceVariant),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.surfaceContainerLow),
                    child: Icon(services[i].$2, color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(height: 8),
                  Text(services[i].$1, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.onBackground), overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBookingCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String date,
    required String status,
    required Color statusColor,
    required Color statusBg,
    required String providerName,
    String? providerImage,
    required String price,
    required Color priceColor,
    required BuildContext context,
  }) {
    return GestureDetector(
      onTap: () => context.go('/customer/track'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.surfaceVariant),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: iconBg),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onBackground)),
                      Text(date, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.onSurfaceVariant)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(9999)),
                  child: Text(status, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: statusColor, letterSpacing: 0.5)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: AppColors.surfaceVariant, height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                if (providerImage != null)
                  CircleAvatar(radius: 12, backgroundImage: NetworkImage(providerImage))
                else
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: AppColors.surfaceDim,
                    child: const Icon(Icons.person, size: 14, color: AppColors.onSurfaceVariant),
                  ),
                const SizedBox(width: 8),
                Text(providerName, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.onBackground)),
                const Spacer(),
                Text(price, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: priceColor)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
