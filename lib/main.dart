import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';
import 'screens/fingerprint_screen.dart';
import 'screens/notes_screen.dart';

void main() {
  runApp(SecureNotesApp());
}

class SecureNotesApp extends StatelessWidget {
  const SecureNotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Secure Notes',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: EntryPoint(),
    );
  }
}

class EntryPoint extends StatefulWidget {
  const EntryPoint({super.key});

  @override
  State<EntryPoint> createState() => _EntryPointState();
}

class _EntryPointState extends State<EntryPoint> {
  String? _token;
  bool _fingerprintEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('token');
      _fingerprintEnabled = prefs.getBool('fingerprint') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_token == null) {
      return LoginScreen();
    } else if (_fingerprintEnabled) {
      return FingerprintScreen();
    } else {
      return NotesScreen();
    }
  }
}