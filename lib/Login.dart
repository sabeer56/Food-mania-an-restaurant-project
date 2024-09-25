import 'package:flutter/material.dart';
import 'package:medapp/Biller/BillerDashBoard.dart';
import 'package:medapp/Inventry/InventryDashBoard.dart';
import 'package:medapp/LoginModel.dart';
import 'package:medapp/Manager/ManagerDashBoard.dart';
import 'package:medapp/SystemAdmin/SystemAdminDashBoard.dart';
import 'package:medapp/Repositary.dart' as repo;

class Login extends StatefulWidget {
  @override
  LoginPage createState() => LoginPage();
}

class LoginPage extends State<Login> {
  final _userIdController = TextEditingController();
  final _passwordController = TextEditingController();
  User? currentuser;
  List<dynamic>? users;

  Future<void> _handleLogin() async {
    final userId = _userIdController.text;
    final password = _passwordController.text;

    if (userId.isEmpty || password.isEmpty) {
      _showSnackBar('Please enter both User ID and Password');
      return;
    }

    try {
      users = await repo.fetchUserCredentials();
      print('Fetched Users: $users');

      final user = users?.firstWhere(
        (ele) => ele.userId == userId && ele.password == password,
     
      );

      print('Found User: $user');

      if (user != null) {
        try {
          currentuser = User(
            userId: user.userId,
            role: user.role,
            type: 'Log In',
          );
          await repo.addLogInUserDetails(currentuser!); // Changed to currentuser
        } catch (e) {
          print('Error logging in user: $e');
        }
        switch (user.role) {
          case 'Manager':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ManagerDashboard(currentuser: currentuser!),
              ),
            );
            break;
          case 'System Admin':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SystemAdminDashboard(currentuser: currentuser!),
              ),
            );
            break;
          case 'Biller':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BillerDashboard(currentuser: currentuser!),
              ),
            );
            break;
          case 'Inventry':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => InventryDashboard(currentuser: currentuser!),
              ),
            );
            break;
          default:
            _showSnackBar('Invalid User Role');
            break;
        }
      } else {
        _showSnackBar('Invalid User ID or Password');
      }
    } catch (e) {
      print('Login Error: $e');
      _showSnackBar('Failed to fetch user credentials');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.deepPurpleAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/heartbeat.png',
                  width: 150,
                  height: 150,
                ),
                SizedBox(height: 20),
                Text(
                  'Med App',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 30),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    controller: _userIdController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[200], // Changed to light grey
                      labelText: 'Enter Your User ID',
                      labelStyle: TextStyle(color: Colors.black87), // Better visibility
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[200], // Changed to light grey
                      labelText: 'Password',
                      labelStyle: TextStyle(color: Colors.black87), // Better visibility
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ElevatedButton(
                    onPressed: _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromRGBO(45, 40, 192, 1),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 14.0),
                    ),
                    child: Text(
                      'Login',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
