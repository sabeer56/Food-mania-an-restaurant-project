import 'dart:html' as html;
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:medapp/Repositary.dart' as repo;

class StockView extends StatefulWidget {
  @override
  _StockViewState createState() => _StockViewState();
}

class _StockViewState extends State<StockView> with SingleTickerProviderStateMixin {
  Future<List<dynamic>>? _stocks;
  final TextEditingController _searchController = TextEditingController();
  String _search = "";
  ScrollController _scrollController = ScrollController();
  AnimationController? _animationController;
  Animation<double>? _animation;

  @override
  void initState() {
    super.initState();

    // Set up animation for the button
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.0, end: 10.0).animate(
      CurvedAnimation(
        parent: _animationController!,
        curve: Curves.bounceIn,
      ),
    );

    // Fetch stock details when the widget initializes
    _fetchStockDetails();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController?.dispose();
    super.dispose();
  }

  Future<void> _fetchStockDetails() async {
    try {
      final stock = await repo.fetchStockDetails();
      setState(() {
        _stocks = Future.value(stock);
      });
    } catch (e) {
      print('Error fetching stock details: $e');
      setState(() {
        _stocks = Future.value([]);
      });
    }
  }

  Future<List<dynamic>> _getFilteredStocks() async {
    final stocks = await _stocks ?? [];
    if (_search.isEmpty) {
      return stocks;
    }
    return stocks.where((stock) {
      return (stock['medicine_name'] as String).toLowerCase().contains(_search.toLowerCase());
    }).toList();
  }

  Future<void> _generateCSV(BuildContext context) async {
    final stocks = await _getFilteredStocks();
    if (stocks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No data available to generate CSV.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    List<List<dynamic>> rows = [
      ['Medicine Name', 'Brand', 'Quantity', 'Unit Price']
    ];

    for (var stock in stocks) {
      rows.add([
        stock['medicine_name'],
        stock['brand'],
        stock['quantity'],
        stock['unit_price'],
      ]);
    }

    String csvData = const ListToCsvConverter().convert(rows);

    if (kIsWeb) {
      // Web-specific code
      final blob = html.Blob([csvData]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', 'stock_data.csv')
        ..click();
      html.Url.revokeObjectUrl(url);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('CSV file downloaded successfully.'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      // Mobile-specific code
      try {
        final directory = await getApplicationDocumentsDirectory();
        final path = '${directory.path}/stock_data.csv';
        final file = File(path);

        await file.writeAsString(csvData);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('CSV file saved at $path'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        print('Error saving CSV file: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save CSV file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final userRole = 'Manager'; // Example user role, replace with dynamic role

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white, // Change the drawer icon color here
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: FaIcon(FontAwesomeIcons.home, size: 15),
          ),
        ],
        backgroundColor: Color.fromRGBO(45, 40, 192, 1),
      ),
      body: Column(
        children: [
          Container(
            width: screenWidth,
            height: screenHeight * 0.4,
            decoration: BoxDecoration(
              color: Color.fromRGBO(45, 40, 192, 1),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30.0),
                bottomRight: Radius.circular(30.0),
              ),
            ),
            child: Column(
              children: [
                Center(
                  child: Image.asset(
                    'assets/stock1.png',
                    width: 250,
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                ),
                AnimatedBuilder(
                  animation: _animation!,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _animation!.value),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(16.0),
                        ),
                        onPressed: () {
                          _scrollController.animateTo(
                            _scrollController.position.maxScrollExtent,
                            duration: Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: Icon(Icons.arrow_downward, color: Color.fromRGBO(45, 40, 192, 1)),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30.0),
                        topRight: Radius.circular(30.0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10.0,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Conditionally display components based on the user's role
                        if (userRole == 'Biller') BillComponent(),
                        if (userRole == 'Manager') ManagerComponent(),
                        if (userRole == 'Inventory') InventoryComponent(),

                        SizedBox(height: 16.0),

                        // Search input field
                        TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            setState(() {
                              _search = value;
                            });
                          },
                          decoration: InputDecoration(
                            labelText: 'Search',
                            prefixIcon: Icon(Icons.search, color: Color.fromRGBO(45, 40, 192, 1)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(color: Color.fromRGBO(45, 40, 192, 1)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(color: Color.fromRGBO(45, 40, 192, 1), width: 2.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(color: Color.fromRGBO(45, 40, 192, 1).withOpacity(0.5)),
                            ),
                          ),
                        ),

                        SizedBox(height: 16.0),

                        // Data table to display stocks
                        FutureBuilder<List<dynamic>>(
                          future: _getFilteredStocks(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Center(child: Text('Error: ${snapshot.error}'));
                            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return Center(child: Text('No data available'));
                            } else {
                              return SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  columnSpacing: 16.0,
                                  columns: [
                                    DataColumn(label: Text('Medicine Name', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Brand', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Quantity', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Unit Price', style: TextStyle(fontWeight: FontWeight.bold))),
                                  ],
                                  rows: snapshot.data!.map((stock) {
                                    return DataRow(cells: [
                                      DataCell(Text(stock['medicine_name'] ?? '')),
                                      DataCell(Text(stock['brand'] ?? '')),
                                      DataCell(Text(stock['quantity']?.toString() ?? '')),
                                      DataCell(Text(stock['unit_price']?.toString() ?? '')),
                                    ]);
                                  }).toList(),
                                ),
                              );
                            }
                          },
                        ),
                        
                        SizedBox(height: 16.0),

                        // Download button
                        ElevatedButton(
                          onPressed: () => _generateCSV(context),
                          child: Text('Download CSV',style: TextStyle(color:Colors.white),),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromRGBO(45, 40, 192, 1),
                           
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Placeholder components for conditional display
class BillComponent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.deepPurple[50],
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4.0, offset: Offset(0, 2))],
      ),
      child: Text(
        'Bill Component',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple),
      ),
    );
  }
}

class ManagerComponent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.deepPurple[50],
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4.0, offset: Offset(0, 2))],
      ),
      child: Text(
        'Stock View',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple),
      ),
    );
  }
}

class InventoryComponent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.deepPurple[50],
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4.0, offset: Offset(0, 2))],
      ),
      child: Text(
        'Inventory Component',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple),
      ),
    );
  }
}
