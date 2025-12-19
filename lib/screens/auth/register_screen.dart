import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/analytics_service.dart';
import '../../services/crashlytics_service.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/google_button.dart';
import './login_screen.dart';
import './select_password_screen.dart';
import '../home/home_screen.dart';
import '../../core/utils/validators.dart';
import '../../core/constants/app_strings.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AnalyticsService.logScreenView('register_screen');
    });
  }

  void _continueToPassword() {
    if (_formKey.currentState!.validate()) {
      AnalyticsService.logButtonTap('continue_to_password');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PasswordScreen(
            email: _emailController.text.trim(),
          ),
        ),
      );
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      AnalyticsService.logButtonTap('google_signup');
      
      final result = await _authService.signInWithGoogle();
      
      if (result['success'] == true) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
          (route) => false,
        );
      } else {
        final error = result['error'] as String?;
        
        if (error?.contains('user-not-found') == true || 
            error?.contains('No account found') == true) {

          _showAccountNotExistsMessage();
        } else {
          setState(() {
            _errorMessage = error ?? 'Google sign in failed';
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred';
      });
      await CrashlyticsService.recordError(e, StackTrace.current, reason: 'Google signup error');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showAccountNotExistsMessage() {
    setState(() {
      _errorMessage = 'No account found with this Google account. Please register with email first.';
    });
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
              'assets/images/grad2.png',
              fit: BoxFit.cover
            ),
          ),
          
          // Loading Overlay
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(AppStrings.alreadyHaveAccount,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),),
                      TextButton(
                        onPressed: _isLoading ? null : () {
                          AnalyticsService.logButtonTap('login_from_register');
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => LoginScreen()),
                          );
                        },
                        child: Text(
                          AppStrings.logIn,
                          style: TextStyle(
                            color: const Color.fromARGB(255, 255, 255, 255),
                            fontSize: 18,
                            decoration: TextDecoration.underline,
                            decorationColor: const Color.fromARGB(255, 255, 255, 255),
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 16),
                  
                  Text(
                    AppStrings.createAccount,
                    style: TextStyle(
                      fontSize: 34,
                      color: const Color.fromARGB(255, 255, 255, 255),
                      fontWeight: FontWeight.w600
                    ),
                  ),
                  SizedBox(height: 32),

                  // Error Message
                  if (_errorMessage.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12),
                      margin: EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close, color: Colors.white, size: 16),
                            onPressed: () {
                              setState(() {
                                _errorMessage = '';
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                  // Google Button
                  GoogleButton(
                    onPressed: _signInWithGoogle,
                  ),
                  SizedBox(height: 24),

                  // Divider
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.white)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          AppStrings.or,
                          style: TextStyle(
                            color: Color.fromARGB(255, 255, 255, 255), 
                            fontSize: 20
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.white)),
                    ],
                  ),
                  SizedBox(height: 24),

                  // Email Field
                  CustomTextField(
                    hintText: AppStrings.emailHint,
                    controller: _emailController,
                    validator: Validators.validateEmail,
                  ),

                  Spacer(flex: 2),

                  // Continue Button
                  CustomButton(
                    text: _isLoading ? 'Please wait...' : AppStrings.continueText,
                    onPressed: _continueToPassword,
                    backgroundColor: const Color(0xFF1E1E1E),
                  ),
                  SizedBox(height: 10),

                  // Terms
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 16,
                        color: const Color.fromARGB(255, 255, 255, 255),
                      ),
                      children: [
                        TextSpan(text: 'By continuing you agree to our '),
                        TextSpan(
                          text: 'Terms & Conditions',
                          style: TextStyle(
                            fontSize: 16,
                            decoration: TextDecoration.underline,
                            decorationColor: const Color.fromARGB(255, 255, 255, 255),
                            decorationThickness: 2.0,
                          ),
                        ),
                        TextSpan(text: ' and '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: TextStyle(
                            fontSize: 16,
                            decoration: TextDecoration.underline,
                            decorationColor: const Color.fromARGB(255, 255, 255, 255),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 10)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}