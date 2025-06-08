import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:new_flutter/pages/landing_page.dart';
import 'package:new_flutter/pages/sign_in_page.dart';
import 'package:new_flutter/pages/sign_up_page.dart';
import 'package:new_flutter/pages/welcome_page.dart';
import 'package:new_flutter/pages/calendar_page.dart';
import 'package:new_flutter/pages/all_activities_page.dart';
import 'package:new_flutter/pages/enhanced_direct_bookings_page.dart';
import 'package:new_flutter/pages/direct_options_page.dart';
import 'package:new_flutter/pages/jobs_page_simple.dart';
import 'package:new_flutter/pages/castings_page.dart';
import 'package:new_flutter/pages/tests_page.dart';
import 'package:new_flutter/pages/on_stay_page.dart';
import 'package:new_flutter/pages/shootings_page.dart';
import 'package:new_flutter/pages/polaroids_page.dart';
import 'package:new_flutter/pages/meetings_page.dart';
import 'package:new_flutter/pages/ai_jobs_page.dart';
import 'package:new_flutter/pages/ai_chat_page.dart';
import 'package:new_flutter/pages/agencies_page.dart';
import 'package:new_flutter/pages/agents_page.dart';
import 'package:new_flutter/pages/industry_contacts_page.dart';
import 'package:new_flutter/pages/job_gallery_page.dart';
import 'package:new_flutter/pages/profile_page.dart';
import 'package:new_flutter/pages/settings_page.dart';
import 'package:new_flutter/pages/new_job_page.dart';
import 'package:new_flutter/pages/new_ai_job_page.dart';
import 'package:new_flutter/pages/new_job_gallery_page.dart';
import 'package:new_flutter/pages/forgot_password_page.dart';
import 'package:new_flutter/pages/register_page.dart';
import 'package:new_flutter/pages/supabase_test_page.dart';
import 'package:new_flutter/pages/edit_direct_booking_page.dart';
import 'package:new_flutter/pages/auth_callback_page.dart';
import 'package:new_flutter/pages/add_event_page.dart';
import 'package:new_flutter/pages/new_agency_page.dart';
import 'package:new_flutter/pages/new_agent_page.dart';
import 'package:new_flutter/pages/new_industry_contact_page.dart';
import 'package:new_flutter/pages/splash_page.dart';
import 'package:new_flutter/pages/new_event_page.dart';
import 'package:new_flutter/models/event.dart';
import 'package:new_flutter/services/auth_service.dart';
import 'package:new_flutter/services/api_client.dart';
import 'package:new_flutter/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://nvawwmygojhhvimvjiif.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im52YXd3bXlnb2poaHZpbXZqaWlmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDU0MzIyMDksImV4cCI6MjA2MTAwODIwOX0.tlTfrUuwdbspyoE6uptKupTCYNuIp3lZMLfGNL3aT7I',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final authService = AuthService();
        // Initialize API client with auth service
        ApiClient.initialize(authService);
        return authService;
      },
      child: MaterialApp(
        title: 'Model Day',
        debugShowCheckedModeBanner: false, // Remove debug banner
        navigatorKey: navigatorKey,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.dark(
            primary: AppTheme.goldColor,
            secondary: AppTheme.goldColor,
            surface: Colors.grey[900]!,
          ),
          textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
          scaffoldBackgroundColor: Colors.black,
        ),
        initialRoute: '/',
        onUnknownRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => const LandingPage(),
          );
        },
        routes: {
          '/': (context) => const SplashPage(),
          '/landing': (context) => const LandingPage(),
          '/signin': (context) => const SignInPage(),
          '/signup': (context) => const SignUpPage(),
          '/welcome': (context) => const WelcomePage(),
          '/calendar': (context) => const CalendarPage(),
          '/activities': (context) => const AllActivitiesPage(),
          '/event-types': (context) => const AllActivitiesPage(), // Placeholder
          '/ai': (context) => const AIChatPage(),
          '/contacts': (context) => const IndustryContactsPage(),
          '/gallery': (context) => const JobGalleryPage(),
          '/all-activities': (context) => const AllActivitiesPage(),
          '/direct-bookings': (context) => const EnhancedDirectBookingsPage(),
          '/direct-options': (context) => const DirectOptionsPage(),
          '/jobs': (context) => const JobsPageSimple(),
          '/castings': (context) => const CastingsPage(),
          '/tests': (context) => const TestsPage(),
          '/on-stay': (context) => const OnStayPage(),
          '/shootings': (context) => const ShootingsPage(),
          '/polaroids': (context) => const PolaroidsPage(),
          '/meetings': (context) => const MeetingsPage(),
          '/ai-jobs': (context) => const AiJobsPage(),
          '/ai-chat': (context) => const AIChatPage(),
          '/agencies': (context) => const AgenciesPage(),
          '/agents': (context) => const AgentsPage(),
          '/industry-contacts': (context) => const IndustryContactsPage(),
          '/job-gallery': (context) => const JobGalleryPage(),
          '/profile': (context) => const ProfilePage(),
          '/settings': (context) => const SettingsPage(),
          '/new-job': (context) => const NewJobPage(),
          '/new-option': (context) => const NewEventPage(eventType: EventType.option),
          '/new-direct-option': (context) => const NewEventPage(eventType: EventType.directOption),
          '/new-direct-booking': (context) => const NewEventPage(eventType: EventType.directBooking),
          '/new-casting': (context) => const NewEventPage(eventType: EventType.casting),
          '/new-on-stay': (context) => const NewEventPage(eventType: EventType.onStay),
          '/new-test': (context) => const NewEventPage(eventType: EventType.test),
          '/new-polaroids': (context) => const NewEventPage(eventType: EventType.polaroids),
          '/new-meeting': (context) => const NewEventPage(eventType: EventType.meeting),
          '/new-other': (context) => const NewEventPage(eventType: EventType.other),
          '/new-ai-job': (context) => const NewAiJobPage(),
          '/new-job-gallery': (context) => const NewJobGalleryPage(),
          '/forgot-password': (context) => const ForgotPasswordPage(),
          '/register': (context) => const RegisterPage(),
          '/supabase-test': (context) => const SupabaseTestPage(),
          '/edit-direct-booking': (context) => const EditDirectBookingPage(),
          '/auth/callback': (context) => const AuthCallbackPage(),
          '/add-event': (context) => const AddEventPage(),
          '/new-agency': (context) => const NewAgencyPage(),
          '/new-agent': (context) => const NewAgentPage(),
          '/new-industry-contact': (context) => const NewIndustryContactPage(),
        },
      ),
    );
  }
}
