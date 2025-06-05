import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:new_flutter/services/auth_service.dart';
import 'package:new_flutter/services/jobs_service.dart';
import 'package:new_flutter/services/shootings_service.dart';
import 'package:new_flutter/services/polaroids_service.dart';
import 'package:new_flutter/services/meetings_service.dart';
import 'package:new_flutter/theme/app_theme.dart';
import 'package:new_flutter/widgets/app_layout.dart';

import 'package:new_flutter/widgets/onboarding/welcome_guide.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  int totalShootings = 0;
  int totalPolaroids = 0;
  int upcomingMeetings = 0;
  int totalJobs = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
    _loadDashboardData();
  }

  Future<void> _checkOnboardingStatus() async {
    try {
      final authService = context.read<AuthService>();
      final user = authService.currentUser;

      if (user != null) {
        debugPrint('Welcome Page - User: ${user.email}');
        debugPrint('Welcome Page - Showing tour overlay for every login');

        // Show the tour for every user on every login
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            _showTourOverlay();
          }
        });
      }
    } catch (error) {
      debugPrint('Error checking onboarding status: $error');
    }
  }

  String _extractUsername(String email) {
    // Extract username from email (part before @)
    return email.split('@').first;
  }

  Future<void> _loadDashboardData() async {
    try {
      final shootings = await ShootingsService().getShootings();
      final polaroids = await PolaroidsService().getPolaroids();
      final meetings = await MeetingsService().getUpcomingMeetings();
      final jobs = await JobsService.list();

      if (mounted) {
        setState(() {
          totalShootings = shootings.length;
          totalPolaroids = polaroids.length;
          upcomingMeetings = meetings.length;
          totalJobs = jobs.length;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading dashboard data: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().currentUser;

    return Stack(
      children: [
        AppLayout(
          currentPage: '/welcome',
          title: 'Welcome',
          child: SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black,
                    Colors.grey[900]!.withValues(alpha: 0.8),
                    Colors.black,
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero Welcome Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 32),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppTheme.goldColor.withValues(alpha: 0.1),
                            Colors.transparent,
                            AppTheme.goldColor.withValues(alpha: 0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppTheme.goldColor.withValues(alpha: 0.2),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.goldColor.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Welcome Text with Custom Typography
                          RichText(
                            text: TextSpan(
                              children: [
                                const TextSpan(
                                  text: 'Welcome back,\n',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w300,
                                    color: Colors.white70,
                                    height: 1.2,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                if (user?.email != null)
                                  TextSpan(
                                    text: _extractUsername(user!.email!),
                                    style: const TextStyle(
                                      fontSize: 42,
                                      fontWeight: FontWeight.w900,
                                      color: AppTheme.goldColor,
                                      height: 1.1,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                const TextSpan(
                                  text: '!',
                                  style: TextStyle(
                                    fontSize: 42,
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.goldColor,
                                    height: 1.1,
                                  ),
                                ),
                              ],
                            ),
                          ).animate().fadeIn(duration: 800.ms).slideX(begin: -0.2),

                          const SizedBox(height: 16),

                          // Subtitle
                          Text(
                            'Ready to elevate your modeling career today?',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withValues(alpha: 0.8),
                              letterSpacing: 0.3,
                            ),
                          ).animate().fadeIn(duration: 800.ms, delay: 200.ms).slideX(begin: -0.2),
                        ],
                      ),
                    ).animate().fadeIn(duration: 1000.ms).scale(begin: const Offset(0.95, 0.95)),

                    const SizedBox(height: 40),

                    // Enhanced Stats Grid
                    _buildStatsSection(),

                    const SizedBox(height: 40),

                    // Enhanced Recent Activity Section
                    _buildRecentActivitySection(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 600;
        final isMediumScreen = constraints.maxWidth < 900;

        if (isSmallScreen) {
          // Mobile: 2x2 grid with enhanced design
          return Column(
            children: [
              Row(
                children: [
                  Expanded(child: _buildStatCard(
                    icon: Icons.camera_alt,
                    label: 'Shootings',
                    value: isLoading ? '...' : totalShootings.toString(),
                    color: Colors.purple,
                    isLoading: isLoading,
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard(
                    icon: Icons.image,
                    label: 'Polaroids',
                    value: isLoading ? '...' : totalPolaroids.toString(),
                    color: Colors.blue,
                    isLoading: isLoading,
                  )),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildStatCard(
                    icon: Icons.calendar_today,
                    label: 'Meetings',
                    value: isLoading ? '...' : upcomingMeetings.toString(),
                    color: Colors.green,
                    isLoading: isLoading,
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard(
                    icon: Icons.work,
                    label: 'Jobs',
                    value: isLoading ? '...' : totalJobs.toString(),
                    color: AppTheme.goldColor,
                    isLoading: isLoading,
                  )),
                ],
              ),
            ],
          );
        } else if (isMediumScreen) {
          // Tablet: 2x2 grid with larger cards
          return Column(
            children: [
              Row(
                children: [
                  Expanded(child: _buildStatCard(
                    icon: Icons.camera_alt,
                    label: 'Total Shootings',
                    value: isLoading ? '...' : totalShootings.toString(),
                    color: Colors.purple,
                    isLoading: isLoading,
                  )),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatCard(
                    icon: Icons.image,
                    label: 'Polaroids',
                    value: isLoading ? '...' : totalPolaroids.toString(),
                    color: Colors.blue,
                    isLoading: isLoading,
                  )),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildStatCard(
                    icon: Icons.calendar_today,
                    label: 'Upcoming Meetings',
                    value: isLoading ? '...' : upcomingMeetings.toString(),
                    color: Colors.green,
                    isLoading: isLoading,
                  )),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatCard(
                    icon: Icons.work,
                    label: 'Total Jobs',
                    value: isLoading ? '...' : totalJobs.toString(),
                    color: AppTheme.goldColor,
                    isLoading: isLoading,
                  )),
                ],
              ),
            ],
          );
        } else {
          // Desktop: Single row with 4 columns
          return Row(
            children: [
              Expanded(child: _buildStatCard(
                icon: Icons.camera_alt,
                label: 'Total Shootings',
                value: isLoading ? '...' : totalShootings.toString(),
                color: Colors.purple,
                isLoading: isLoading,
              )),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard(
                icon: Icons.image,
                label: 'Polaroids',
                value: isLoading ? '...' : totalPolaroids.toString(),
                color: Colors.blue,
                isLoading: isLoading,
              )),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard(
                icon: Icons.calendar_today,
                label: 'Upcoming Meetings',
                value: isLoading ? '...' : upcomingMeetings.toString(),
                color: Colors.green,
                isLoading: isLoading,
              )),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard(
                icon: Icons.work,
                label: 'Total Jobs',
                value: isLoading ? '...' : totalJobs.toString(),
                color: AppTheme.goldColor,
                isLoading: isLoading,
              )),
            ],
          );
        }
      },
    ).animate().fadeIn(duration: 800.ms, delay: 400.ms).slideY(begin: 0.3);
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isLoading,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallCard = constraints.maxWidth < 200;

        return Container(
          height: isSmallCard ? 110 : 130,
          padding: EdgeInsets.all(isSmallCard ? 12 : 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.1),
                Colors.transparent,
                color.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Icon container
              Container(
                padding: EdgeInsets.all(isSmallCard ? 6 : 8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: isSmallCard ? 16 : 18,
                ),
              ),

              // Spacer to push content to bottom
              const Spacer(),

              // Content area
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Value
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      isLoading ? '...' : value,
                      style: TextStyle(
                        fontSize: isSmallCard ? 20 : 24,
                        fontWeight: FontWeight.w900,
                        color: color,
                        height: 1,
                      ),
                    ),
                  ),

                  SizedBox(height: isSmallCard ? 2 : 4),

                  // Label
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: isSmallCard ? 10 : 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.7),
                      letterSpacing: 0.1,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecentActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                color: AppTheme.goldColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ).animate().fadeIn(duration: 800.ms, delay: 600.ms).slideX(begin: -0.3),

        const SizedBox(height: 24),

        // Activity Cards
        Column(
          children: [
            _buildActivityCard(
              icon: Icons.camera_alt,
              title: 'New Shooting Added',
              description: 'Fashion Editorial for Vogue',
              time: '2 hours ago',
              color: Colors.purple,
              delay: 700,
            ),
            const SizedBox(height: 12),
            _buildActivityCard(
              icon: Icons.image,
              title: 'Polaroids Updated',
              description: 'Added 6 new polaroids',
              time: '4 hours ago',
              color: Colors.blue,
              delay: 800,
            ),
            const SizedBox(height: 12),
            _buildActivityCard(
              icon: Icons.calendar_today,
              title: 'Meeting Scheduled',
              description: 'Meeting with Elite Models',
              time: '1 day ago',
              color: Colors.green,
              delay: 900,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActivityCard({
    required IconData icon,
    required String title,
    required String description,
    required String time,
    required Color color,
    required int delay,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900]!.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: Duration(milliseconds: delay)).slideX(begin: 0.3);
  }

  void _showTourOverlay() {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black.withValues(alpha: 0.6),
        pageBuilder: (context, animation, secondaryAnimation) {
          return WelcomeGuide(
            isOpen: true,
            onClose: () {
              Navigator.of(context).pop();
            },
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }
}
