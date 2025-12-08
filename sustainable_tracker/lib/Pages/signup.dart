// login_page.dart
import 'dart:convert'; // For jsonEncode / jsonDecode
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sustainable_tracker/Pages/Home.dart';

// NEW: HTTP package to send requests
import 'package:http/http.dart' as http;

// NEW: Secure storage to safely store JWT on device (recommended for mobile)
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class loginPage2 extends StatefulWidget {
  const loginPage2({super.key});

  @override
  State<loginPage2> createState() => _loginPageState();
}

class _loginPageState extends State<loginPage2> {
  // Form Key and controllers (same as your original)
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // NEW: secure storage instance to save JWT securely on device
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // NEW: Base URL for your backend. <-- CHANGE THIS to your real backend URL
  final String _baseUrl = 'http://localhost:8000/api/auth';

  // Keep existing state variable used to toggle login/signup UI
  bool isLogin = true;

  // NEW: loading state to disable button while request is in progress
  bool _loading = false;

  // -------------------------
  // Validation functions (unchanged)
  // -------------------------
  String? _validateName(String? v) {
    // Only validate name in SIGN-UP mode
    if (!isLogin) {
      if (v == null || v.trim().isEmpty) return 'Please enter name';
      if (v.trim().length < 2) return 'Name too short';
    }
    return null;
  }

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Please enter email';
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(v.trim())) return 'Enter a valid email';
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Please enter password';
    if (v.length < 6) return 'Password should be at least 6 chars';
    return null;
  }

  // -------------------------
  // NEW: Networking helpers
  // These are minimal helpers to call your backend login/signup endpoints,
  // parse responses and store/read tokens.
  // -------------------------

  // Minimal POST for login: returns map { 'status': int, 'body': String }
  Future<Map<String, dynamic>> _loginRequest(
    String email,
    String password,
  ) async {
    final resp = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return {'status': resp.statusCode, 'body': resp.body};
  }

  // Minimal POST for signup: returns map { 'status': int, 'body': String }
  Future<Map<String, dynamic>> _signupRequest(
    String name,
    String email,
    String password,
  ) async {
    final resp = await http.post(
      Uri.parse('$_baseUrl/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
    return {'status': resp.statusCode, 'body': resp.body};
  }

  // Save token securely
  Future<void> _saveToken(String token) async {
    await _secureStorage.write(key: 'jwt', value: token);
  }

  // Read token when needed
  Future<String?> _readToken() async {
    return await _secureStorage.read(key: 'jwt');
  }

  // Minimal helper to request protected resource using saved token.
  // Example usage: await _getProtectedResource('/profile');
  Future<Map<String, dynamic>> _getProtectedResource(String path) async {
    final token = await _readToken();
    final resp = await http.get(
      Uri.parse('$_baseUrl$path'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    return {'status': resp.statusCode, 'body': resp.body};
  }

  // Parse body safely into Map if possible, else return raw string under 'raw'
  Map<String, dynamic> _parseResponse(String body) {
    try {
      final parsed = jsonDecode(body);
      if (parsed is Map<String, dynamic>) return parsed;
      return {'raw': body};
    } catch (_) {
      return {'raw': body};
    }
  }

  // -------------------------
  // Existing _handleSubmit with minimal changes:
  // - Calls backend via helpers
  // - Stores token if returned
  // - Shows snackbars for errors / success
  // Note: I preserved your UI flow and only replaced the demo logic.
  // -------------------------
  void _handleSubmit() async {
    // Validate all fields first
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // Start loading state (optional, but recommended)
    setState(() {
      _loading = true;
    });

    try {
      if (isLogin) {
        // -------------------
        // LOGIN FLOW -> call backend
        // -------------------
        final resp = await _loginRequest(email, password);
        final status = resp['status'] as int;
        final bodyStr = resp['body'] as String;
        final body = _parseResponse(bodyStr);

        if (status == 200) {
          // Expecting backend to return token in JSON: { "token": "..." }
          final token = body['token'] ?? body['accessToken'];
          if (token != null) {
            await _saveToken(token);
            if (!mounted) return;
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text("Logged in")));
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Home()),
            );
          } else {
            // If backend uses cookies instead of returning token, mobile can't rely on cookies.
            // But still let user proceed (optional) or show helpful message.
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Logged in (no token returned)")),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Home()),
            );
          }
        } else {
          final msg =
              body['message'] ?? body['error'] ?? body['raw'] ?? 'Login failed';
          if (!mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(msg.toString())));
        }
      } else {
        // -------------------
        // SIGNUP FLOW -> call backend
        // -------------------
        final resp = await _signupRequest(name, email, password);
        final status = resp['status'] as int;
        final bodyStr = resp['body'] as String;
        final body = _parseResponse(bodyStr);

        if (status == 201 || status == 200) {
          final token = body['token'] ?? body['accessToken'];
          if (token != null) {
            await _saveToken(token);
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Signed up & logged in")),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Home()),
            );
          } else {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Signed up (no token returned)")),
            );
          }
        } else {
          final msg =
              body['message'] ??
              body['error'] ??
              body['raw'] ??
              'Signup failed';
          if (!mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(msg.toString())));
        }
      }
    } catch (e) {
      // Network or unexpected error
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Network error: $e')));
    } finally {
      // Stop loading state
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    // Dispose controllers to free memory
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Helper to build the action button (keeps UI tidy)
  Widget _buildActionButton() {
    return SizedBox(
      width: 180,
      child: ElevatedButton(
        onPressed: _loading ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: Colors.green,
        ),
        child: _loading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(
                isLogin ? "Login" : "Sign Up",
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontSize: 14,
                ),
              ),
      ),
    );
  }

  // -------------------------
  // Build UI (kept your original structure)
  // -------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(
                    FontAwesomeIcons.leaf,
                    size: 30,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                child: Column(
                  children: [
                    Text(
                      "Sustainable Shoping",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.green.withOpacity(0.9),
                      ),
                    ),
                    const Text(
                      'Track your carbon footprint',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(25.0),
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedSize(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        child: isLogin
                            ? const SizedBox.shrink()
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 8),
                                  const Padding(
                                    padding: EdgeInsets.only(left: 5),
                                    child: Text(
                                      "Name",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: _nameController,
                                    validator: _validateName,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      hintText: "Enter your Name",
                                      hintStyle: TextStyle(fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                      const SizedBox(height: 10),
                      const Padding(
                        padding: EdgeInsets.only(left: 5),
                        child: Text(
                          "Email",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _emailController,
                        validator: _validateEmail,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Enter your Email",
                          hintStyle: TextStyle(fontSize: 13),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Padding(
                        padding: EdgeInsets.only(left: 5),
                        child: Text(
                          "Password",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _passwordController,
                        validator: _validatePassword,
                        obscureText: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Enter your Passsword",
                          hintStyle: TextStyle(fontSize: 13),
                        ),
                      ),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeIn,
                        child: !isLogin
                            ? const SizedBox.shrink()
                            : Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {},
                                  child: const Text(
                                    "Forget Password?",
                                    textAlign: TextAlign.end,
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 49, 52, 206),
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              _buildActionButton(),
              TextButton(
                onPressed: _loading
                    ? null
                    : () {
                        setState(() {
                          isLogin = !isLogin;
                        });
                      },
                child: Text(
                  isLogin
                      ? "Don't have an account? Sign Up"
                      : "Already have an account? Login",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
