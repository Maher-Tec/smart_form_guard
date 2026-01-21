import 'package:flutter/material.dart';
import 'package:smart_form_guard/smart_form_guard.dart';

void main() {
  runApp(const SmartFormGuardExample());
}

class SmartFormGuardExample extends StatelessWidget {
  const SmartFormGuardExample({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Form Guard Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1), // Indigo
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      home: const SignUpScreen(),
    );
  }
}

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _selectedRole;
  DateTime? _birthDate;
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _onFormValid() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Text('Account created successfully! 🎉'),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Create Account',
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Join us to get started',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 40),

              // Smart Form
              SmartForm(
                onValid: _onFormValid,
                child: Column(
                  children: [
                    // Name field
                    SmartField.required(
                      controller: _nameController,
                      label: 'Full Name',
                      hint: 'Enter your full name',
                      prefixIcon: Icons.person_outline,
                    ),
                    const SizedBox(height: 20),

                    // Email field
                    SmartField.email(
                      controller: _emailController,
                      label: 'Email',
                    ),
                    const SizedBox(height: 20),

                    // Phone field
                    SmartField.phone(
                      controller: _phoneController,
                      label: 'Phone Number',
                    ),
                    const SizedBox(height: 20),

                    SmartField.password(
                      controller: _passwordController,
                      label: 'Password',
                      hint: 'Enter your password',
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                    const SizedBox(height: 20),

                    // Role Dropdown
                    SmartDropdown<String>(
                      label: 'Account Role',
                      hint: 'Select your role',
                      value: _selectedRole,
                      prefixIcon: Icons.work_outline,
                      items: [
                        DropdownMenuItem(
                          value: 'developer',
                          child: Row(
                            children: [
                              Icon(Icons.code, size: 20, color: theme.colorScheme.primary),
                              const SizedBox(width: 12),
                              const Text('Developer'),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'designer',
                          child: Row(
                            children: [
                              Icon(Icons.palette_outlined, size: 20, color: theme.colorScheme.tertiary),
                              const SizedBox(width: 12),
                              const Text('Designer'),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'manager',
                          child: Row(
                            children: [
                              Icon(Icons.people_outline, size: 20, color: theme.colorScheme.secondary),
                              const SizedBox(width: 12),
                              const Text('Manager'),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'other',
                          child: Row(
                            children: [
                              Icon(Icons.more_horiz, size: 20, color: theme.colorScheme.outline),
                              const SizedBox(width: 12),
                              const Text('Other'),
                            ],
                          ),
                        ),
                      ],
                      validator: (value) => value == null ? 'Please select a role' : null,
                      onChanged: (value) => setState(() => _selectedRole = value),
                    ),

                    const SizedBox(height: 20),

                    // Birth Date Picker
                    SmartDatePicker(
                      label: 'Birth Date',
                      value: _birthDate,
                      validator: (value) => value == null ? 'Please select your birth date' : null,
                      onChanged: (value) => setState(() => _birthDate = value),
                    ),
                    const SizedBox(height: 20),

                    // Terms Checkbox
                    SmartCheckbox(
                      title: const Text('I agree to the Terms and Conditions'),
                      value: _agreedToTerms,
                      validator: (value) => value != true ? 'You must agree to continue' : null,
                      onChanged: (value) => setState(() => _agreedToTerms = value ?? false),
                    ),
                    const SizedBox(height: 32),

                    // Submit button
                    SmartSubmitButton(
                      text: 'Create Account',
                      icon: Icons.arrow_forward,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),

              // Footer
              Center(
                child: Text.rich(
                  TextSpan(
                    text: 'Already have an account? ',
                    style: theme.textTheme.bodyMedium,
                    children: [
                      TextSpan(
                        text: 'Sign In',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
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
    );
  }
}
