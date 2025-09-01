import 'package:flutter/material.dart';
import 'package:secure_notes/screens/notes_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final LocalAuthentication auth = LocalAuthentication();

  bool _isLoggedInBefore = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final loggedIn = prefs.getBool('loggedIn') ?? false;
    setState(() {
      _isLoggedInBefore = loggedIn;
    });
    if (loggedIn) {

    }
  }

  Future<void> _login() async {
    if (_usernameController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('loggedIn', true);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const NotesScreen()),
      );
    }
  }

  Future<void> _loginWithBiometrics() async {
    try {
      final isAvailable = await auth.canCheckBiometrics;
      if (isAvailable) {
        final didAuthenticate = await auth.authenticate(
          localizedReason: 'Authenticate for logging in!',
          options: const AuthenticationOptions(biometricOnly: true),
        );

        if (didAuthenticate) {
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const NotesScreen()),
          );
        }
      } else {
        debugPrint('Biometric authentication is not available on this device.');
      }
    } catch (e) {
      debugPrint('Biometric error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login'),),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: const Text('Login'),
            ),
            if (_isLoggedInBefore) ...[
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _loginWithBiometrics,
                icon: const Icon(Icons.fingerprint),
                label: const Text('Login with Fingerprint'),
              )
            ]
          ],
        ),
      ),
    );
  }
}