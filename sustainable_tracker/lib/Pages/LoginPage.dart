import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class loginPage extends StatefulWidget {
  const loginPage({super.key});

  @override
  State<loginPage> createState() => _loginPageState();
}

class _loginPageState extends State<loginPage> {
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
            Container(
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {},

                      child: Text('Login'),

                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(150, 40),
                        foregroundColor: Colors.black,

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8), // No radius
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {},
                      child: Text('Login'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(150, 40),
                        foregroundColor: Colors.black,

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8), // No radius
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
