import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/auth_service.dart';
import '../services/biometric_service.dart';
import 'notes_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _useBiometrics = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSavedLogin();
  }

  Future<void> _loadSavedLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUsername = prefs.getString('username');
    final biometricsEnabled = prefs.getBool('useBiometrics') ?? false;

    if (savedUsername != null && savedUsername.isNotEmpty) {
      _usernameController.text = savedUsername;
    }
    setState(() => _useBiometrics = biometricsEnabled);
  }

  Future<void> _login({bool useFingerprint = false}) async {
    setState(() => _isLoading = true);

    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    if (useFingerprint) {
      final success = await BiometricService.authenticate();
      if (!success) {
        setState(() => _isLoading = false);
        return;
      }
      final prefs = await SharedPreferences.getInstance();
      password = prefs.getString('password') ?? '';
    }

    final token = await AuthService.login(username, password);

    setState(() => _isLoading = false);

    if (token != null && token.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', username);

      if (!(prefs.getBool('askedBiometrics') ?? false)) {
        final enable = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Enable Fingerprint Login?'),
            content: const Text('Would you like to use fingerprint for future logins?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
              ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Yes')),
            ],
          ),
        );
        if (enable == true) {
          await prefs.setBool('useBiometrics', true);
          await prefs.setString('password', password);
        }
        await prefs.setBool('askedBiometrics', true);
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const NotesScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid username or password')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
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
            if (_useBiometrics)
              ElevatedButton.icon(
                onPressed: _isLoading ? null : () => _login(useFingerprint: true),
                icon: const Icon(Icons.fingerprint),
                label: const Text('Login with Fingerprint'),
              ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _isLoading ? null : () => _login(),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Login'),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                );
              },
              child: const Text('Create Account'),
            ),
          ],
        ),
      ),
    );
  }
}
