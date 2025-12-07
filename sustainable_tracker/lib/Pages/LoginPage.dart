import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sustainable_tracker/Pages/Home.dart';

class loginPage extends StatefulWidget {
  const loginPage({super.key});

  @override
  State<loginPage> createState() => _loginPageState();
}

class _loginPageState extends State<loginPage> {
  bool isLogin = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
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
                                TextField(
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
                    TextField(
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
                    TextField(
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
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Home()),
                  );
                },
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
    );
  }
}
