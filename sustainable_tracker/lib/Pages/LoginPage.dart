import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sustainable_tracker/Pages/Home.dart';

class loginPage extends StatefulWidget {
  const loginPage({super.key});

  @override
  State<loginPage> createState() => _loginPageState();
}

class _loginPageState extends State<loginPage> {
  // Form Key
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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

  void _handleSubmit() {
    // Validate all fields first
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (isLogin) {
      if (password == '12345678' && email == "punith@gmail.com") {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Logged in (demo)")));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Home()),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Check the credentials")));
      }
    } else {
      // SIGNUP LOGIC HERE
      debugPrint("SIGNUP -> Name: $name Email: $email Password: $password");

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Signed up (demo)")));
    }
  }

  bool isLogin = true;

  @override
  void dispose() {
    // Dispose controllers to free memory
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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
              SizedBox(height: 20),
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
                    Text(
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
                                  Padding(
                                    padding: const EdgeInsets.only(left: 5),
                                    child: Text(
                                      "Name",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  TextFormField(
                                    controller: _nameController,
                                    validator: _validateName,

                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      hintText: "Enter your Name",
                                      hintStyle: TextStyle(fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                      ),

                      SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: Text(
                          "Email",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      TextFormField(
                        controller: _emailController,
                        validator: _validateEmail,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Enter your Email",
                          hintStyle: TextStyle(fontSize: 13),
                        ),
                      ),
                      SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: Text(
                          "Password",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      TextFormField(
                        controller: _passwordController,
                        validator: _validatePassword,
                        decoration: InputDecoration(
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
                                  child: Text(
                                    "Forget Password?",
                                    textAlign: TextAlign.end,
                                    style: TextStyle(
                                      color: const Color.fromARGB(
                                        255,
                                        49,
                                        52,
                                        206,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(
                width: 180,
                child: ElevatedButton(
                  onPressed: _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: Colors.green,
                  ),

                  child: isLogin
                      ? Text(
                          "Login",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                            fontSize: 14,
                          ),
                        )
                      : Text(
                          "Sign Up",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                            fontSize: 14,
                          ),
                        ),
                ),
              ),

              TextButton(
                onPressed: () {
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
