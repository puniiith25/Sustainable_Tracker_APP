// Home.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Adjust this import path to where your login page file is.
import 'package:sustainable_tracker/Pages/signup.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Change this to your backend base url (same as login_page.dart)
  final String _baseUrl = 'http://localhost:8000/api/auth';

  String? _name; // the user's name fetched from backend
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUser(); // fetch user on open
  }

  // Read token then call backend to get user info
  Future<void> _loadUser() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final token = await _secureStorage.read(key: 'jwt');

      // If there's no token, go back to login
      if (token == null) {
        _redirectToLogin();
        return;
      }

      // Call your protected endpoint to get user profile.
      // I use '/me' here — change if your backend uses a different route.
      final resp = await http.get(
        Uri.parse('$_baseUrl/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (resp.statusCode == 200) {
        final parsed = jsonDecode(resp.body);
        // Expecting something like: { "user": { "name": "Punitha", ... } }
        final user = parsed is Map && parsed['user'] is Map
            ? parsed['user']
            : parsed;
        setState(() {
          _name = (user is Map && user['name'] != null)
              ? user['name'].toString()
              : 'User';
          _loading = false;
        });
      } else if (resp.statusCode == 401) {
        // token invalid/expired -> redirect to login
        await _secureStorage.delete(key: 'jwt');
        _redirectToLogin();
      } else {
        setState(() {
          _error = 'Failed to load profile (${resp.statusCode})';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Network error: $e';
        _loading = false;
      });
    }
  }

  // Clear token and go to login screen
  Future<void> _logout() async {
    await _secureStorage.delete(key: 'jwt');

    // Optionally call backend logout endpoint to clear cookie on server:
    // await http.post(Uri.parse('$_baseUrl/logout'));

    _redirectToLogin();
  }

  void _redirectToLogin() {
    // Replace with your actual login page route/file import if different
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const loginPage2()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: Colors.green,
        actions: [
          // Logout button in appbar
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : _error != null
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _loadUser,
                    child: const Text('Retry'),
                  ),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Hello, ${_name ?? 'User'}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _logout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('Logout'),
                  ),
                ],
              ),
      ),
    );
  }
}
