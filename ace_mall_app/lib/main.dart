import 'package:flutter/material.dart';
import 'pages/intro_page.dart';
import 'pages/signin_page.dart';
import 'pages/hr_dashboard_page.dart';
import 'pages/ceo_dashboard_page.dart';
import 'pages/coo_dashboard_page.dart';
import 'pages/auditor_dashboard_page.dart';
import 'pages/branch_manager_dashboard_page.dart';
import 'pages/floor_manager_dashboard_page.dart';
import 'pages/compliance_officer_dashboard_page.dart';
import 'pages/facility_manager_dashboard_page.dart';
import 'pages/floor_manager_add_staff_page.dart';
import 'pages/floor_manager_team_page.dart';
import 'pages/floor_manager_team_reviews_page.dart';
import 'pages/add_general_staff_page.dart';
import 'pages/shift_times_page.dart';
import 'pages/roster_management_page.dart';
import 'pages/view_rosters_page.dart';
import 'pages/view_ratings_page.dart';
import 'pages/general_staff_dashboard_page.dart';
import 'pages/staff_type_selection_page.dart';
import 'pages/role_selection_page.dart';
import 'pages/branch_selection_page.dart';
import 'pages/department_selection_page.dart';
import 'pages/staff_profile_creation_page.dart';
import 'pages/test_image_upload_page.dart';
import 'pages/test_upload_types_page.dart';
import 'pages/staff_list_page.dart';
import 'pages/branch_staff_list_page.dart';
import 'pages/departments_management_page.dart';
import 'pages/staff_promotion_page.dart';
import 'pages/reports_analytics_page.dart';
import 'pages/staff_detail_page.dart';
import 'pages/branch_reports_page.dart';
import 'pages/branch_staff_performance_page.dart';
import 'pages/branch_departments_page.dart';
import 'pages/view_profile_page.dart';
import 'pages/my_reviews_page.dart';
import 'pages/my_schedule_page.dart';
import 'pages/notifications_page.dart';
import 'pages/staff_performance_page.dart';
import 'pages/terminated_staff_page.dart';
import 'pages/admin_messaging_page.dart';
import 'pages/forgot_password_page.dart';
import 'pages/change_password_page.dart';
import 'pages/change_email_page.dart';

void main() {
  runApp(const AceMallApp());
}

class AceMallApp extends StatelessWidget {
  const AceMallApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ace Mall Staff Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4CAF50),
          primary: const Color(0xFF4CAF50),
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        // Handle routes with arguments
        if (settings.name == '/role-selection') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => RoleSelectionPage(
              staffType: args['staffType'],
            ),
          );
        }
        if (settings.name == '/branch-selection') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => BranchSelectionPage(
              staffType: args['staffType'],
              role: args['role'],
            ),
          );
        }
        if (settings.name == '/department-selection') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => DepartmentSelectionPage(
              staffType: args['staffType'],
              role: args['role'],
              branch: args['branch'],
            ),
          );
        }
        if (settings.name == '/profile-creation') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => StaffProfileCreationPage(
              staffType: args['staffType'],
              role: args['role'],
              branch: args['branch'],
            ),
          );
        }
        if (settings.name == '/staff-detail') {
          final staff = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => StaffDetailPage(staff: staff),
          );
        }
        if (settings.name == '/add-general-staff') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => AddGeneralStaffPage(userRole: args['userRole']),
          );
        }
        return null;
      },
      routes: {
        '/': (context) => const IntroPage(),
        '/signin': (context) => const SignInPage(),
        '/forgot-password': (context) => const ForgotPasswordPage(),
        '/hr-dashboard': (context) => const HRDashboardPage(),
        '/ceo-dashboard': (context) => const CEODashboardPage(),
        '/coo-dashboard': (context) => const COODashboardPage(),
        '/auditor-dashboard': (context) => const AuditorDashboardPage(),
        '/branch-manager-dashboard': (context) => const BranchManagerDashboardPage(),
        '/operations-manager-dashboard': (context) => const FloorManagerDashboardPage(),
        '/supervisor-dashboard': (context) => const FloorManagerDashboardPage(),
        '/floor-manager-dashboard': (context) => const FloorManagerDashboardPage(),
        '/compliance-officer-dashboard': (context) => const ComplianceOfficerDashboardPage(),
        '/facility-manager-dashboard': (context) => const FacilityManagerDashboardPage(),
        '/floor-manager-add-staff': (context) => const FloorManagerAddStaffPage(),
        '/floor-manager-team': (context) => const FloorManagerTeamPage(),
        '/floor-manager-team-reviews': (context) => const FloorManagerTeamReviewsPage(),
        '/shift-times': (context) => const ShiftTimesPage(),
        '/roster-management': (context) => const RosterManagementPage(),
        '/view-rosters': (context) => const ViewRostersPage(),
        '/view-ratings': (context) => const ViewRatingsPage(),
        '/general-staff-dashboard': (context) => const GeneralStaffDashboardPage(),
        '/staff-type-selection': (context) => const StaffTypeSelectionPage(),
        '/test-image-upload': (context) => const TestImageUploadPage(),
        '/test-upload-types': (context) => const TestUploadTypesPage(),
        '/staff-list': (context) => const StaffListPage(),
        '/branch-staff-list': (context) => const BranchStaffListPage(),
        '/departments-management': (context) => const DepartmentsManagementPage(),
        '/staff-promotion': (context) => const StaffPromotionPage(),
        '/reports-analytics': (context) => const ReportsAnalyticsPage(),
        '/branch-reports': (context) => const BranchReportsPage(),
        '/branch-staff-performance': (context) => const BranchStaffPerformancePage(),
        '/branch-departments': (context) => const BranchDepartmentsPage(),
        '/profile': (context) => const ViewProfilePage(),
        '/my-reviews': (context) => const MyReviewsPage(),
        '/my-schedule': (context) => const MySchedulePage(),
        '/notifications': (context) => const NotificationsPage(),
        '/staff-performance': (context) => const StaffPerformancePage(),
        '/terminated-staff': (context) => const TerminatedStaffPage(),
        '/admin-messaging': (context) => const AdminMessagingPage(),
        '/change-password': (context) => const ChangePasswordPage(),
        '/change-email': (context) => const ChangeEmailPage(),
      },
    );
  }
}
