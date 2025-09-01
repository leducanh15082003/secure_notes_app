import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notes_screen.dart';
import 'login_screen.dart';

class FingerprintScreen extends StatefulWidget {
  const FingerprintScreen({super.key});

  @override
  State<FingerprintScreen> createState() => _FingerprintScreenState();
}

class _FingerprintScreenState extends State<FingerprintScreen> {

  final LocalAuthentication auth = LocalAuthentication();
  String _message = 'Please authenticate by fingerprint!';

  @override
  void initState() {
    super.initState();
    _authenticate();
  }

  Future<void> _authenticate() async {
    try {
      bool canCheck = await auth.canCheckBiometrics;
      if (!canCheck) {
        setState(() {
          _message = 'Your device is not supported!';
        });
        return;
      }
      bool authenticated = await auth.authenticate(
        localizedReason: 'Authenticate to get access',
        options: AuthenticationOptions(biometricOnly: true)
      );

      if (authenticated) {
        if (!mounted) return;
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const NotesScreen()));
      } else {
        setState(() {
          _message = 'Authenticate failed! Please try again';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Error $e';
      });
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fingerprint authentication!'),
        actions: [
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout))
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_message, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _authenticate,
              child: const Text('Try again!'),
            )
          ],
        ),
      ),
    );
  }
}