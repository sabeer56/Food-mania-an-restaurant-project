import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:medapp/Repositary.dart' as repo;
import 'package:medapp/SalesModel.dart';
import 'dart:html' as html;

class SalesReport extends StatefulWidget {
  @override
  _SalesReportState createState() => _SalesReportState();
}

class _SalesReportState extends State<SalesReport> {
  DateTime? fromDate;
  DateTime? toDate;

  Future<List<SalesModel>>? salesData;
  final List<Map<String, dynamic>> tableHeaders = [
    {"text": "Bill No", "value": "bill_no"},
    {"text": "Bill Date", "value": "bill_date"},
    {"text": "Medicine Name", "value": "medicine_name"},
    {"text": "Quantity", "value": "quantity"},
    {"text": "Amount", "value": "netprice"},
  ];
  String search = '';

  Future<void> handleSalesReport() async {
  salesData = Future.value([]);
    if (fromDate == null || toDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select both From Date and To Date.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (fromDate!.isAfter(toDate!)) {
     setState(() {
        salesData = Future.value([]);
     });
    
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('From Date cannot be after To Date.'),
          backgroundColor: Colors.red,
        ),
      );
       
      return;
    }

    setState(() {
      salesData = repo.fetchSalesData(
        DateFormat('yyyy-MM-dd').format(fromDate!),
        DateFormat('yyyy-MM-dd').format(toDate!),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: FaIcon(FontAwesomeIcons.home, size: 20),
          ),
        ],
        backgroundColor: Color(0xFF2D28C0),
        elevation: 4,
      ),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Color(0xFF2D28C0),
          ),
          Positioned(
            top: 80,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 5,
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildDatePicker(
                            label: 'From Date',
                            selectedDate: fromDate,
                            onDateSelected: (date) {
                              setState(() {
                                fromDate = date;
                              });
                            },
                            isToDate: false,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: _buildDatePicker(
                            label: 'To Date',
                            selectedDate: toDate,
                            onDateSelected: (date) {
                              setState(() {
                                toDate = date;
                              });
                            },
                            isToDate: true,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: handleSalesReport,
                            child: Text('Search'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 5,
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _exportToCSV,
                            child: Text('Download CSV'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    TextField(
                      onChanged: (value) {
                        setState(() {
                          search = value;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Search',
                        suffixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                    ),
                    SizedBox(height: 16),
                    Expanded(
                      child: FutureBuilder<List<SalesModel>>(
                        future: salesData,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(child: Text('Error: ${snapshot.error}'));
                          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Center(child: Text('No sales data available.'));
                          } else {
                            final filteredSalesData = snapshot.data!.where((item) {
                              final searchText = search.toLowerCase();
                              return item.billNo.toLowerCase().contains(searchText) ||
                                  item.medicineName.toLowerCase().contains(searchText);
                            }).toList();

                            return SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                columnSpacing: 16,
                                headingRowHeight: 56,
                                dataRowHeight: 56,
                                columns: tableHeaders.map((header) {
                                  return DataColumn(
                                    label: Text(
                                      header['text'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2D28C0),
                                      ),
                                    ),
                                  );
                                }).toList(),
                                rows: filteredSalesData.map((item) {
                                  return DataRow(
                                    cells: tableHeaders.map((header) {
                                      return DataCell(
                                        Text(
                                          item.toMap()[header['value']].toString(),
                                          style: TextStyle(color: Colors.black87),
                                        ),
                                      );
                                    }).toList(),
                                  );
                                }).toList(),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime? selectedDate,
    required ValueChanged<DateTime> onDateSelected,
    required bool isToDate,
  }) {
    return GestureDetector(
      onTap: () async {
        final DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: isToDate ? DateTime.now() : DateTime(2101),
          builder: (context, child) {
            return Theme(
              data: ThemeData.light().copyWith(
                primaryColor: Color(0xFF2D28C0),
                buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
              ),
              child: child!,
            );
          },
        );
        if (pickedDate != null && pickedDate != selectedDate) {
          onDateSelected(pickedDate);
        }
      },
      child: AbsorbPointer(
        child: TextField(
          controller: TextEditingController(
            text: selectedDate != null
                ? DateFormat('yyyy-MM-dd').format(selectedDate)
                : '',
          ),
          decoration: InputDecoration(
            labelText: label,
            suffixIcon: Icon(Icons.calendar_today),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            hintText: selectedDate != null
                ? DateFormat('yyyy-MM-dd').format(selectedDate)
                : 'Select Date',
            filled: true,
            fillColor: Colors.grey[200],
          ),
        ),
      ),
    );
  }
Future<void> _exportToCSV() async {
  try {
    // Get the sales data
    final List<SalesModel>? data = await salesData;

    if (data == null || data.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No sales data to export.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Convert data to CSV
    final csv = convertToCSV(data);

    // Create a blob from CSV string
    final blob = html.Blob([csv]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', 'salesReport.csv')
      ..click();
    html.Url.revokeObjectUrl(url);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('CSV file downloaded successfully.'),
        backgroundColor: Colors.green,
      ),
    );
  } catch (e) {
    print("Error while exporting to CSV: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to export CSV.'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

String convertToCSV(List<SalesModel> data) {
  final List<List<dynamic>> rows = [];
  // Add headers
  rows.add(tableHeaders.map((header) => header['text']).toList());
  // Add data rows
  for (var item in data) {
    rows.add(tableHeaders.map((header) => item.toMap()[header['value']]).toList());
  }
  return const ListToCsvConverter().convert(rows);
}

}
