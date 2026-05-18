import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';

class BottomNavShell extends StatelessWidget {
  final Widget child;
  final String currentPath;
  final bool isCustomer;

  const BottomNavShell({
    super.key,
    required this.child,
    required this.currentPath,
    required this.isCustomer,
  });

  int _getIndex() {
    final prefix = isCustomer ? '/customer' : '/technician';
    if (currentPath.startsWith('$prefix/home')) return 0;
    if (currentPath.startsWith('$prefix/bookings')) return 1;
    if (isCustomer && currentPath.startsWith('$prefix/track')) return 2;
    if (!isCustomer && currentPath.startsWith('$prefix/insights')) return 2;
    if (currentPath.startsWith('$prefix/profile')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final index = _getIndex();
    final prefix = isCustomer ? '/customer' : '/technician';

    final customerItems = [
      _NavItem(icon: Icons.home_rounded, label: 'Home', path: '$prefix/home'),
      _NavItem(icon: Icons.event_note_rounded, label: 'My Bookings', path: '$prefix/bookings'),
      _NavItem(icon: Icons.query_stats_rounded, label: 'Track', path: '$prefix/track'),
      _NavItem(icon: Icons.person_rounded, label: 'Profile', path: '$prefix/profile'),
    ];

    final techItems = [
      _NavItem(icon: Icons.home_rounded, label: 'Home', path: '$prefix/home'),
      _NavItem(icon: Icons.event_note_rounded, label: 'My Bookings', path: '$prefix/bookings'),
      _NavItem(icon: Icons.query_stats_rounded, label: 'Insights', path: '$prefix/insights'),
      _NavItem(icon: Icons.person_rounded, label: 'Profile', path: '$prefix/profile'),
    ];

    final items = isCustomer ? customerItems : techItems;

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              offset: const Offset(0, -2),
              blurRadius: 4,
            ),
          ],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(items.length, (i) {
                final item = items[i];
                final isActive = i == index;
                return GestureDetector(
                  onTap: () => context.go(item.path),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(
                      horizontal: isActive ? 16 : 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.primaryContainer : Colors.transparent,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item.icon,
                          size: 24,
                          color: isActive ? AppColors.onPrimaryContainer : AppColors.onSurfaceVariant,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                            color: isActive ? AppColors.onPrimaryContainer : AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final String path;
  const _NavItem({required this.icon, required this.label, required this.path});
}
