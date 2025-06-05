import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:new_flutter/services/auth_service.dart';
import 'package:new_flutter/services/logger_service.dart';
import 'package:new_flutter/theme/app_theme.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _agreeToTerms = false;
  String _error = '';
  int _passwordStrength = 0;
  List<String> _passwordFeedback = [];

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _checkPasswordStrength(String password) {
    int score = 0;
    List<String> feedback = [];

    if (password.length >= 8) {
      score++;
    } else {
      feedback.add('Password should be at least 8 characters');
    }

    if (password.contains(RegExp(r'[A-Z]'))) {
      score++;
    } else {
      feedback.add('Include at least one uppercase letter');
    }

    if (password.contains(RegExp(r'[a-z]'))) {
      score++;
    } else {
      feedback.add('Include at least one lowercase letter');
    }

    if (password.contains(RegExp(r'[0-9]'))) {
      score++;
    } else {
      feedback.add('Include at least one number');
    }

    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      score++;
    } else {
      feedback.add('Include at least one special character');
    }

    setState(() {
      _passwordStrength = score;
      _passwordFeedback = feedback;
    });
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeToTerms) {
      setState(() => _error = 'You must agree to the terms and conditions');
      return;
    }
    if (_passwordStrength < 3) {
      setState(() => _error = 'Please use a stronger password');
      return;
    }

    setState(() => _error = '');

    try {
      await context.read<AuthService>().signUp(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            fullName: _fullNameController.text.trim(),
          );
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/welcome');
      }
    } catch (e) {
      setState(
        () => _error = 'Could not create your account. Please try again.',
      );
    }
  }

  Future<void> _handleGoogleSignUp() async {
    setState(() => _error = '');

    try {
      await context.read<AuthService>().signInWithGoogle();
      // Navigation will be handled by auth state changes
    } catch (e) {
      setState(
        () => _error = 'Failed to sign up with Google. Please try again.',
      );
    }
  }

  Color _getPasswordStrengthColor() {
    switch (_passwordStrength) {
      case 0:
      case 1:
        return Colors.red;
      case 2:
      case 3:
        return Colors.yellow;
      case 4:
      case 5:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthService>().loading;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Back Button - Fixed at top
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      LoggerService.info('🔥 Back button clicked!');
                      Navigator.pop(context);
                    },
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
                ],
              ),
            ),

            // Main Content
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo
                      Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppTheme.goldColor.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            'assets/images/model_day_logo.png',
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              // Fallback to text logo if asset fails to load
                              return Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: AppTheme.goldColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Center(
                                  child: Text(
                                    'M',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ).animate().fadeIn(duration: 600.ms),

                      const SizedBox(height: 32),

                      // Sign Up Card
                      Container(
                        constraints: const BoxConstraints(maxWidth: 400),
                        decoration: AppTheme.cardDecoration,
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Create an account',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Join Model Day and take your modeling career to the next level',
                              style: TextStyle(color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),

                            // Google Sign Up Button
                            OutlinedButton.icon(
                              onPressed: isLoading ? null : _handleGoogleSignUp,
                              icon: const Icon(Icons.g_mobiledata, size: 20),
                              label: const Text('Sign up with Google'),
                              style: AppTheme.outlineButtonStyle,
                            ),

                            const SizedBox(height: 24),
                            const Row(
                              children: [
                                Expanded(child: Divider(color: Colors.grey)),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    'OR',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                                Expanded(child: Divider(color: Colors.grey)),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Error Message
                            if (_error.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.red.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.error_outline,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _error,
                                        style:
                                            const TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            if (_error.isNotEmpty) const SizedBox(height: 16),

                            // Sign Up Form
                            Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  TextFormField(
                                    controller: _fullNameController,
                                    decoration:
                                        AppTheme.textFieldDecoration.copyWith(
                                      labelText: 'Full Name',
                                      hintText: 'John Doe',
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your full name';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _emailController,
                                    decoration:
                                        AppTheme.textFieldDecoration.copyWith(
                                      labelText: 'Email',
                                      hintText: 'name@example.com',
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your email';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _passwordController,
                                    decoration:
                                        AppTheme.textFieldDecoration.copyWith(
                                      labelText: 'Password',
                                      hintText: '********',
                                    ),
                                    obscureText: true,
                                    onChanged: _checkPasswordStrength,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter a password';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  // Password Strength Indicator
                                  if (_passwordController.text.isNotEmpty)
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        LinearProgressIndicator(
                                          value: _passwordStrength / 5,
                                          backgroundColor: Colors.grey[800],
                                          color: _getPasswordStrengthColor(),
                                        ),
                                        const SizedBox(height: 8),
                                        ..._passwordFeedback.map(
                                          (feedback) => Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 4,
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.info_outline,
                                                  size: 16,
                                                  color: Colors.grey[400],
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  feedback,
                                                  style: TextStyle(
                                                    color: Colors.grey[400],
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _confirmPasswordController,
                                    decoration:
                                        AppTheme.textFieldDecoration.copyWith(
                                      labelText: 'Confirm Password',
                                      hintText: '********',
                                    ),
                                    obscureText: true,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please confirm your password';
                                      }
                                      if (value != _passwordController.text) {
                                        return 'Passwords do not match';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Checkbox(
                                        value: _agreeToTerms,
                                        onChanged: (value) {
                                          setState(
                                              () => _agreeToTerms = value!);
                                        },
                                        activeColor: AppTheme.goldColor,
                                      ),
                                      const Expanded(
                                        child: Text.rich(
                                          TextSpan(
                                            text: 'I agree to the ',
                                            style: TextStyle(
                                              color: Colors.grey,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: 'Terms and Conditions',
                                                style: TextStyle(
                                                  color: AppTheme.goldColor,
                                                  decoration:
                                                      TextDecoration.underline,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  ElevatedButton.icon(
                                    onPressed: isLoading ? null : _handleSignUp,
                                    icon: isLoading
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Icon(Icons.person_add),
                                    label: Text(
                                      isLoading
                                          ? 'Creating account...'
                                          : 'Create Account',
                                    ),
                                    style: AppTheme.primaryButtonStyle,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Already have an account? ',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushReplacementNamed(
                                      context,
                                      '/signin',
                                    );
                                  },
                                  child: const Text(
                                    'Sign in',
                                    style: TextStyle(color: AppTheme.goldColor),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 600.ms, delay: 200.ms),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
