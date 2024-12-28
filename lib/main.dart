import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hyper/pages/alarm_clock.dart';
import 'package:hyper/pages/dashboard.dart';
import 'package:hyper/pages/splash_screen.dart';
import 'package:hyper/user_auth/firebase_auth_implementation/firebase_auth_services.dart';
import 'pages/sign_in.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyDDgSrKn0KM7zj68SlFelTJ9C8dHkLb3ck",
            authDomain: "hyper-68b2a.firebaseapp.com",
            projectId: "hyper-68b2a",
            storageBucket: "hyper-68b2a.firebasestorage.app",
            messagingSenderId: "512686810338",
            appId: "1:512686810338:web:3e5062836cd20e6993eabb"));
  } else {
    await Firebase.initializeApp();
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => SplashScreen(
              child: SignInPage(),
            ),
        '/login': (context) => SignInPage(),
        '/signUp': (context) => SignUpPage(),
        '/dashboard': (context) => DashboardPage(),
        '/alarm': (context) => const AlarmClock()
      },
    );
  }
}

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final FirebaseAuthService _auth = FirebaseAuthService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                  // Centering the logo
                  child: Text(
                'Sign Up for ',
                style: GoogleFonts.poppins(
                  // Custom Google Font, you can use any font
                  textStyle: TextStyle(
                    color: Colors.blue, // Blue color for the text
                    fontSize: 16, // Large font size for a logo look
                    fontWeight: FontWeight.normal, // Bold for emphasis
                    letterSpacing: 2.0, // Slight spacing for a logo feel
                  ),
                ),
              )),
              Center(
                  // Centering the logo
                  child: Text(
                'HYPER',
                style: GoogleFonts.poppins(
                  // Custom Google Font, you can use any font
                  textStyle: TextStyle(
                    color: Colors.blue, // Blue color for the text
                    fontSize: 24, // Large font size for a logo look
                    fontWeight: FontWeight.w600, // Bold for emphasis
                    letterSpacing: 2.0, // Slight spacing for a logo feel
                  ),
                ),
              )),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Username'),
                validator: (value) {
                  if (value == null || value.isEmpty || value.length < 2) {
                    return 'username must be at least 2 characters';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty || !value.contains('@')) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value != _passwordController.text) {
                    return 'password is too short';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: _signUp,
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16, // Adjust font size as needed
                        fontWeight: FontWeight
                            .bold, // You can change the weight if needed
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => SignInPage()),
                  )
                },
                child: Text('Already have an account? Sign In'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _signUp() async {
    String username = _usernameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;

    User? user = await _auth.signUpWithEmailAndPassword(email, password);

    if (user != null) {
      print("User created");

      Navigator.pushNamed(context, "/login");

      {
        if (_formKey.currentState?.validate() ?? false) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Signing Up')));
          // Implement sign-up logic here
        }
      }
    } else {
      print("Some error occured");
    }
  }
}
