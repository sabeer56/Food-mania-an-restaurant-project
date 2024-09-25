import 'package:flutter/material.dart';
import 'package:medapp/LoginModel.dart';
import 'package:medapp/Repositary.dart' as repo;

class AddUserPage extends StatefulWidget {
  final User currentuser;

  AddUserPage({required this.currentuser});

  @override
  _AddUserPageState createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  final _formKey = GlobalKey<FormState>();
  final _userIdController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _selectedRole;
  bool _showPassword = false;
  final List<String> _roleOptions = ["Biller", "Manager", "System Admin", "Inventory"];
  String _errorMessage = '';
  List<dynamic>? users;

  Future<void> handleAddUser() async {
    if (!_formKey.currentState!.validate()) {
      _showSnackbar('Please fill out all fields correctly.');
      return;
    }

    try {
      // Fetch existing users
      users = await repo.fetchUserCredentials();
      print('Fetched Users: $users');

      // Check if the user already exists
      final userExists = users?.any(
        (ele) => ele.userId == _userIdController.text,
      );

      if (userExists == true) {
        _showSnackbar('User already exists.');
      } else {
        // Create a new user
        final newUser = AddUser(
          userId: _userIdController.text,
          role: _selectedRole!,
          password: _passwordController.text,
          created_By: widget.currentuser.userId,
        );
        
        // Add new user to the repository
        await repo.addNewUserDetails(newUser);
        _showSnackbar('User added successfully!', color: Colors.green);
      }
    } catch (e) {
      print(e);
      _showSnackbar('An error occurred while adding the user.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;

    return Scaffold(
     
      body: Container(
        
        child: Stack(
          children: [
            Positioned(
              top: 10,
              left: screenWidth * 0.3,
              child: Container(
                child: Image.asset(
                  'assets/adduser-removebg-preview.png',
                  width: 200,
                  height: 150,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              top: 170,
              left: 0,
              right: 0,
              child: Divider(
                color: Colors.white70, // Divider color
                thickness: 1.5,
                indent: screenWidth * 0.3, // Adjust indent based on screen width
                endIndent: screenWidth * 0.3,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: SingleChildScrollView(
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Add User',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color.fromRGBO(45, 40, 192, 1),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 16),
                          Divider(
                            color: Colors.white70,
                            thickness: 1,
                            indent: screenWidth * 0.35,
                            endIndent: screenWidth * 0.35,
                          ),
                          SizedBox(height: 16),
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _userIdController,
                                  decoration: InputDecoration(
                                    labelText: 'User ID',
                                    prefixIcon: Icon(Icons.account_circle, color: Color.fromRGBO(45, 40, 192, 1)),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) return 'User ID is required';
                                    if (value.contains(' ')) return 'User ID cannot contain spaces';
                                    RegExp emailRegExp = RegExp(r'^[^\s@.]+@[^\s@.]+\.[^\s@.]{2,}$');
                                    return emailRegExp.hasMatch(value) && !value.contains('..')
                                        ? null
                                        : 'Invalid User ID';
                                  },
                                ),
                                SizedBox(height: 16),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: !_showPassword,
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    prefixIcon: Icon(Icons.lock, color: Color.fromRGBO(45, 40, 192, 1)),
                                    suffixIcon: IconButton(
                                      icon: Icon(_showPassword ? Icons.visibility : Icons.visibility_off),
                                      onPressed: () {
                                        setState(() {
                                          _showPassword = !_showPassword;
                                        });
                                      },
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) return 'Password is required';
                                    if (value.length < 8) return 'Password must be at least 8 characters long';
                                    RegExp passwordRegExp = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');
                                    return passwordRegExp.hasMatch(value)
                                        ? null
                                        : 'Invalid Password';
                                  },
                                ),
                                SizedBox(height: 16),
                                DropdownButtonFormField<String>(
                                  value: _selectedRole,
                                  hint: Text('Select Role'),
                                  items: _roleOptions.map((role) {
                                    return DropdownMenuItem<String>(
                                      value: role,
                                      child: Text(role),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedRole = value;
                                    });
                                  },
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null) return 'Role is required';
                                    return null;
                                  },
                                ),
                                SizedBox(height: 16),
                                if (_errorMessage.isNotEmpty)
                                  Text(
                                    _errorMessage,
                                    style: TextStyle(color: Colors.red),
                                  ),
                                SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    ElevatedButton(
                                      onPressed: handleAddUser,
                                      child: Text('Add User', style: TextStyle(color: Colors.white)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color.fromRGBO(45, 40, 192, 1),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        padding: EdgeInsets.symmetric(vertical: 14.0),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text('Back', style: TextStyle(color: Colors.white)),
                                      style: TextButton.styleFrom(
                                        backgroundColor: Colors.black,
                                        padding: EdgeInsets.symmetric(vertical: 14.0),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackbar(String message, {Color color = Colors.red}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: Duration(seconds: 3),
      ),
    );
  }
}
