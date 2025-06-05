import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Wait for auth service to initialize
      final authService = context.read<AuthService>();

      // Wait a minimum time for splash screen visibility
      await Future.wait([
        Future.delayed(const Duration(seconds: 2)),
        _waitForAuthInitialization(authService),
      ]);

      if (!mounted) return;

      // Navigate based on authentication status
      if (authService.isAuthenticated) {
        Navigator.pushReplacementNamed(context, '/welcome');
      } else {
        Navigator.pushReplacementNamed(context, '/landing');
      }
    } catch (e) {
      debugPrint('Splash initialization error: $e');
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/landing');
      }
    }
  }

  Future<void> _waitForAuthInitialization(AuthService authService) async {
    // Wait for auth service to complete initialization
    while (!authService.isInitialized) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<AuthService>(
        builder: (context, authService, child) {
          return Stack(
            children: [
              // Background gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black,
                      Colors.grey[900]!,
                      Colors.black,
                    ],
                  ),
                ),
              ),

              // Main content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(60), // Make it circular
                        border: Border.all(
                          color: AppTheme.goldColor.withValues(alpha: 0.5),
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.goldColor.withValues(alpha: 0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(60),
                        child: Image.asset(
                          'assets/images/model_day_logo.png',
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            // Fallback to icon if asset fails to load
                            return Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: AppTheme.goldColor,
                                borderRadius: BorderRadius.circular(60),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 60,
                                color: Colors.black,
                              ),
                            );
                          },
                        ),
                      ),
                    )
                        .animate()
                        .scale(
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.elasticOut,
                        )
                        .fadeIn(duration: const Duration(milliseconds: 600)),

                    const SizedBox(height: 32),

                    // App name
                    const Text(
                      'Model Day',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.goldColor,
                        letterSpacing: 2,
                      ),
                    )
                        .animate()
                        .fadeIn(
                          delay: const Duration(milliseconds: 400),
                          duration: const Duration(milliseconds: 800),
                        )
                        .slideY(
                          begin: 0.3,
                          end: 0,
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeOut,
                        ),

                    const SizedBox(height: 16),

                    // Tagline
                    Text(
                      'Your Professional Portfolio',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: 0.8),
                        letterSpacing: 1,
                      ),
                    ).animate().fadeIn(
                          delay: const Duration(milliseconds: 800),
                          duration: const Duration(milliseconds: 600),
                        ),

                    const SizedBox(height: 64),

                    // Loading indicator
                    Column(
                      children: [
                        const SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.goldColor,
                            ),
                          ),
                        )
                            .animate(
                                onPlay: (controller) => controller.repeat())
                            .rotate(duration: const Duration(seconds: 2)),
                        const SizedBox(height: 16),
                        Text(
                          authService.loading
                              ? 'Signing you in...'
                              : authService.isInitialized
                                  ? 'Welcome back!'
                                  : 'Initializing...',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ).animate().fadeIn(
                              delay: const Duration(milliseconds: 1200),
                              duration: const Duration(milliseconds: 400),
                            ),
                      ],
                    ),
                  ],
                ),
              ),

              // Version info at bottom
              Positioned(
                bottom: 32,
                left: 0,
                right: 0,
                child: Text(
                  'Version 1.0.0',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                ).animate().fadeIn(
                      delay: const Duration(milliseconds: 1600),
                      duration: const Duration(milliseconds: 400),
                    ),
              ),
            ],
          );
        },
      ),
    );
  }
}
