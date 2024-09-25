import 'dart:html' as html;
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medapp/LoginModel.dart';
import 'package:medapp/Repositary.dart' as repo;
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';

class UserLogsPage extends StatefulWidget {
  @override
  _UserLogsPageState createState() => _UserLogsPageState();
}

class _UserLogsPageState extends State<UserLogsPage> {
  Future<List<UserLogDetails>>? _userLogs;

  @override
  void initState() {
    super.initState();
    _fetchLogDetails();
  }

  Future<void> _fetchLogDetails() async {
    try {
      final logs = await repo.fetchUserLogCredentials();
      logs.sort((a, b) => b.id.compareTo(a.id));
      setState(() {
        _userLogs = Future.value(logs);
      });
    } catch (e) {
      print('Error fetching log details: $e');
      // Optionally show an error message to the user
    }
  }

  Future<void> _handleLogout() async {
    try {
      await repo.updateLogHistory();
      Navigator.pop(context);
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Image.asset(
              'assets/History-removebg-preview.png',
              width: MediaQuery.of(context).size.width * 0.5, // Responsive width
              height: MediaQuery.of(context).size.width * 0.3, // Responsive height
              fit: BoxFit.contain,
            ),
            SystemComponent(userLogsFuture: _userLogs),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<List<UserLogDetails>>(
                future: _userLogs,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No Logs Available'));
                  }

                  final logs = snapshot.data!;

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columnSpacing: 16, // Adjust spacing as needed
                            columns: [
                              DataColumn(label: Text('User ID')),
                              DataColumn(label: Text('Type')),
                              DataColumn(label: Text('Login Time')),
                              DataColumn(label: Text('Login Date')),
                              DataColumn(label: Text('Role')),
                              DataColumn(label: Text('Logout Time')),
                              DataColumn(label: Text('Logout Date')),
                            ],
                            rows: logs.map((log) {
                              return DataRow(
                                cells: [
                                  DataCell(Text(log.userId.isEmpty ? 'N/A' : log.userId)),
                                  DataCell(Text(log.type.isEmpty ? 'N/A' : log.type)),
                                  DataCell(Text(log.loginTime.isEmpty ? 'N/A' : log.loginTime)),
                                  DataCell(Text(log.loginDate.isEmpty ? 'N/A' : log.loginDate)),
                                  DataCell(Text(log.role.isEmpty ? 'N/A' : log.role)),
                                  DataCell(Text(log.logoutTime.isEmpty ? 'N/A' : log.logoutTime)),
                                  DataCell(Text(log.logoutDate.isEmpty ? 'N/A' : log.logoutDate)),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SystemComponent extends StatelessWidget {
  final Future<List<UserLogDetails>>? userLogsFuture;

  SystemComponent({required this.userLogsFuture});

  Future<void> _generateCSV(BuildContext context) async {
    final logs = await userLogsFuture; // Ensure you have data
    if (logs == null || logs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No logs available to generate CSV.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    List<List<dynamic>> rows = [
      [
        'User ID', 'Type', 'Login Time', 'Login Date', 'Role', 'Logout Time', 'Logout Date'
      ]
    ];

    for (var log in logs) {
      rows.add([
        log.userId,
        log.type,
        log.loginTime,
        log.loginDate,
        log.role,
        log.logoutTime,
        log.logoutDate
      ]);
    }

    String csvData = const ListToCsvConverter().convert(rows);

    if (kIsWeb) {
      // Web-specific code
      final blob = html.Blob([csvData]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', 'user_logs.csv')
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
        final path = '${directory.path}/user_logs.csv';
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
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.grey[200],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              'User Login & Logout History',
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.05,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 10), // Add some space between text and button
          Container(
            width: 80,
            height: 30,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.amber,
            ),
            child: TextButton(
              onPressed: () => _generateCSV(context),
              child: Center(
                child: Text(
                  'Download',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: MediaQuery.of(context).size.width * 0.020,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
