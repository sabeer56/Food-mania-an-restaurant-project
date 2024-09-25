import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medapp/Biller/BillerDashBoard.dart';
import 'package:medapp/LoginModel.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:medapp/Repositary.dart' as repo;
import 'package:path_provider/path_provider.dart';
import 'dart:html' as html;
class BillEntry extends StatefulWidget {
  final User currentuser;
  BillEntry({required this.currentuser});

  @override
  _BillEntryState createState() => _BillEntryState();
}

class _BillEntryState extends State<BillEntry> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  String? _selectedCategory;
  String? _selectedMedicineName;
  String? _selectedMedicineBrand;
  String _billNo = '';
  List<Map<String, dynamic>> _newBill = [];
  bool _isBillStarted = false;
  late Future<List<Map<String, dynamic>>> _stockItems;
  late Future<List<String>> _categories;

  @override
  void initState() {
    super.initState();
    _stockItems = _fetchStockItems();
    _categories = _fetchCategories();
    _generateUniqueBillNo();
  }

  Future<void> _saveBill() async {
    try {
      await repo.addNewBillDetails(_newBill);
      _showSnackbarMessage('Bill saved successfully');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => BillEntry(currentuser: widget.currentuser)),
      );
    } catch (e) {
      print('Error saving bill: $e');
      _showSnackbarMessage('Failed to save bill');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchStockItems() async {
    try {
      final stock = await repo.fetchStockDetails();
      return stock.map((item) => item as Map<String, dynamic>).toList();
    } catch (e) {
      print('Error fetching stock details: $e');
      _showSnackbarMessage('Failed to fetch stock details');
      return [];
    }
  }

  Future<List<String>> _fetchCategories() async {
    try {
      final stock = await _stockItems;
      // Exclude categories with zero quantity
      final categories = stock
          .where((item) => (item['quantity'] ?? 0) > 0)
          .map((item) => item['medicine_name'].toString()+" "+item['brand'])
         
          .toList();
      return categories;
    } catch (e) {
      print('Error fetching categories: $e');
      _showSnackbarMessage('Failed to fetch categories');
      return [];
    }
  }

  void _generateUniqueBillNo() {
    final now = DateTime.now().millisecondsSinceEpoch%10000;
    setState(() {
      _billNo = now.toString();
    });
  }

  void _addToBill() {
    if (_formKey.currentState?.validate() ?? false) {
      _stockItems.then((stockItems) {
        final parts=_selectedCategory!.split(' ');
          _selectedMedicineBrand=parts[1];
          _selectedMedicineName=parts[0];
          print(_selectedMedicineBrand);
          print(_selectedMedicineName);
        final selectedStock = stockItems.firstWhere(
          (stock) => stock['medicine_name']== _selectedMedicineName!.toString() && stock['brand']==_selectedMedicineBrand!.toString(),
          orElse: () => {'medicine_name': '', 'unit_price': 0.0, 'brand': ''},
        );
        print(stockItems);
  print(selectedStock);
        if (selectedStock['medicine_name'] != '') {
          final quantity = int.parse(_quantityController.text);
          final totalPrice = quantity * selectedStock['unit_price'];
          final gst = totalPrice * 0.18;

          final existingBillIndex = _newBill.indexWhere(
            (bill) => bill['Medicine_Name'] == selectedStock['medicine_name'] && bill['Brand']==selectedStock['brand'],
          );
   print(_newBill);
          if (existingBillIndex != -1) {
            // Update existing entry
            final existingBill = _newBill[existingBillIndex];
            existingBill['Quantity'] += quantity;
            existingBill['UnitPrice'] = existingBill['Quantity'] * selectedStock['unit_price'];
            existingBill['GST'] = existingBill['UnitPrice'] * 0.18;
            existingBill['netprice'] = existingBill['UnitPrice'] + existingBill['GST'];
            _newBill[existingBillIndex] = existingBill;
          } else {
            // Add new entry
            _newBill.add({
              'Medicine_Name': selectedStock['medicine_name'],
              'Brand': selectedStock['brand'],
              'Bill_No': _billNo,
              'Quantity': quantity,
              'UnitPrice': totalPrice,
              'GST': gst,
              'netprice': totalPrice + gst,
              'Created_By': widget.currentuser.userId,
            });
          }

          setState(() {
            _quantityController.clear();
            _showSnackbarMessage('Item added to bill');
            _isBillStarted = true;
          });
        } else {
          _showSnackbarMessage('Selected item not found in stock.');
        }
      });
    }
  }

  void _showSnackbarMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _resetBill() {
    setState(() {
      _newBill.clear();
      _selectedCategory = null;
      _quantityController.clear();
      _generateUniqueBillNo();
      _isBillStarted = false;
    });
  }

Future<void> _downloadCSV() async {
  try {
    // Prepare data for CSV
    final List<List<dynamic>> rows = [
      ['Medicine Name', 'Brand', 'Quantity', 'Unit Price', 'GST', 'Net Price'],
      ..._newBill.map((item) => [
        item['Medicine_Name'],
        item['Brand'],
        item['Quantity'],
        item['UnitPrice'],
        item['GST'],
        item['netprice'],
      ]),
    ];

    // Convert data to CSV format
    String csv = const ListToCsvConverter().convert(rows);

    // Create a Blob from the CSV string
    final blob = html.Blob([csv]);
    final url = html.Url.createObjectUrlFromBlob(blob);

    // Create a link element
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', 'bill_items.csv')
      ..click(); // Trigger the download

    // Revoke the object URL after the download is triggered
    html.Url.revokeObjectUrl(url);
    
    // Inform the user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('CSV file saved successfully')),
    );
  } catch (e) {
    print('Error during CSV download: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to save CSV file')),
    );
  }
}



  void _openPreviewDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Bill Preview', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_isBillStarted) 
                Text(
                  'Bill No: $_billNo',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                ),
              SizedBox(height: 10),
              ..._newBill.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: ListTile(
                    title: Text(item['Medicine_Name'] ?? 'Unknown', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      'Brand: ${item['Brand'] ?? 'Unknown'}\n'
                      'Quantity: ${item['Quantity'] ?? 0}\n'
                      'Unit Price: ${item['UnitPrice'] ?? 0.0}\n'
                      'GST: ${item['GST'] ?? 0.0}\n'
                      'Net Price: ${item['netprice'] ?? 0.0}',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ),
                );
              }).toList(),
              Divider(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Total Amount: ${_newBill.fold<double>(0, (sum, item) => sum + (item['netprice'] ?? 0.0))}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _downloadCSV();
            },
            child: Text('Download CSV'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              elevation: 5,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(45, 40, 192, 1),
        elevation: 6.0,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () {
             Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BillerDashboard(currentuser: widget.currentuser),
              ),
            );
            },
            icon: FaIcon(FontAwesomeIcons.home, size: 15),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              width: screenWidth,
              height: screenHeight * 0.4,
              color: Color.fromRGBO(45, 40, 192, 1),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    Expanded(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            FutureBuilder<List<String>>(
                              future: _categories,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return Center(child: CircularProgressIndicator());
                                } else if (snapshot.hasError) {
                                  return Center(child: Text('Error: ${snapshot.error}'));
                                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                  return Center(child: Text('No categories available.'));
                                } else {
                                  return DropdownButtonFormField<String>(
                                    value: _selectedCategory,
                                    hint: Text('Select a Category'),
                                    items: snapshot.data!.map((String category) {
                                      return DropdownMenuItem<String>(
                                        value: category,
                                        child: Text(category),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        _selectedCategory = newValue;
                                      });
                                    },
                                    decoration: InputDecoration(
                                      labelText: 'Category',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12.0),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                                      filled: true,
                                      fillColor: Colors.white,
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12.0),
                                        borderSide: BorderSide(color: Colors.blue, width: 2),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12.0),
                                        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                            SizedBox(height: 16),
                            TextFormField(
                              controller: _quantityController,
                              decoration: InputDecoration(
                                labelText: 'Quantity',
                                filled: true,
                                fillColor: Colors.grey.shade200,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Quantity is required';
                                }
                                final quantity = int.tryParse(value);
                                if (quantity == null || quantity <= 0) {
                                  return 'Enter a valid quantity';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _addToBill,
                                    child: Text('Add'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12.0),
                                      ),
                                      padding: EdgeInsets.symmetric(horizontal: 14.0),
                                      elevation: 5,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 5),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _resetBill,
                                    child: Text('Cancel'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12.0),
                                      ),
                                      padding: EdgeInsets.symmetric(horizontal: 14.0),
                                      elevation: 5,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 5),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _openPreviewDialog,
                                    child: Text('Preview'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12.0),
                                      ),
                                      padding: EdgeInsets.symmetric(horizontal: 14.0),
                                      elevation: 5,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 5),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _saveBill,
                                    child: Text('Save'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color.fromARGB(255, 175, 76, 170),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12.0),
                                      ),
                                      padding: EdgeInsets.symmetric(horizontal: 14.0),
                                      elevation: 5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  
                    if (_isBillStarted)
                      Text(
                        'Bill No: $_billNo',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: screenHeight * 0.4 - 20,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _newBill.isEmpty
                    ? Center(child: Text('No items added yet', style: TextStyle(fontSize: 18, color: Colors.grey.shade600)))
                    : ListView.builder(
                        itemCount: _newBill.length,
                        itemBuilder: (context, index) {
                          final item = _newBill[index];
                          return Card(
                            elevation: 3,
                            margin: EdgeInsets.symmetric(vertical: 8.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.all(12.0),
                              title: Text(item['Medicine_Name'] ?? 'Unknown', style: TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(
                                'Brand: ${item['Brand'] ?? 'Unknown'}\n'
                                'Quantity: ${item['Quantity'] ?? 0}\n'
                                'Unit Price: ${item['UnitPrice'] ?? 0.0}',
                                style: TextStyle(color: Colors.grey.shade700),
                              ),
                              trailing: Text(
                                'Net Payable: ${item['netprice'] ?? 0.0}',
                                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
