import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'analytics_service.dart';
import 'crashlytics_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<User?> signUpWithEmailAndPassword(
    String email, 
    String password,
  ) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      // Analytics
      await AnalyticsService.logSignUp(method: 'email');
      await AnalyticsService.setUserProperties(result.user?.uid ?? 'unknown');
      
      // Crashlytics
      await CrashlyticsService.setUserIdentifier(result.user?.uid ?? 'unknown');
      await CrashlyticsService.logMessage('User signed up with email: $email');
      
      return result.user;
    } catch (e, stack) {
      await CrashlyticsService.recordError(e, stack, reason: 'Email signup error');
      rethrow;
    }
  }

  Future<User?> signInWithEmailAndPassword(
    String email, 
    String password,
  ) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password
      );
      
      // Analytics
      await AnalyticsService.logLogin(method: 'email');
      await AnalyticsService.setUserProperties(result.user?.uid ?? 'unknown');
      
      // Crashlytics
      await CrashlyticsService.setUserIdentifier(result.user?.uid ?? 'unknown');
      await CrashlyticsService.logMessage('User logged in with email: $email');
      
      return result.user;
    } catch (e, stack) {
      await CrashlyticsService.recordError(e, stack, reason: 'Email login error');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: [
          'email',
          'profile',
        ],
        signInOption: SignInOption.standard,
      );
    
      await googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn(); 
      if (googleUser == null) {
        return {'success': false, 'error': 'Sign in cancelled', 'user': null};
      }

      final GoogleSignInAuthentication googleAuth = 
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential result = await _auth.signInWithCredential(credential);
      
      if (result.user != null) {
        // Analytics
        await AnalyticsService.logLogin(method: 'google');
        await AnalyticsService.setUserProperties(result.user?.uid ?? 'unknown');
        
        // Crashlytics
        await CrashlyticsService.setUserIdentifier(result.user?.uid ?? 'unknown');
        await CrashlyticsService.logMessage('User logged in with Google: ${googleUser.email}');
        
        return {'success': true, 'error': null, 'user': result.user};
      } else {
        return {'success': false, 'error': 'Authentication failed', 'user': null};
      }
      
    } catch (e, stack) {
      String errorMessage = 'Google sign in failed';
      
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'account-exists-with-different-credential':
            errorMessage = 'An account already exists with the same email but different sign-in method.';
            break;
          case 'invalid-credential':
            errorMessage = 'The authentication credential is invalid.';
            break;
          case 'user-disabled':
            errorMessage = 'This user account has been disabled.';
            break;
          case 'user-not-found':
            errorMessage = 'No account found with this Google account. Please register first.';
            break;
          case 'wrong-password':
            errorMessage = 'Wrong password provided for that user.';
            break;
          case 'invalid-email':
            errorMessage = 'The email address is invalid.';
            break;
          case 'user-mismatch':
            errorMessage = 'The credential does not correspond to the current user.';
            break;
          case 'requires-recent-login':
            errorMessage = 'This operation requires recent authentication. Please log in again.';
            break;
          case 'operation-not-allowed':
            errorMessage = 'Google sign-in is not enabled. Please contact support.';
            break;
          case 'network-request-failed':
            errorMessage = 'Network error. Please check your internet connection.';
            break;
          case 'too-many-requests':
            errorMessage = 'Too many requests. Please try again later.';
            break;
          default:
            errorMessage = 'Authentication failed: ${e.message}';
        }
      }
      
      await CrashlyticsService.recordError(e, stack, reason: 'Google login error');
      return {'success': false, 'error': errorMessage, 'user': null};
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      
      await AnalyticsService.logEvent('logout', null);
      await CrashlyticsService.logMessage('User signed out');
    } catch (e, stack) {
      await CrashlyticsService.recordError(e, stack, reason: 'Logout error');
      rethrow;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      await AnalyticsService.logEvent('password_reset_requested', {'email': email});
      await CrashlyticsService.logMessage('Password reset requested for: $email');
    } catch (e, stack) {
      await CrashlyticsService.recordError(e, stack, reason: 'Password reset error');
      rethrow;
    }
  }

  bool get isLoggedIn => _auth.currentUser != null;
}