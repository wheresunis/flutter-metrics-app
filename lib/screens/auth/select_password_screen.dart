import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../../services/analytics_service.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../home/home_screen.dart';
import '../../core/utils/validators.dart';
import '../../core/constants/app_strings.dart';

class PasswordScreen extends StatefulWidget {
  final String email;

  const PasswordScreen({super.key, required this.email});

  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AnalyticsService.logScreenView('password_screen');
    });
  }

  Future<void> _createAccount() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      try {
        AnalyticsService.logButtonTap('create_account');
        
        final user = await _authService.signUpWithEmailAndPassword(
          widget.email,
          _passwordController.text,
        );
        
        if (user != null) {
          // Успішна реєстрація
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        setState(() {
          _errorMessage = _getErrorMessage(e);
        });
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'email-already-in-use':
          return 'This email is already registered. Please log in instead.';
        case 'weak-password':
          return 'Password is too weak. Please choose a stronger password.';
        case 'invalid-email':
          return 'Invalid email address. Please check your email.';
        case 'operation-not-allowed':
          return 'Email/password accounts are not enabled. Please contact support.';
        default:
          return 'Registration failed: ${error.message}';
      }
    }
    return 'An unexpected error occurred. Please try again.';
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Image.asset(
              'assets/images/grad3.png',
              fit: BoxFit.cover,
            ),
          ),
          
          // Back Button
          Positioned(
            top: 81,
            left: 52,
            child: Container(
              width: 49,
              height: 49,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.white,
                  width: 1,
                ),
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                iconSize: 25,
                padding: EdgeInsets.fromLTRB(11, 0, 0, 0),
                onPressed: _isLoading ? null : () => Navigator.pop(context),
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.all(55),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 100),
                  
                  // Title
                  Text(
                    AppStrings.selectStrongPassword,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 34,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 32),

                  // Error Message
                  if (_errorMessage.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _errorMessage,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  if (_errorMessage.isNotEmpty) SizedBox(height: 16),

                  // Email Field (disabled)
                  CustomTextField(
                    hintText: AppStrings.emailHint,
                    controller: TextEditingController(text: widget.email),
                    enabled: false,
                  ),
                  SizedBox(height: 16),

                  // Password Field
                  CustomTextField(
                    hintText: AppStrings.choosePasswordHint,
                    obscureText: true,
                    controller: _passwordController,
                    validator: Validators.validatePassword,
                  ),
                  SizedBox(height: 16),

                  // Confirm Password Field
                  CustomTextField(
                    hintText: 'Confirm password',
                    obscureText: true,
                    controller: _confirmPasswordController,
                    validator: _validateConfirmPassword,
                  ),
                  SizedBox(height: 10),

                  // Password Requirements
                  Text(
                    AppStrings.passwordRequirements,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  SizedBox(height: 24),

                  // Create Account Button
                  CustomButton(
                    text: _isLoading ? 'Creating Account...' : AppStrings.confirm,
                    onPressed:  _createAccount,
                    backgroundColor: const Color(0xFF1E1E1E),
                  ),

                  Spacer(flex: 2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}