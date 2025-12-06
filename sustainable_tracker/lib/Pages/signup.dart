// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// class loginPage extends StatefulWidget {
//   const loginPage({super.key});

//   @override
//   State<loginPage> createState() => _loginPageState();
// }

// class _loginPageState extends State<loginPage> with TickerProviderStateMixin {
//   // Form key to validate all input fields
//   final _formKey = GlobalKey<FormState>();

//   // Controllers to read user input values
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();

//   // This variable controls whether we are in Login or Sign-up mode
//   bool isLogin = true;

//   // For showing or hiding password
//   bool _obscurePassword = true;

//   // -------------------- VALIDATION FUNCTIONS --------------------

//   String? _validateName(String? v) {
//     // Only validate name in SIGN-UP mode
//     if (!isLogin) {
//       if (v == null || v.trim().isEmpty) return 'Please enter name';
//       if (v.trim().length < 2) return 'Name too short';
//     }
//     return null;
//   }

//   String? _validateEmail(String? v) {
//     if (v == null || v.trim().isEmpty) return 'Please enter email';
//     final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
//     if (!emailRegex.hasMatch(v.trim())) return 'Enter a valid email';
//     return null;
//   }

//   String? _validatePassword(String? v) {
//     if (v == null || v.isEmpty) return 'Please enter password';
//     if (v.length < 6) return 'Password should be at least 6 chars';
//     return null;
//   }

//   // -------------------- SUBMIT HANDLER --------------------

//   void _handleSubmit() {
//     // Validate all fields first
//     if (!_formKey.currentState!.validate()) return;

//     final name = _nameController.text.trim();
//     final email = _emailController.text.trim();
//     final password = _passwordController.text;

//     if (isLogin) {
//       // LOGIN LOGIC HERE
//       debugPrint("LOGIN -> Email: $email Password: $password");

//       ScaffoldMessenger.of(context)
//           .showSnackBar(const SnackBar(content: Text("Logged in (demo)")));
//     } else {
//       // SIGNUP LOGIC HERE
//       debugPrint("SIGNUP -> Name: $name Email: $email Password: $password");

//       ScaffoldMessenger.of(context)
//           .showSnackBar(const SnackBar(content: Text("Signed up (demo)")));
//     }
//   }

//   // -------------------- TOGGLE LOGIN / SIGNUP --------------------

//   void _toggleMode() {
//     setState(() {
//       // Switch between Login & SignUp modes
//       isLogin = !isLogin;

//       // Clear name when switching back to login
//       if (isLogin) {
//         _nameController.clear();
//       }
//     });
//   }

//   @override
//   void dispose() {
//     // Dispose controllers to free memory
//     _nameController.dispose();
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   // -------------------- UI STARTS HERE --------------------

//   @override
//   Widget build(BuildContext context) {
//     // Text changes based on mode
//     final titleText = isLogin ? 'Login' : 'Create Account';
//     final buttonText = isLogin ? 'Login' : 'Sign Up';
//     final switchText =
//         isLogin ? "Don't have an account? Sign up" : "Already have an account? Login";

//     return Scaffold(
//       body: Center(
//         child: SingleChildScrollView(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               // -------------------- APP ICON --------------------
//               Container(
//                 width: 70,
//                 height: 70,
//                 decoration: BoxDecoration(
//                   color: Colors.green,
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: const Center(
//                   child: Icon(FontAwesomeIcons.leaf,
//                       size: 30, color: Colors.white),
//                 ),
//               ),

//               const SizedBox(height: 20),

//               // -------------------- TITLE TEXT --------------------
//               Column(
//                 children: [
//                   Text(
//                     "Sustainable Shoping",
//                     style: TextStyle(
//                       fontWeight: FontWeight.w500,
//                       color: Colors.green.withOpacity(0.9),
//                     ),
//                   ),
//                   const Text(
//                     'Track your carbon footprint',
//                     style: TextStyle(
//                       fontWeight: FontWeight.w400,
//                       color: Colors.black,
//                     ),
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 20),

//               // -------------------- FORM CARD --------------------
//               Padding(
//                 padding: const EdgeInsets.all(25.0),
//                 child: Card(
//                   elevation: 5,
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12)),
//                   child: Padding(
//                     padding: const EdgeInsets.all(20.0),

//                     // FORM STARTS HERE
//                     child: Form(
//                       key: _formKey,
//                       child: Column(
//                         children: [
//                           // FORM TITLE
//                           Text(
//                             titleText,
//                             style: const TextStyle(
//                                 fontSize: 18, fontWeight: FontWeight.w600),
//                           ),
//                           const SizedBox(height: 20),

//                           // -------------------- NAME FIELD (Sign-Up only) --------------------
//                           AnimatedSize(
//                             duration: const Duration(milliseconds: 200),
//                             curve: Curves.easeInOut,
//                             child: isLogin
//                                 ? const SizedBox.shrink() // Hide in login
//                                 : Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       const Text("Name",
//                                           style: TextStyle(
//                                               fontWeight: FontWeight.w400)),
//                                       const SizedBox(height: 5),
//                                       TextFormField(
//                                         controller: _nameController,
//                                         validator: _validateName,
//                                         decoration: InputDecoration(
//                                           border: OutlineInputBorder(
//                                             borderRadius:
//                                                 BorderRadius.circular(8),
//                                           ),
//                                           hintText: "Enter your Name",
//                                         ),
//                                       ),
//                                       const SizedBox(height: 15),
//                                     ],
//                                   ),
//                           ),

//                           // -------------------- EMAIL FIELD --------------------
//                           const Align(
//                             alignment: Alignment.centerLeft,
//                             child: Text("Email",
//                                 style: TextStyle(fontWeight: FontWeight.w400)),
//                           ),
//                           const SizedBox(height: 5),
//                           TextFormField(
//                             controller: _emailController,
//                             validator: _validateEmail,
//                             keyboardType: TextInputType.emailAddress,
//                             decoration: InputDecoration(
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               hintText: "Enter your Email",
//                             ),
//                           ),
//                           const SizedBox(height: 15),

//                           // -------------------- PASSWORD FIELD --------------------
//                           const Align(
//                             alignment: Alignment.centerLeft,
//                             child: Text("Password",
//                                 style: TextStyle(fontWeight: FontWeight.w400)),
//                           ),
//                           const SizedBox(height: 5),
//                           TextFormField(
//                             controller: _passwordController,
//                             validator: _validatePassword,
//                             obscureText: _obscurePassword,
//                             decoration: InputDecoration(
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               hintText: "Enter your Password",

//                               // Show / hide password icon
//                               suffixIcon: IconButton(
//                                 onPressed: () {
//                                   setState(() => _obscurePassword =
//                                       !_obscurePassword);
//                                 },
//                                 icon: Icon(_obscurePassword
//                                     ? Icons.visibility
//                                     : Icons.visibility_off),
//                               ),
//                             ),
//                           ),

//                           const SizedBox(height: 20),

//                           // -------------------- LOGIN / SIGNUP BUTTON --------------------
//                           SizedBox(
//                             width: 180,
//                             child: ElevatedButton(
//                               onPressed: _handleSubmit,
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.green,
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(8),
//                                 ),
//                               ),
//                               child: Text(
//                                 buttonText,
//                                 style: const TextStyle(
//                                   color: Colors.black,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                             ),
//                           ),

//                           const SizedBox(height: 10),

//                           // -------------------- SWITCH LOGIN <-> SIGNUP --------------------
//                           TextButton(
//                             onPressed: _toggleMode,
//                             child: Text(
//                               switchText,
//                               style: const TextStyle(
//                                   decoration: TextDecoration.underline),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
