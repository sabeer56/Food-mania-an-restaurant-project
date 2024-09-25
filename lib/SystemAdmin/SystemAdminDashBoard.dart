import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medapp/Login.dart';
import 'package:medapp/LoginModel.dart';
import 'package:medapp/SystemAdmin/AddUser.dart';
import 'package:medapp/SystemAdmin/UserHistory.dart';
import 'package:medapp/Repositary.dart' as repo;

class SystemAdminDashboard extends StatefulWidget {
  final User currentuser;

  SystemAdminDashboard({required this.currentuser});

  @override
  SystemAdminDashboardPage createState() => SystemAdminDashboardPage();
}

class SystemAdminDashboardPage extends State<SystemAdminDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

 Future<void> handleLogut() async {
    try {
      await repo.updateLogHistory();
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white, // Change the drawer icon color here
        ),
        backgroundColor: Color.fromRGBO(45, 40, 192, 1), // Adjusted opacity
        title: Text(
          'System Admin',
          style: TextStyle(color: Colors.white, fontSize: 18), // Adjust font size
        ),
        actions: [
          IconButton(
            icon: FaIcon(FontAwesomeIcons.signOutAlt), // Logout icon
            onPressed: () {
              handleLogut();
               Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => Login(),
              ),
            );
              print('Logout pressed');
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white, // Color for the active tab text
          unselectedLabelColor: Colors.grey, // Color for the inactive tab text
          indicatorColor: Colors.white, // Color of the tab indicator
          tabs: [
            Tab(text: 'Add User'),
            Tab(text: 'Login History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          AddUserPage(currentuser: widget.currentuser),
          UserLogsPage(),
        ],
      ),
    );
  }
}
