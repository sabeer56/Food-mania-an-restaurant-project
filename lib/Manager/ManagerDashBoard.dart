import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:medapp/Login.dart';
import 'package:medapp/LoginModel.dart';
import 'package:medapp/Manager/SalesReport.dart';
import 'package:medapp/Manager/StockEntry.dart';
import 'package:medapp/Manager/StockView.dart';
import 'package:medapp/SalesModel.dart';
import 'package:medapp/SystemAdmin/AddUser.dart';
import 'package:medapp/SystemAdmin/UserHistory.dart';
import 'package:medapp/Repositary.dart' as repo;
import 'package:medapp/charts/DailySales.dart';
import 'package:medapp/charts/MonthlySales.dart';
import 'package:medapp/charts/MonthlySalesByBiller.dart';
import 'package:medapp/charts/PieChart.dart';

class ManagerDashboard extends StatefulWidget {
  final User currentuser;
  ManagerDashboard({required this.currentuser});
  
  @override
  ManagerDashboardPage createState() => ManagerDashboardPage();
}

class ManagerDashboardPage extends State<ManagerDashboard> {
  final ScrollController _scrollController = ScrollController(); // Add this line

  DateTime date = DateTime.now(); // Initialize with current date
  double todaySales = 0.0; // Variable to hold today's sales sum
  double yesterdaySales = 0.0; // Variable to hold yesterday's sales sum
  double currentInventory = 0.0; // Variable to hold current inventory value
  IconData trendIcon = Icons.trending_flat; // Default icon (flat)
  Color trendColor = Colors.grey; // Default color (grey)

  @override
  void initState() {
    super.initState();
    handleSales();
    handleCurrentInventryValue();
  }
  
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

  Future<void> handleSales() async {
    try {
      String todayDate = DateFormat('yyyy-MM-dd').format(date);
      String yesterdayDate = DateFormat('yyyy-MM-dd').format(date.subtract(Duration(days: 1)));

      // Fetch today's sales data
      List<TodaySalesByBiller> todayData = await repo.fetchTodaySalesData(todayDate);
      double todaySum = todayData.fold(
        0.0,
        (previousValue, element) => previousValue + element.todaytotalsale,
      );

      // Fetch yesterday's sales data
      List<TodaySalesByBiller> yesterdayData = await repo.fetchTodaySalesData(yesterdayDate);
      double yesterdaySum = yesterdayData.fold(
        0.0,
        (previousValue, element) => previousValue + element.todaytotalsale,
      );

      // Determine the trend
      IconData trend = Icons.trending_flat;
      Color trendClr = Colors.grey;
      if (todaySum > yesterdaySum) {
        trend = Icons.trending_up;
        trendClr = Colors.green;
      } else if (todaySum < yesterdaySum) {
        trend = Icons.trending_down;
        trendClr = Colors.red;
      }

      setState(() {
        todaySales = todaySum;
        yesterdaySales = yesterdaySum;
        trendIcon = trend;
        trendColor = trendClr;
      });
    } catch (e) {
      print('Error fetching sales data: $e');
    }
  }

  void _scrollToChart(int index) {
    // Adjust the offset based on your chart heights and spacing
    double offset = index * (300 + 16); // Chart height + spacing
    _scrollController.animateTo(
      offset,
      duration: Duration(seconds: 1),
      curve: Curves.easeInOut,
    );
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
        title: Text(
          'Manager',
          style: TextStyle(color: Colors.white, fontSize: 18), // Adjust font size
        ),
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
                'Manager',
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
                  'STOCK ENTRY',
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
                  MaterialPageRoute(builder: (context) => StockEntry(currentuser: widget.currentuser)),
                );
              },
            ),
            ListTile(
              leading: FaIcon(
                FontAwesomeIcons.receipt,
                color: Color.fromRGBO(45, 40, 192, 1), // Icon color
              ),
              title: TextButton(
                onPressed: () {},
                child: Text(
                  'SALES REPORT',
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
                  MaterialPageRoute(builder: (context) => SalesReport()),
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4, // Make the top section take up 40% of the height
            child: Stack(
              children: [
                Container(
                  width: screenWidth,
                  color: Color.fromRGBO(45, 40, 192, 1),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 60,),
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
                                todaySales.toStringAsFixed(2), // Display the sum with 2 decimal places
                                style: TextStyle(color: Colors.white),
                              ),
                              SizedBox(width: 8),
                              Icon(trendIcon, color: trendColor),
                            ],
                          ),
                        ),
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
                            currentInventory.toStringAsFixed(2), // Display the inventory value with 2 decimal places
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        SizedBox(height: 40,),
                        ListTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: Tooltip(
                                  message: 'Today Sales By Biller',
                                  child: IconButton(
                                    icon: FaIcon(FontAwesomeIcons.chartLine, color: Colors.white),
                                    onPressed: () {
                                      _scrollToChart(0); // Scroll to Today Sales By Biller chart
                                    },
                                  ),
                                ),
                              ),
                              MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: Tooltip(
                                  message: 'Daily Sales',
                                  child: IconButton(
                                    icon: FaIcon(FontAwesomeIcons.calendarAlt, color: Colors.white),
                                    onPressed: () {
                                      _scrollToChart(1); // Scroll to Daily Sales chart
                                    },
                                  ),
                                ),
                              ),
                              MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: Tooltip(
                                  message: 'Monthly Sales',
                                  child: IconButton(
                                    icon: FaIcon(FontAwesomeIcons.moneyBill, color: Colors.white),
                                    onPressed: () {
                                      _scrollToChart(2); // Scroll to Monthly Sales chart
                                    },
                                  ),
                                ),
                              ),
                              MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: Tooltip(
                                  message: 'Monthly Sales By Biller',
                                  child: IconButton(
                                    icon: FaIcon(FontAwesomeIcons.receipt, color: Colors.white),
                                    onPressed: () {
                                      _scrollToChart(3); // Scroll to Monthly Sales By Biller chart
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: screenHeight * 0.4 - 20, // Adjust based on your needs
                  left: 0,
                  right: 0,
                  bottom: 0, // Ensure it extends to the bottom
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SingleChildScrollView(
                        controller: _scrollController, // Attach the ScrollController
                        child: Column(
                          children: [
                            Container(
                              width: double.infinity,
                              height: 300,
                              child: TodaySalesByBillerChart(),
                            ),
                            SizedBox(height: 16), // Add spacing between charts
                            Container(
                              width: double.infinity,
                              height: 300,
                              child: Dailysales(),
                            ),
                            SizedBox(height: 16), // Add spacing between charts
                            Container(
                              width: double.infinity,
                              height: 500,
                              child: Monthlysales(),
                            ),
                            SizedBox(height: 16), // Add spacing between charts
                            Container(
                              width: double.infinity,
                              height: 500,
                              child: Monthlysalesbybiller(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
