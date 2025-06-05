import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:new_flutter/services/auth_service.dart';
import 'package:new_flutter/theme/app_theme.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _error = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _error = '');

    try {
      await context.read<AuthService>().signIn(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/welcome');
      }
    } catch (e) {
      setState(() => _error = 'Invalid email or password. Please try again.');
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _error = '');

    try {
      await context.read<AuthService>().signInWithGoogle();
      // Navigation will be handled by auth state changes
    } catch (e) {
      setState(
        () => _error = 'Failed to sign in with Google. Please try again.',
      );
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
                      print('🔥 Back button clicked!');
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

                      // Sign In Card
                      Container(
                        constraints: const BoxConstraints(maxWidth: 400),
                        decoration: AppTheme.cardDecoration,
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Sign In',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Welcome back to Model Day',
                              style: TextStyle(color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),

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

                            // Sign In Form
                            Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  TextFormField(
                                    controller: _emailController,
                                    decoration:
                                        AppTheme.textFieldDecoration.copyWith(
                                      labelText: 'Email',
                                      hintText: 'name@example.com',
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
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
                                    textInputAction: TextInputAction.done,
                                    onFieldSubmitted: (_) async =>
                                        await _handleSignIn(),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your password';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.pushNamed(
                                            context, '/forgot-password');
                                      },
                                      child: const Text(
                                        'Forgot password?',
                                        style: TextStyle(
                                            color: AppTheme.goldColor),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    onPressed: isLoading ? null : _handleSignIn,
                                    icon: isLoading
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Icon(Icons.login),
                                    label: Text(
                                      isLoading ? 'Signing in...' : 'Sign In',
                                    ),
                                    style: AppTheme.primaryButtonStyle,
                                  ),
                                  const SizedBox(height: 24),
                                  const Row(
                                    children: [
                                      Expanded(
                                          child: Divider(color: Colors.grey)),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 16,
                                        ),
                                        child: Text(
                                          'OR',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ),
                                      Expanded(
                                          child: Divider(color: Colors.grey)),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  OutlinedButton.icon(
                                    onPressed:
                                        isLoading ? null : _handleGoogleSignIn,
                                    icon: const Icon(
                                      Icons.g_mobiledata,
                                      size: 20,
                                    ),
                                    label: const Text('Sign in with Google'),
                                    style: AppTheme.outlineButtonStyle,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Don\'t have an account? ',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushReplacementNamed(
                                      context,
                                      '/signup',
                                    );
                                  },
                                  child: const Text(
                                    'Sign up',
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
