// login_page.dart
import 'dart:convert'; // For jsonEncode / jsonDecode
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sustainable_tracker/Views/Pages/Home.dart';
import 'package:sustainable_tracker/Views/widgets/widget_tree.dart';

class login_Page extends StatefulWidget {
  const login_Page({super.key});

  @override
  State<login_Page> createState() => _loginPageState();
}

class _loginPageState extends State<login_Page> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final String _baseUrl = 'http://192.168.1.4:8000/api/auth';

  bool isLogin = false;
  bool _loading = false;

  String? _validateName(String? v) {
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

  Future<void> _saveToken(String token) async {
    await _secureStorage.write(key: 'jwt', value: token);
  }

  Future<String?> _readToken() async {
    return await _secureStorage.read(key: 'jwt');
  }

  Map<String, dynamic> _parseResponse(String body) {
    try {
      final parsed = jsonDecode(body);
      if (parsed is Map<String, dynamic>) return parsed;
      return {'raw': body};
    } catch (_) {
      return {'raw': body};
    }
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() => _loading = true);

    try {
      if (isLogin) {
        final resp = await _loginRequest(email, password);
        final status = resp['status'] as int;
        final body = _parseResponse(resp['body'] as String);

        if (status == 200) {
          final token = body['token'] ?? body['accessToken'];
          if (token != null) {
            await _saveToken(token);
            if (!mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const widgetTree()),
            );
          } else {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Logged in (no token returned)")),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const widgetTree()),
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
        final resp = await _signupRequest(name, email, password);
        final status = resp['status'] as int;
        final body = _parseResponse(resp['body'] as String);

        if (status == 201 || status == 200) {
          final token = body['token'] ?? body['accessToken'];
          if (token != null) {
            await _saveToken(token);
            if (!mounted) return;
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text("Signed up")));
            setState(() {
              isLogin = true;
            });
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
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Network error: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _buildActionButton() {
    return SizedBox(
      width: 180,
      height: 45,
      child: ElevatedButton(
        onPressed: _loading ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 6,
          shadowColor: Colors.black26,
        ),

        child: _loading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : (isLogin
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        SizedBox(width: 8),
                        Text(
                          "Login",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.person_add, size: 18, color: Colors.black),
                        SizedBox(width: 8),
                        Text(
                          "Sign Up",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    )),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ---------- NEW: cleaned build that preserves original visuals ----------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(
            context,
          ).unfocus(), // dismiss keyboard on outside tap
          behavior: HitTestBehavior.opaque,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 35),
                          Container(
                            margin: const EdgeInsets.only(top: 6, bottom: 6),
                            width: double.infinity,
                            alignment: Alignment.topCenter,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Center(
                                child: Icon(
                                  FontAwesomeIcons.leaf,
                                  color: Colors.white,
                                  size: 46,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),
                          // Title (centered)
                          Column(
                            children: [
                              Text(
                                "Sustainable Shoping",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.green.withOpacity(0.9),
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Track your carbon footprint',
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),

                          if (isLogin) ...{
                            SizedBox(height: 100),
                          } else ...{
                            SizedBox(height: 40),
                          },

                          // Form fields with the original big padding
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6.0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AnimatedSize(
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeInOut,
                                  child: isLogin
                                      ? const SizedBox.shrink()
                                      : Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
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
                                                hintStyle: TextStyle(
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 14),
                                          ],
                                        ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(left: 5),
                                  child: Text(
                                    "Email",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _emailController,
                                  validator: _validateEmail,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    hintText: "Enter your Email",
                                    hintStyle: TextStyle(fontSize: 13),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                const Padding(
                                  padding: EdgeInsets.only(left: 5),
                                  child: Text(
                                    "Password",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _passwordController,
                                  validator: _validatePassword,
                                  obscureText: true,
                                  textInputAction: TextInputAction.done,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    hintText: "Enter your Passsword",
                                    hintStyle: TextStyle(fontSize: 13),
                                  ),
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                          if (isLogin) ...{
                            SizedBox(height: 40),
                          } else ...{
                            SizedBox(height: 40),
                          },
                          // Bottom action area - keep centered and spaced like original
                          Column(
                            children: [
                              _buildActionButton(),
                              const SizedBox(height: 18),
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
                                  style: const TextStyle(
                                    color: Color(0xFF6B4CA3),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
