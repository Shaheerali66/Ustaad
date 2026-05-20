import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/splash_screen.dart';
import '../screens/role_selection_screen.dart';
import '../screens/customer/home_screen.dart';
import '../screens/customer/request_summary_screen.dart';
import '../screens/customer/ai_processing_screen.dart';
import '../screens/customer/provider_discovery_screen.dart';
import '../screens/customer/provider_details_screen.dart';
import '../screens/customer/booking_confirmation_screen.dart';
import '../screens/customer/my_bookings_screen.dart';
import '../screens/customer/follow_up_screen.dart';
import '../screens/customer/ai_reasoning_logs_screen.dart';
import '../screens/customer/profile_screen.dart';
import '../screens/customer/quick_service_form_screen.dart';
import '../screens/technician/tech_dashboard_screen.dart';
import '../screens/technician/tech_registration_screen.dart';
import '../screens/technician/tech_service_info_screen.dart';
import '../screens/technician/tech_documents_screen.dart';
import '../screens/technician/tech_performance_screen.dart';
import '../screens/technician/tech_navigation_screen.dart';
import '../screens/technician/tech_welcome_screen.dart';
import '../screens/technician/tech_login_screen.dart';
import '../screens/technician/tech_submitted_screen.dart';
import '../widgets/bottom_nav_shell.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/admin_login_screen.dart';
import '../screens/customer/provider_chat_screen.dart';
import '../screens/customer/welcome_screen.dart';
import '../screens/customer/signup_screen.dart';
import '../screens/customer/login_screen.dart';
import '../data/user_database.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

Map<String, dynamic>? _getBookingDetails(Object? extra) {
  if (extra is Map) {
    try {
      return Map<String, dynamic>.from(extra);
    } catch (_) {
      return extra.map((k, v) => MapEntry(k.toString(), v));
    }
  }
  return null;
}

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  redirect: (context, state) {
    final isAuthenticated = UserDatabase.isAuthenticated;
    final path = state.uri.path;
    final isCustomerRoute = path.startsWith('/customer');
    final isAuthRoute = path == '/customer/welcome' ||
                        path == '/customer/login' ||
                        path == '/customer/signup';

    // Unauthenticated user trying to access any protected customer screen
    // → redirect to welcome screen
    if (isCustomerRoute && !isAuthenticated && !isAuthRoute) {
      return '/customer/welcome';
    }

    // Authenticated user trying to access auth screens (welcome/login/signup)
    // → skip auth and go straight to home dashboard
    if (isAuthenticated && isAuthRoute) {
      return '/customer/home';
    }

    final isTechRoute = path.startsWith('/technician');
    final isTechAuthRoute = path == '/technician/welcome' ||
                            path == '/technician/login' ||
                            path == '/technician/register' ||
                            path == '/technician/service-info' ||
                            path == '/technician/documents' ||
                            path == '/technician/submitted';

    // Unauthenticated technician trying to access protected technician dashboard/insights/etc.
    if (isTechRoute && !UserDatabase.isTechAuthenticated && !isTechAuthRoute) {
      return '/technician/welcome';
    }

    // Authenticated technician trying to access welcome or login screen
    if (UserDatabase.isTechAuthenticated && (path == '/technician/welcome' || path == '/technician/login')) {
      return '/technician/home';
    }

    return null;
  },
  routes: [
    GoRoute(path: '/customer/welcome', builder: (context, state) => const WelcomeScreen()),
    GoRoute(path: '/customer/signup', builder: (context, state) => const SignupScreen()),
    GoRoute(path: '/customer/login', builder: (context, state) => const LoginScreen()),

    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/role-selection', builder: (context, state) => const RoleSelectionScreen()),

    // Customer flow with bottom nav
    ShellRoute(
      builder: (context, state, child) => BottomNavShell(
        currentPath: state.uri.toString(),
        isCustomer: true,
        child: child,
      ),
      routes: [
        GoRoute(path: '/customer/home', builder: (context, state) => const HomeScreen()),
        GoRoute(path: '/customer/bookings', builder: (context, state) => const MyBookingsScreen()),
        GoRoute(path: '/customer/track', builder: (context, state) => const FollowUpScreen()),
        GoRoute(path: '/customer/profile', builder: (context, state) => const ProfileScreen()),
      ],
    ),

    // Customer standalone screens (no bottom nav)
    GoRoute(path: '/customer/quick-service-form', builder: (context, state) => QuickServiceFormScreen(category: state.extra as String?)),
    GoRoute(path: '/customer/request-summary', builder: (context, state) => RequestSummaryScreen(queryText: state.extra as String?)),
    GoRoute(path: '/customer/ai-processing', builder: (context, state) => AiProcessingScreen(bookingDetails: _getBookingDetails(state.extra))),
    GoRoute(path: '/customer/provider-discovery', builder: (context, state) => ProviderDiscoveryScreen(bookingDetails: _getBookingDetails(state.extra))),
    GoRoute(
      path: '/customer/provider-details',
      builder: (context, state) {
        Map<String, dynamic>? tech;
        if (state.extra is Map) {
          tech = Map<String, dynamic>.from(state.extra as Map);
        }
        return ProviderDetailsScreen(technician: tech);
      },
    ),
    GoRoute(
      path: '/customer/provider-chat',
      builder: (context, state) {
        Map<String, dynamic>? tech;
        if (state.extra is Map) {
          tech = Map<String, dynamic>.from(state.extra as Map);
        }
        return ProviderChatScreen(technician: tech);
      },
    ),
    GoRoute(path: '/customer/booking-confirmed', builder: (context, state) => const BookingConfirmationScreen()),
    GoRoute(path: '/customer/ai-logs', builder: (context, state) => const AiReasoningLogsScreen()),

    // Technician flow with bottom nav
    ShellRoute(
      builder: (context, state, child) => BottomNavShell(
        currentPath: state.uri.toString(),
        isCustomer: false,
        child: child,
      ),
      routes: [
        GoRoute(path: '/technician/home', builder: (context, state) => const TechDashboardScreen()),
        GoRoute(path: '/technician/bookings', builder: (context, state) => const MyBookingsScreen()),
        GoRoute(path: '/technician/insights', builder: (context, state) => const TechPerformanceScreen()),
        GoRoute(path: '/technician/profile', builder: (context, state) => const ProfileScreen()),
      ],
    ),

    // Technician registration flow
    GoRoute(path: '/technician/welcome', builder: (context, state) => const TechWelcomeScreen()),
    GoRoute(path: '/technician/login', builder: (context, state) => const TechLoginScreen()),
    GoRoute(path: '/technician/register', builder: (context, state) => const TechRegistrationScreen()),
    GoRoute(path: '/technician/service-info', builder: (context, state) => const TechServiceInfoScreen()),
    GoRoute(path: '/technician/documents', builder: (context, state) => const TechDocumentsScreen()),
    GoRoute(path: '/technician/submitted', builder: (context, state) => const TechSubmittedScreen()),
    GoRoute(path: '/technician/navigation', builder: (context, state) => const TechNavigationScreen()),
    
    // Administrative backend portal
    GoRoute(path: '/admin/login', builder: (context, state) => const AdminLoginScreen()),
    GoRoute(path: '/admin/dashboard', builder: (context, state) => const AdminDashboardScreen()),
  ],
);
