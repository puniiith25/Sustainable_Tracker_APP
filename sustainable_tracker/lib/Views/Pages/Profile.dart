// ProfilePage.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sustainable_tracker/Views/Welcome_Pages/Welcome_Page1.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String username = 'unknown';
  String useremail = 'unknown@gmai.com';

  bool loading = true;
  bool loggingOut = false;
  String? errorMsg;

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  final String _baseUrl = 'http://192.168.1.5:8000/api/auth';

  @override
  void initState() {
    super.initState();
    fetchCurrentUser();
  }

  Future<String?> _readToken() async {
    try {
      return await _secureStorage.read(key: 'jwt');
    } catch (_) {
      return null;
    }
  }

  Future<void> _removeToken() async {
    try {
      await _secureStorage.delete(key: 'jwt');
    } catch (_) {}
  }

  Map<String, dynamic> _safeDecode(String body) {
    try {
      final parsed = jsonDecode(body);
      if (parsed is Map<String, dynamic>) return parsed;
      return {'raw': parsed};
    } catch (_) {
      return {'raw': body};
    }
  }

  Future<void> fetchCurrentUser() async {
    setState(() {
      loading = true;
      errorMsg = null;
    });

    try {
      final token = await _readToken();

      final headers = <String, String>{
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

      final uri = Uri.parse('$_baseUrl/me');
      final resp = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 15));

      if (resp.statusCode == 200) {
        final data = _safeDecode(resp.body);

        String? name;
        String? email;

        if (data.containsKey('user') && data['user'] is Map) {
          name = (data['user']['name'] ?? data['user']['username'])?.toString();
          email = data['user']['email']?.toString();
        } else {
          name = (data['name'] ?? data['username'])?.toString();
          email = data['email']?.toString();
        }

        setState(() {
          username = name ?? username;
          useremail = email ?? useremail;
          loading = false;
        });
      } else if (resp.statusCode == 401 || resp.statusCode == 403) {
        await _removeToken();
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const Welcome_Page1()),
          (route) => false,
        );
      } else {
        final parsed = _safeDecode(resp.body);
        final message =
            parsed['message'] ??
            parsed['error'] ??
            parsed['raw'] ??
            'Failed to fetch profile';
        setState(() {
          errorMsg = 'Error ${resp.statusCode}: $message';
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMsg = 'Network error: $e';
        loading = false;
      });
    }
  }

  Future<void> handleLogout() async {
    setState(() {
      loggingOut = true;
    });

    try {
      final token = await _readToken();
      final headers = <String, String>{
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

      final uri = Uri.parse('$_baseUrl/logout');
      final resp = await http
          .post(uri, headers: headers)
          .timeout(const Duration(seconds: 10));

      await _removeToken();

      if (resp.statusCode == 200 || resp.statusCode == 204) {
      } else {}

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const Welcome_Page1()),
        (route) => false,
      );
    } catch (e) {
      await _removeToken();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout error: $e — clearing local session')),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const Welcome_Page1()),
        (route) => false,
      );
    } finally {
      if (mounted) {
        setState(() {
          loggingOut = false;
        });
      }
    }
  }

  Widget _buildMenuTile({
    required IconData leading,
    required String title,
    VoidCallback? onTap,
    Color? titleColor,
    Color? iconColor,
    Color? trailingColor,
  }) {
    return Column(
      children: [
        TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(padding: EdgeInsets.zero),
          child: ListTile(
            leading: Icon(leading, color: iconColor ?? Colors.grey),
            title: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
                color: titleColor ?? Colors.black,
              ),
            ),
            trailing: Icon(
              Icons.arrow_right,
              color: trailingColor ?? Colors.grey,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
            onTap: onTap,
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(left: 10.0),
          child: Divider(
            color: Color.fromARGB(255, 236, 235, 235),
            thickness: 1,
            endIndent: 30,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Align(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Text(
              'Profile',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.green,
                fontSize: 24,
              ),
            ),
          ),
        ),
        backgroundColor: Colors.white,
        toolbarHeight: 40,
        elevation: 0,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  if (errorMsg != null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        errorMsg!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Container(
                      width: double.infinity,
                      height: 180,
                      decoration: const BoxDecoration(color: Colors.white),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                children: [
                                  const CircleAvatar(
                                    radius: 35,
                                    child: Icon(
                                      Icons.person,
                                      size: 40,
                                      color: Colors.green,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(6.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          username,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(useremail),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 250,
                              height: 50,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 2,
                                  color: const Color.fromARGB(
                                    255,
                                    230,
                                    229,
                                    229,
                                  ),
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () {},
                                child: const Text(
                                  'Edit Profile',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Container(
                      width: double.infinity,
                      height: 250,
                      decoration: const BoxDecoration(color: Colors.white),
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 12.0),
                              child: Text(
                                'Statistics',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total Purchases',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(right: 25.0),
                                    child: Text('24'),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 15.0),
                              child: Divider(
                                color: Color.fromARGB(255, 236, 235, 235),
                                thickness: 1,
                                endIndent: 40,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Eco-Friendly Choices',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(right: 25.0),
                                    child: Text(
                                      '18(75%)',
                                      style: TextStyle(color: Colors.green),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 15.0),
                              child: Divider(
                                color: Color.fromARGB(255, 236, 235, 235),
                                thickness: 1,
                                endIndent: 40,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total Carbon Saved',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(right: 25.0),
                                    child: Text(
                                      '47.8 kg CO₂',
                                      style: TextStyle(color: Colors.green),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(color: Colors.white),
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 6.0),
                              child: Text(
                                'Menu Options',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            // Settings
                            _buildMenuTile(
                              leading: Icons.settings,
                              title: 'Settings',
                              onTap: () {},
                            ),
                            // Purchase History
                            _buildMenuTile(
                              leading: FontAwesomeIcons.bagShopping,
                              title: 'Purchase History',
                              onTap: () {},
                            ),
                            // Learn about sustainability
                            _buildMenuTile(
                              leading: Icons.book,
                              title: 'Learn about sustainability',
                              onTap: () {},
                            ),
                            // Help & Support
                            _buildMenuTile(
                              leading: Icons.question_answer_outlined,
                              title: 'Help & Support',
                              onTap: () {},
                            ),
                            // Notifications
                            _buildMenuTile(
                              leading: Icons.notifications,
                              title: 'Notifications',
                              onTap: () {},
                            ),
                            // Logout (active)
                            Column(
                              children: [
                                TextButton(
                                  onPressed: loggingOut ? null : handleLogout,
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                  ),
                                  child: ListTile(
                                    leading: const Icon(
                                      Icons.logout,
                                      color: Colors.red,
                                    ),
                                    title: Text(
                                      loggingOut ? 'Logging out...' : 'Logout',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 13,
                                        color: Colors.red,
                                      ),
                                    ),
                                    trailing: const Icon(
                                      Icons.arrow_right,
                                      color: Colors.red,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                    ),
                                    onTap: loggingOut ? null : handleLogout,
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(left: 10.0),
                                  child: Divider(
                                    color: Color.fromARGB(255, 236, 235, 235),
                                    thickness: 1,
                                    endIndent: 30,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
