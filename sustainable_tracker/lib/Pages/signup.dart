import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool isLogin = true; // true = Sign In, false = Sign Up
  bool _obscurePassword = true;

  // VALIDATORS
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
    if (!emailRegex.hasMatch(v.trim())) return 'Enter valid email';
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Please enter password';
    if (v.length < 6) return 'Minimum 6 characters';
    return null;
  }

  // SUBMIT FUNCTION
  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (isLogin) {
      debugPrint("SIGN IN -> Email: $email Password: $password");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Signed In (demo)")));
    } else {
      debugPrint("SIGN UP -> Name: $name Email: $email Password: $password");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Account Created (demo)")));
    }
  }

  // Toggle Sign In / Sign Up
  void _toggleMode() {
    setState(() {
      isLogin = !isLogin;
      if (isLogin) _nameController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final titleText = isLogin ? "Sign In" : "Create Account";
    final buttonText = isLogin ? "Sign In" : "Sign Up";
    final switchText = isLogin
        ? "Don't have an account? Sign Up"
        : "Already have an account? Sign In";

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // LOGO
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Icon(
                    FontAwesomeIcons.leaf,
                    size: 30,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // TITLE TEXT
              Column(
                children: [
                  Text(
                    "Sustainable Shopping",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.green.withOpacity(0.9),
                    ),
                  ),
                  const Text(
                    'Track your carbon footprint',
                    style: TextStyle(color: Colors.black87),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // FORM
              Padding(
                padding: const EdgeInsets.all(25.0),
                child: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Text(
                            titleText,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // NAME FIELD (only for Sign Up)
                          AnimatedSize(
                            duration: const Duration(milliseconds: 200),
                            child: isLogin
                                ? const SizedBox.shrink()
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text("Name"),
                                      const SizedBox(height: 5),
                                      TextFormField(
                                        controller: _nameController,
                                        validator: _validateName,
                                        decoration: _inputBox(
                                          "Enter your name",
                                        ),
                                      ),
                                      const SizedBox(height: 15),
                                    ],
                                  ),
                          ),

                          // EMAIL FIELD
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text("Email"),
                          ),
                          const SizedBox(height: 5),
                          TextFormField(
                            controller: _emailController,
                            validator: _validateEmail,
                            decoration: _inputBox("Enter your email"),
                          ),
                          const SizedBox(height: 15),

                          // PASSWORD FIELD
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text("Password"),
                          ),
                          const SizedBox(height: 5),
                          TextFormField(
                            controller: _passwordController,
                            validator: _validatePassword,
                            obscureText: _obscurePassword,
                            decoration: _inputBox("Enter your password")
                                .copyWith(
                                  suffixIcon: IconButton(
                                    onPressed: () => setState(
                                      () =>
                                          _obscurePassword = !_obscurePassword,
                                    ),
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                  ),
                                ),
                          ),

                          const SizedBox(height: 20),

                          // BUTTON
                          SizedBox(
                            width: 180,
                            child: ElevatedButton(
                              onPressed: _handleSubmit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                              child: Text(
                                buttonText,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),

                          // SWITCH SIGN IN / SIGN UP
                          TextButton(
                            onPressed: _toggleMode,
                            child: Text(
                              switchText,
                              style: const TextStyle(
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Input decoration shortcut
  InputDecoration _inputBox(String hint) {
    return InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      hintText: hint,
    );
  }
}
