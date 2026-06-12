import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/glass_panel.dart';
import '../../../../core/widgets/kinetic_skew.dart';
import '../../../../core/widgets/pill_button.dart';
import '../viewmodels/auth_viewmodel.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _keepSignedIn = false;
  String _selectedRole = 'player'; // default

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    final authVM = context.read<AuthViewModel>();
    final ok = await authVM.login(
      _emailController.text.trim(),
      _passwordController.text,
    );
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authVM.errorMessage ?? 'Login gagal'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    final role = authVM.currentUser!.role;
    if (role == 'owner') {
      Navigator.pushReplacementNamed(context, '/owner_dashboard');
    } else {
      Navigator.pushReplacementNamed(context, '/explore');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Layer with Asymmetric Tension & Blur
          Positioned.fill(
            child: Container(
              color: Colors.black,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.6,
                      child: Transform.scale(
                        scale: 1.1,
                        child: Transform.rotate(
                          angle: -0.02,
                          child: Image.network(
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuD0xztQrW3U4KCBPcY7SBaA02Hi7Gha4B6qEyw_SYehLRG2DQM2FTeRdF1bQigdCi3bK65HI0oaGUqBEXLXzcUqBolf4WG7d4ywzD3r6wQQnV3HgM_50CpIHv87fSTKgEUA2aY-vURocwPjA7rMNXWsvDQ6vryzfdw4T4hNoaS4f-8WxqAiNbNecSLYXkh9ZuJ10ENWDw27TTrvO0BmgL_c5CYVvRmQI_PlDhf_sZ556nCVo8Fbbmv664FItWSmj8Fz-uMKoKD31w',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withOpacity(0.4),
                            AppColors.secondaryFixed.withOpacity(0.2),
                          ],
                          begin: Alignment.bottomLeft,
                          end: Alignment.topRight,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Floating background graphics
          Positioned(
            top: 60,
            right: -20,
            child: Opacity(
              opacity: 0.15,
              child: Transform.rotate(
                angle: 0.2,
                child: Text(
                  '01',
                  style: AppTypography.displayLarge.copyWith(
                    fontSize: 220,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: -10,
            child: Opacity(
              opacity: 0.15,
              child: Transform.rotate(
                angle: -0.1,
                child: Text(
                  'MVP',
                  style: AppTypography.displayMedium.copyWith(
                    fontSize: 140,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w900,
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ),
          ),

          // Foreground Content Canvas
          Positioned.fill(
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Brand Identity
                      KineticSkew(
                        angleDegrees: -3.0,
                        child: Column(
                          children: [
                            Text(
                              'raketinAJA',
                              style: AppTypography.displayMedium.copyWith(
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primary,
                                shadows: [
                                  Shadow(
                                    color: AppColors.primary.withOpacity(0.4),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.secondaryContainer,
                                borderRadius: BorderRadius.circular(9999),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.flash_on,
                                    color: AppColors.onSecondaryContainer,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'PERFORMANCE PROTOCOL',
                                    style: AppTypography.labelSmall.copyWith(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.onSecondaryContainer,
                                      letterSpacing: 2.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Login Form Card with Glassmorphism
                      GlassPanel(
                        padding: const EdgeInsets.all(28.0),
                        borderRadius: 24.0,
                        border: Border.all(color: Colors.white.withOpacity(0.15)),
                        boxShadow: AppColors.ambientGlow,
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome Back',
                                style: AppTypography.headlineMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Synchronize your session to continue.',
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 28),

                              // Role Toggle (Interactive addition for usability)
                              Text(
                                'LOGIN ROLE',
                                style: AppTypography.labelSmall.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.secondary,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 6),
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
                              const SizedBox(height: 18),

                              // Email Input
                              CustomTextField(
                                label: 'Identity (Email)',
                                placeholder: 'athlete@velocity.core',
                                prefixIcon: Icons.alternate_email_outlined,
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
                              const SizedBox(height: 18),

                              // Password Input
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(left: 16.0),
                                        child: Text(
                                          'ACCESS KEY',
                                          style: AppTypography.labelSmall.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.secondary,
                                            letterSpacing: 1.5,
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.pushNamed(context, '/forgot_password');
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.only(right: 8.0),
                                          child: Text(
                                            'Forgot Password?',
                                            style: AppTypography.bodySmall.copyWith(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  CustomTextField(
                                    label: '',
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
                                ],
                              ),
                              const SizedBox(height: 20),

                              // Keep me signed in
                              Row(
                                children: [
                                  Checkbox(
                                    value: _keepSignedIn,
                                    activeColor: AppColors.secondaryContainer,
                                    checkColor: AppColors.onSecondaryContainer,
                                    onChanged: (val) {
                                      setState(() {
                                        _keepSignedIn = val ?? false;
                                      });
                                    },
                                  ),
                                  Text(
                                    'Keep me signed in',
                                    style: AppTypography.bodyMedium.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // Action Button
                              Consumer<AuthViewModel>(
                                builder: (context, vm, _) {
                                  return PillButton(
                                    text: vm.isLoading
                                        ? 'Authenticating...'
                                        : 'Enter raketinAJA',
                                    width: double.infinity,
                                    icon: const Icon(
                                      Icons.arrow_forward_ios,
                                      color: AppColors.onPrimary,
                                      size: 16,
                                    ),
                                    onPressed:
                                        vm.isLoading ? () {} : _handleLogin,
                                  );
                                },
                              ),
                              const SizedBox(height: 24),

                              // Bottom Pathway
                              Center(
                                child: Text.rich(
                                  TextSpan(
                                    text: 'New recruit? ',
                                    style: AppTypography.bodyMedium,
                                    children: [
                                      WidgetSpan(
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.pushNamed(context, '/register');
                                          },
                                          child: Text(
                                            'Request Access',
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
                      const SizedBox(height: 32),

                      // System Status Bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.secondaryContainer,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'SYSTEM ACTIVE',
                                style: AppTypography.labelSmall.copyWith(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 32),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.secondaryContainer,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'SECURE ENCRYPTED',
                                style: AppTypography.labelSmall.copyWith(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
