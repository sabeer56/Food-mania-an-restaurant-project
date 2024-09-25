import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:http/http.dart' as http;
import 'package:medapp/LoginModel.dart';
import 'package:medapp/SalesModel.dart';
import 'package:medapp/StockModel.dart';

import 'package:flutter/material.dart'; 

final baseUrl='http://localhost:9090';
Future<List<LoginModel>> fetchUserCredentials() async {
  final response = await http.get(Uri.parse('${baseUrl}/getuser'));

  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

    // Extract the list of users from "userArr"
    final List<dynamic> userList = jsonResponse['userArr'];
     print(userList);
    return userList.map((data) => LoginModel.fromJson(data)).toList();
  } else {
    throw Exception('Failed to load user credentials');
  }
}


Future<void> addLogInUserDetails(User user) async {
  final url = Uri.parse('${baseUrl}/addloghistory');
  final headers = {'Content-Type': 'application/json'};
  
  // Convert user object to JSON string
  final data = jsonEncode(user.toJson());

  try {
    final response = await http.post(url, headers: headers, body: data);
    
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      
      if (responseData['status'] == 'S') {
        // Handle success
        print('Login successful');
      } else {
        // Handle failure status
        print('Login failed: ${responseData['message']}');
      }
    } else {
      // Handle non-200 response codes
      print('Failed to login: ${response.statusCode}');
    }
  } catch (e) {
    // Handle any errors that occur during the HTTP request
    print('An error occurred: $e');
  }}


  Future<List<UserLogDetails>> fetchUserLogCredentials() async {
  final response = await http.get(Uri.parse('${baseUrl}/getuserlogs'));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    if (data['status'] == 'S') {
      List<dynamic> userLogsJson = data['userlogs'];
      return userLogsJson
          .map((json) => UserLogDetails.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load user logs');
    }
  } else {
    throw Exception('Failed to load user logs');
  }
}


Future<void> updateLogHistory()async{
   final response=await http.put(Uri.parse('${baseUrl}/updateloghistory'));
   if(response.statusCode==200){
       final data=jsonDecode(response.body);
       if(data['status']=='S'){
         print('Logout Done SuccessFully');
       }
       else {
      throw Exception('Failed to load user logs');
    }
   }

}

Future<void> addNewUserDetails(AddUser user) async {
  final url = Uri.parse('${baseUrl}/adduser');
  final headers = {'Content-Type': 'application/json'};
  
  // Convert user object to JSON string
  final data = jsonEncode(user.toJson());

  try {
    final response = await http.post(url, headers: headers, body: data);
    
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      
      if (responseData['status'] == 'S') {
        // Handle success
        print('Login successful');
      } else {
        // Handle failure status
        print('Login failed: ${responseData['message']}');
      }
    } else {
      // Handle non-200 response codes
      print('Failed to login: ${response.statusCode}');
    }
  } catch (e) {
    // Handle any errors that occur during the HTTP request
    print('An error occurred: $e');
  }}

 Future<List<dynamic>> fetchStockDetails() async {
  final response = await http.get(Uri.parse('${baseUrl}/stockview'));

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = json.decode(response.body);
    if (data['status'] == 'S') {
      // Extract the 'stockArr' array from the response
      return List<dynamic>.from(data['stockArr']);
    } else {
      throw Exception('Failed to load stock details');
    }
  } else {
    throw Exception('Failed to load stock details');
  }
}
Future<String> convertToCSV(List<SalesModel> salesData) async {
  List<List<dynamic>> rows = [];

  // Add header
  rows.add([
    'Bill No',
    'Medicine Name',
    'Bill Date',
    'Quantity',
    'Net Price'
  ]);

  // Add data
  for (var sale in salesData) {
    rows.add([
      sale.billNo,
      sale.medicineName,
      sale.billDate,
      sale.quantity,
      sale.netPrice
    ]);
  }

  // Convert to CSV
  String csv = const ListToCsvConverter().convert(rows);
  return csv;
}
Future<void> addNewStockDetails(AddStock stock) async {
  final url = Uri.parse('${baseUrl}/addstock');
  final headers = {'Content-Type': 'application/json'};
  
  // Convert user object to JSON string
  final data = jsonEncode(stock.toJson());

  try {
    final response = await http.post(url, headers: headers, body: data);
    
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      
      if (responseData['status'] == 'S') {
        // Handle success
        print('stock added');
      } else {
        // Handle failure status
        print('stock failed: ${responseData['message']}');
      }
    } else {
      // Handle non-200 response codes
      print('Failed to add: ${response.statusCode}');
    }
  } catch (e) {
    // Handle any errors that occur during the HTTP request
    print('An error occurred: $e');
  }}


Future<List<Stock>> fetchStockDetails1() async {
  final response = await http.get(Uri.parse('${baseUrl}/stockview'));

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = json.decode(response.body);
    if (data['status'] == 'S') {
      // Extract the 'stockArr' array from the response
      List<dynamic> stockArr = data['stockArr'];
      // Map the list of JSON objects to a list of Stock objects
      return stockArr.map((item) => Stock.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load stock details');
    }
  } else {
    throw Exception('Failed to load stock details');
  }
}


Future<void> updateNewStockDetails(BuildContext context, UpdateStock stock) async {
  final url = Uri.parse('${baseUrl}/updatestock');
  final headers = {'Content-Type': 'application/json'};
  
  // Convert user object to JSON string
  final data = jsonEncode(stock.toJson());

  try {
    final response = await http.post(url, headers: headers, body: data);
    
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      
      if (responseData['status'] == 'S') {
        // Handle success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Stock updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Handle failure status
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Stock update failed: ${responseData['message']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      // Handle non-200 response codes
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update stock. Status code: ${response.statusCode}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } catch (e) {
    // Handle any errors that occur during the HTTP request
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('An error occurred: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}


Future<List<SalesModel>> fetchSalesData(String fromDate, String toDate) async {
  final url = Uri.parse('${baseUrl}/salesreport')
      .replace(queryParameters: {
    'from_date': fromDate,
    'to_date': toDate,
  });

  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse['status'] == 'S') {
        List<dynamic> data = jsonResponse['salesResultArr'];
        return data.map((item) => SalesModel.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load sales data. Status: ${jsonResponse['status']}');
      }
    } else {
      throw Exception('Failed to load sales data. Status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching sales data: $e');
    return [];
  }
}
Future<void> addNewBillDetails(List<Map<String, dynamic>> data) async {
  final url = Uri.parse('${baseUrl}/addbill');
  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data), 
    );

    if (response.statusCode == 200) {
      await addNewBillDetails1(data);
      print('Data successfully sent.');
    } else {
      print('Failed to send data. Status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Error: $e');
  }
}

Future<void> addNewBillDetails1(List<Map<String, dynamic>> data) async {
  final url = Uri.parse('${baseUrl}/addbilldetails');
  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data), 
    );

    if (response.statusCode == 200) {
      print('Data successfully sent.');
    } else {
      print('Failed to send data. Status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Error: $e');
  }
}

Future<List<TodaySalesByBiller>> fetchTodaySalesData(String today) async {
  final url = Uri.parse('${baseUrl}/todaysales').replace(
    queryParameters: {'date': today},
  );

  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse['status'] == 'S') {
        List<dynamic> data = jsonResponse['totalSale'] ?? [];
        return data.map((item) => TodaySalesByBiller.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load sales data. Status: ${jsonResponse['status']}');
      }
    } else {
      throw Exception('Failed to load sales data. Status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching sales data: $e');
    return []; // Return an empty list on error
  }
}


Future<CurrentInventryValue> fetchCurrentInventryData() async {
  final url = Uri.parse('${baseUrl}/currentInventry');

  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      
      if (jsonResponse['status'] == 'S') {
        return CurrentInventryValue.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to load inventory data. Status: ${jsonResponse['status']}');
      }
    } else {
      throw Exception('Failed to load inventory data. Status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching inventory data: $e');
    rethrow; // Optionally rethrow to handle it at a higher level
  }
}