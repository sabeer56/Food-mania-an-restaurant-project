import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medapp/Biller/BillEntry.dart';
import 'package:medapp/Login.dart';
import 'package:medapp/LoginModel.dart';
import 'package:medapp/Manager/SalesReport.dart';
import 'package:medapp/Manager/StockEntry.dart';
import 'package:medapp/Manager/StockView.dart';
import 'package:medapp/SalesModel.dart';
import 'package:medapp/SystemAdmin/AddUser.dart';
import 'package:medapp/SystemAdmin/UserHistory.dart';
import 'package:medapp/Repositary.dart' as repo;

class InventryDashboard extends StatefulWidget {
  final User currentuser;
  InventryDashboard({required this.currentuser});
  
  @override
  InventryDashboardPage createState() => InventryDashboardPage();
}

class InventryDashboardPage extends State<InventryDashboard> {
  double currentInventory = 0.0; // Move this inside the state class
  
  Future<void> handleLogut() async {
    try {
      await repo.updateLogHistory();
    } catch (e) {
      print(e);
    }
  }

  Future<void> handleCurrentInventryValue() async {
    try {
      CurrentInventryValue val = await repo.fetchCurrentInventryData();
      setState(() {
        currentInventory = val.inventryval.toDouble(); // Update state with inventory value
      });
    } catch (e) {
      print('Error fetching inventory data: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    handleCurrentInventryValue();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color.fromRGBO(45, 40, 192, 1),
        actions: [
          IconButton(
            icon: FaIcon(FontAwesomeIcons.signOutAlt),
            onPressed: () {
              handleLogut();
              print('Logout pressed');
              Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => Login(),
              ),
            );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromRGBO(45, 40, 192, 1),
              ),
              child: Text(
                'Inventry',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: FaIcon(
                FontAwesomeIcons.chartLine,
                color: Color.fromRGBO(45, 40, 192, 1),
              ),
              title: Text('STOCK VIEW',   style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => StockView()));
              },
            ),
            ListTile(
              leading: FaIcon(
                FontAwesomeIcons.box,
                color: Color.fromRGBO(45, 40, 192, 1),
              ),
              title: Text('STOCK ENTRY',  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => StockEntry(currentuser: widget.currentuser)));
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Container(
            width: screenWidth,
            height: screenHeight * 0.4,
            color: Color.fromRGBO(45, 40, 192, 1),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 60),
                        ListTile(
                          leading: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: Tooltip(
                              message: 'Current Inventory Value',
                              child: FaIcon(FontAwesomeIcons.box, color: Colors.white),
                            ),
                          ),
                          title: Text('Current Inventory Value', style: TextStyle(color: Colors.white)),
                          trailing: Text(
                            currentInventory.toStringAsFixed(2), // Dynamically display the inventory value
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: screenHeight * 0.4 - 20,
            left: 0,
            right: 0,
            child: Container(
              height: screenHeight - screenHeight * 0.4 - 20,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
