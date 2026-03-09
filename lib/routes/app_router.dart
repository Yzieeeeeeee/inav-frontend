import 'package:go_router/go_router.dart';
import 'package:edupro_e_learning_app_community_3968448878/authentication/signup.dart';
import 'package:edupro_e_learning_app_community_3968448878/views/account_set_up_screen.dart';
import 'package:edupro_e_learning_app_community_3968448878/views/all_loan_offers.dart';
import 'package:edupro_e_learning_app_community_3968448878/views/homepage.dart';
import 'package:edupro_e_learning_app_community_3968448878/views/loan_screen.dart';
import 'package:edupro_e_learning_app_community_3968448878/views/onboarding_page.dart';
import 'package:edupro_e_learning_app_community_3968448878/views/payment_history_page.dart';
import 'package:edupro_e_learning_app_community_3968448878/views/payment_success_page.dart';
import 'package:edupro_e_learning_app_community_3968448878/views/profile_page.dart';
import 'package:edupro_e_learning_app_community_3968448878/views/emi_schedule_page.dart';

import '../authentication/login.dart';
import '../views/bottom_navigation.dart';
import '../views/emi_pay_submit_section.dart';
import '../views/notifications_page.dart';
import '../views/about_page.dart';
import '../views/privacy_policy_page.dart';
import '../views/help_support_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: "/onboard",
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(path: '/signup', builder: (context, state) => const Signup()),
    GoRoute(path: '/homepage', builder: (context, state) => const HomePage()),
    GoRoute(path: "/navig", builder: (context, state) => const Navigation()),
    GoRoute(path: "/loan", builder: (context, state) => LoanDetailsScreen()),
    GoRoute(
      path: "/loan-detail/:id",
      builder: (context, state) {
        // Safe cast extras to LoanModel
        final loan = state.extra is LoanModel ? state.extra as LoanModel : null;
        return LoanDetailsScreen(loan: loan);
      },
    ),
    GoRoute(
      path: "/pay-history",
      builder: (context, state) {
        final account = state.extra as String?;
        return PaymentHistoryScreen(accountNumber: account);
      },
    ),
    GoRoute(
      path: "/Emi-submit",
      builder: (context, state) {
        final loan = state.extra is LoanModel ? state.extra as LoanModel : null;
        return EmiPaymentScreen(loan: loan);
      },
    ),
    GoRoute(
      path: "/emi-schedule",
      builder: (context, state) {
        final loan = state.extra is LoanModel ? state.extra as LoanModel : null;
        // fallback to empty or non-nullable if structured that way.
        return EmiSchedulePage(loan: loan!);
      },
    ),
    GoRoute(
      path: "/payment-success",
      builder: (c, s) {
        if (s.extra is Map<String, dynamic>) {
          final extra = s.extra as Map<String, dynamic>;
          final loan = extra['loan'] as LoanModel?;
          final accountName = extra['accountName'] as String?;
          final paidAmount = extra['paidAmount'] as double?;
          final isPartial = extra['isPartial'] as bool?;
          return PaymentSuccessPage(
            loan: loan,
            accountName: accountName,
            paidAmount: paidAmount,
            isPartial: isPartial,
          );
        }
        final loan = s.extra is LoanModel ? s.extra as LoanModel : null;
        return PaymentSuccessPage(loan: loan);
      },
    ),
    GoRoute(
      path: "/profile",
      builder: (context, state) => ProfileScreen(),
    ),
    GoRoute(
      path: "/account-setup",
      builder: (context, state) => AccountSetupScreen(),
    ),
    GoRoute(
      path: "/onboard",
      builder: (context, state) => OnboardingScreen(),
    ),
    GoRoute(
      path: "/loan-offer",
      builder: (context, state) => AllLoansScreen(),
    ),
    GoRoute(
      path: "/notifications",
      builder: (c, s) => const NotificationsPage(),
    ),
    GoRoute(
      path: "/about",
      builder: (c, s) => const AboutPage(),
    ),
    GoRoute(
      path: "/privacy",
      builder: (c, s) => const PrivacyPolicyPage(),
    ),
    GoRoute(
      path: "/help",
      builder: (c, s) => const HelpSupportPage(),
    ),
  ],
);
