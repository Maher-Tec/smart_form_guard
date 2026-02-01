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
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _selectedRole;
  String? _experienceLevel;
  DateTime? _birthDate;
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
                    // Username field with Async Validator
                    SmartField(
                      controller: _nameController,
                      label: 'Username',
                      hint: 'Choose a unique username',
                      prefixIcon: Icons.alternate_email,
                      validator: (value) => 
                        (value == null || value.isEmpty) ? 'Username is required' : null,
                      asyncValidator: (value) async {
                        // Simulate network request
                        await Future.delayed(const Duration(seconds: 2));
                        if (value!.toLowerCase() == 'admin') {
                          return 'This username is already taken';
                        }
                        return null;
                      },
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

                    // Confirm Password
                    SmartField.confirmPassword(
                      controller: _confirmPasswordController, // Use persistent controller
                      passwordController: _passwordController,
                      label: 'Confirm Password',
                      hint: 'Re-enter your password',
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                    const SizedBox(height: 20),

                    // Role Dropdown
                    SmartDropdown<String>(
                      label: 'Account Role',
                      hint: 'Select your role',
                      value: _selectedRole,
                      prefixIcon: Icons.work_outline,
                      items: const [
                        DropdownMenuItem(value: 'developer', child: Text('Developer')),
                        DropdownMenuItem(value: 'designer', child: Text('Designer')),
                        DropdownMenuItem(value: 'manager', child: Text('Manager')),
                        DropdownMenuItem(value: 'other', child: Text('Other')),
                      ],
                      validator: (value) => value == null ? 'Please select a role' : null,
                      onChanged: (value) => setState(() => _selectedRole = value),
                    ),
                    const SizedBox(height: 20),

                    // Experience Level Radio Group
                    SmartRadioGroup<String>(
                      label: 'Experience Level',
                      activeColor: Colors.green,
                      initialValue: _experienceLevel,
                      options: const [
                        SmartRadioOption(
                          value: 'entry', 
                          label: 'Entry Level', 
                          description: '0-2 years',
                          icon: Icons.school_outlined,
                        ),
                        SmartRadioOption(
                          value: 'mid', 
                          label: 'Mid Level', 
                          description: '2-5 years',
                          icon: Icons.trending_up,
                        ),
                        SmartRadioOption(
                          value: 'senior', 
                          label: 'Senior', 
                          description: '5+ years',
                          icon: Icons.star_outline,
                        ),
                      ],
                      onChanged: (value) => setState(() => _experienceLevel = value),
                      validator: (value) => value == null ? 'Please select experience level' : null,
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
