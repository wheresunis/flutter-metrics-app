import 'package:flutter/material.dart';
import './login_screen.dart';
import './register_screen.dart';
import '../../core/widgets/custom_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Image.asset(
              'assets/images/grad1.png',
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(25, 200, 25, 100),
            child: Column(
              children: [
                SizedBox(
                  width: 90,
                  height: 90,
                  child: Center(
                    child: Image.asset(
                      'assets/images/app_icon.png',
                      width: 90,
                      height: 90,
                    ),
                  ),
                ),
                SizedBox(height: 32),
                Text(
                  'Hello there!',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 5),
                SizedBox(
                  width: 250,
                  height: 100,
                  child:
                  Text(
                    'First time here? Start your journey by signing up!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      height: 1.5,
                    ),
                  ),
                ),
                Spacer(flex: 1),
                CustomButton(
                  text: 'Sign up',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegisterScreen()),
                    );
                  },
                  backgroundColor: const Color(0xFF1E1E1E),
                  textColor: const Color(0xFFFFFFFF),
                ),
                SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                        );
                      },
                      child: Text(
                        'Log In',
                        style: TextStyle(
                          color: const Color.fromARGB(255, 255, 255, 255),
                          fontSize: 20,
                          decoration: TextDecoration.underline,
                          decorationColor: const Color.fromARGB(255, 255, 255, 255)
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}