import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/pill_button.dart';
import '../viewmodels/auth_viewmodel.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  String _selectedRole = 'player';
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must agree to the Terms and Conditions'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final authVM = context.read<AuthViewModel>();
    final ok = await authVM.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text,
      role: _selectedRole,
    );
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authVM.errorMessage ?? 'Registrasi gagal'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Account successfully created!'),
        backgroundColor: AppColors.secondary,
      ),
    );

    if (_selectedRole == 'owner') {
      Navigator.pushReplacementNamed(context, '/owner_dashboard');
    } else {
      Navigator.pushReplacementNamed(context, '/explore');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    'Create Account',
                    style: AppTypography.displaySmall.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Join the next generation of athletic management.',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Identify As / Role Choice
                  Text(
                    'Identify As',
                    style: AppTypography.labelSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedRole = 'player';
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _selectedRole == 'player'
                                    ? AppColors.primary
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Player',
                                textAlign: TextAlign.center,
                                style: AppTypography.labelMedium.copyWith(
                                  color: _selectedRole == 'player'
                                      ? Colors.white
                                      : AppColors.onSurfaceVariant,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedRole = 'owner';
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _selectedRole == 'owner'
                                    ? AppColors.primary
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Owner',
                                textAlign: TextAlign.center,
                                style: AppTypography.labelMedium.copyWith(
                                  color: _selectedRole == 'owner'
                                      ? Colors.white
                                      : AppColors.onSurfaceVariant,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Full Name
                  CustomTextField(
                    label: 'Full Name',
                    placeholder: 'Alex Rivera',
                    prefixIcon: Icons.person_outline,
                    controller: _nameController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your full name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Email
                  CustomTextField(
                    label: 'Email Address',
                    placeholder: 'alex@raketinaja.com',
                    prefixIcon: Icons.mail_outline,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Phone Number
                  CustomTextField(
                    label: 'Phone Number',
                    placeholder: '+62 812-3456-789',
                    prefixIcon: Icons.phone_android_outlined,
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Password fields in Row on desktop, Column on mobile
                  CustomTextField(
                    label: 'Password',
                    placeholder: '••••••••',
                    isPassword: true,
                    prefixIcon: Icons.lock_outline,
                    controller: _passwordController,
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  CustomTextField(
                    label: 'Confirm Password',
                    placeholder: '••••••••',
                    isPassword: true,
                    prefixIcon: Icons.lock_outline,
                    controller: _confirmPasswordController,
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Terms checkbox
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _agreeToTerms,
                        activeColor: AppColors.primary,
                        onChanged: (val) {
                          setState(() {
                            _agreeToTerms = val ?? false;
                          });
                        },
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: Text.rich(
                            TextSpan(
                              text: 'I agree to the ',
                              style: AppTypography.bodySmall,
                              children: [
                                TextSpan(
                                  text: 'Terms and Conditions',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const TextSpan(text: ' and the '),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const TextSpan(text: '.'),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Submit Button
                  Consumer<AuthViewModel>(
                    builder: (context, vm, _) {
                      return PillButton(
                        text: vm.isLoading
                            ? 'Registering...'
                            : 'Complete Registration',
                        width: double.infinity,
                        icon: const Icon(
                          Icons.arrow_forward,
                          color: AppColors.onPrimary,
                        ),
                        onPressed: vm.isLoading ? () {} : _handleRegister,
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Sign In Redirect
                  Center(
                    child: Text.rich(
                      TextSpan(
                        text: 'Already have an account? ',
                        style: AppTypography.bodyMedium,
                        children: [
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                'Sign In',
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
