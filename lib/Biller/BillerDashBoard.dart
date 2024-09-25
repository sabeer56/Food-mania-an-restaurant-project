import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:medapp/Biller/BillEntry.dart';
import 'package:medapp/Login.dart';
import 'package:medapp/LoginModel.dart';
import 'package:medapp/Manager/StockView.dart';
import 'package:medapp/Repositary.dart' as repo;
import 'package:medapp/SalesModel.dart';

class BillerDashboard extends StatefulWidget {
  final User currentuser;

  BillerDashboard({required this.currentuser});

  @override
  BillerDashboardPage createState() => BillerDashboardPage();
}

class BillerDashboardPage extends State<BillerDashboard> {
    Future<void> handleLogut() async {
    try {
      await repo.updateLogHistory();
    } catch (e) {
      print(e);
    }
  }
  List<TodaySalesByBiller>? salesData;
  double todaySales = 0.0;
  String salesComparison = 'same'; // Initialize comparison state
  DateTime date = DateTime.now(); // Initialize with current date

  @override
  void initState() {
    super.initState();
    fetchSalesData();
  }

  Future<void> fetchSalesData() async {
    try {
      // Fetch today's sales data
      List<TodaySalesByBiller> todayData = await repo.fetchTodaySalesData(
        DateFormat('yyyy-MM-dd').format(date),
      );

      // Fetch yesterday's sales data
      DateTime yesterdayDate = date.subtract(Duration(days: 1));
      List<TodaySalesByBiller> yesterdayData = await repo.fetchTodaySalesData(
        DateFormat('yyyy-MM-dd').format(yesterdayDate),
      );

      setState(() {
        salesData = todayData;

        // Find today's sales for the current user
        final currentUserTodaySales = todayData.firstWhere(
          (item) => item.login_id == widget.currentuser.userId,
          orElse: () => TodaySalesByBiller(login_id: '', todaytotalsale: 0.0),
        );
        todaySales = currentUserTodaySales.todaytotalsale;

        // Find yesterday's sales for the current user
        final currentUserYesterdaySales = yesterdayData.firstWhere(
          (item) => item.login_id == widget.currentuser.userId,
          orElse: () => TodaySalesByBiller(login_id: '', todaytotalsale: 0.0),
        );
        double yesterdaySales = currentUserYesterdaySales.todaytotalsale;

        // Compare today's and yesterday's sales
        if (todaySales > yesterdaySales) {
          salesComparison = 'up';
        } else if (todaySales < yesterdaySales) {
          salesComparison = 'down';
        } else {
          salesComparison = 'same';
        }
      });
    } catch (e) {
      print('Error fetching sales data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white, // Change the drawer icon color here
        ),
        backgroundColor: Color.fromRGBO(45, 40, 192, 1), // Adjusted opacity
         actions: [
          IconButton(
            icon: FaIcon(FontAwesomeIcons.signOutAlt), // Logout icon
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
          padding: EdgeInsets.zero, // Remove default padding if not needed
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromRGBO(45, 40, 192, 1), // Same color as AppBar
              ),
              child: Text(
                'Biller',
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
                color: Color.fromRGBO(45, 40, 192, 1), // Icon color
              ),
              title: TextButton(
                onPressed: () {},
                child: Text(
                  'STOCK VIEW',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StockView()),
                );
              },
            ),
            ListTile(
              leading: FaIcon(
                FontAwesomeIcons.box,
                color: Color.fromRGBO(45, 40, 192, 1), // Icon color
              ),
              title: TextButton(
                onPressed: () {},
                child: Text(
                  'BILL ENTRY',
                   style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BillEntry(currentuser: widget.currentuser)),
                );
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
                              message: 'Today Sales',
                              child: FaIcon(FontAwesomeIcons.chartLine, color: Colors.white),
                            ),
                          ),
                          title: Text('Today Sales', style: TextStyle(color: Colors.white)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                todaySales.toStringAsFixed(2),
                                style: TextStyle(color: Colors.white),
                              ),
                              SizedBox(width: 8),
                              salesComparison == 'up'
                                ? FaIcon(FontAwesomeIcons.arrowUp, color: Colors.green)
                                : salesComparison == 'down'
                                  ? FaIcon(FontAwesomeIcons.arrowDown, color: Colors.red)
                                  : Container(), // If same, no arrow
                            ],
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
