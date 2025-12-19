// app_strings.dart
abstract class AppStrings {
  // Common strings
  static const String appTitle = 'Health App';
  static const String welcomeBack = 'Welcome back!';
  static const String enterLoginInfo = 'Please enter your login info';
  static const String emailHint = 'youremail@example.com';
  static const String passwordHint = 'Password';
  static const String choosePasswordHint = 'Choose a password';
  static const String forgotPassword = 'Forgot your password?';
  static const String or = 'or';
  static const String confirm = 'Confirm';
  static const String continueText = 'Continue';
  static const String signUp = 'Sign up';
  static const String logIn = 'Log In';
  static const String helloThere = 'Hello there!';
  static const String welcomeMessage = 'First time here? Start your journey by signing up!';
  static const String alreadyHaveAccount = 'Already have an account?';
  static const String createAccount = 'Create an account to save your data and preferences, even if you change devices.';
  static const String selectStrongPassword = 'Select a strong password';
  static const String passwordRequirements = 'At least 8 characters, 1 number, 1 upper case letter and 1 lower case letter';
  static const String termsAndConditions = 'By continuing you agree to our Terms & Conditions and Privacy Policy';

  // Validation messages
  static const String emailRequired = 'Email is required';
  static const String invalidEmail = 'Please enter a valid email address';
  static const String passwordRequired = 'Password is required';
  static const String weakPassword = 'Password is too weak';
  static const String passwordTooShort = 'Password must be at least 8 characters long';
  static const String passwordNoNumber = 'Password must contain at least one number';
  static const String passwordNoUpperCase = 'Password must contain at least one uppercase letter';
  static const String passwordNoLowerCase = 'Password must contain at least one lowercase letter';

  const AppStrings._();
}