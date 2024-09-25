import 'dart:convert'; // Import this to parse JSON
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:http/http.dart' as http; // Import this to make HTTP requests

class TodaySalesByBillerChart extends StatefulWidget {
  @override
  TodaySalesByBillerChartPage createState() => TodaySalesByBillerChartPage();
}

class TodaySalesByBillerChartPage extends State<TodaySalesByBillerChart> {
  DateTime date = DateTime.now(); 
  List<_PieData> pieData = []; // List to hold dynamic data

  @override
  void initState() {
    super.initState();
    handleTodaySalesByBiller();
  }

  Future<void> handleTodaySalesByBiller() async {
    try {
      // Construct the URL with the date parameter
      final String url = 'http://localhost:9090/todaysales?date=${DateFormat('yyyy-MM-dd').format(date)}';
      
      // Make an HTTP GET request
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        // Parse the JSON response
        final Map<String, dynamic> data = json.decode(response.body);

        // Check if the status is "S" (success)
        if (data['status'] == 'S') {
          // Extract monthly sales data
          final List<dynamic> monthlySales = data['totalSale'];
          
          // Convert the extracted data into _PieData format
          List<_PieData> pieDataList = monthlySales.map((item) => _PieData(
            item['login_id'],  // Assuming 'login_id' is the biller name
            item['todaytotalsale'].toDouble(), // Assuming 'monthlytotalsale' is the sale amount
            '${item['login_id']}: ${item['todaytotalsale']}',
          )).toList();

          setState(() {
            pieData = pieDataList;
          });
        } else {
          // Handle the case where status is not "S"
          print('Error: Status is not "S"');
        }
      } else {
        // Handle HTTP errors
        print('Error: Failed to fetch data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SfCircularChart(
        title: ChartTitle(text: 'Today Sales By Billers'),
        legend: Legend(isVisible: true),
        series: <PieSeries<_PieData, String>>[
          PieSeries<_PieData, String>(
            explode: true,
            explodeIndex: 0,
            dataSource: pieData,
            xValueMapper: (_PieData data, _) => data.xData,
            yValueMapper: (_PieData data, _) => data.yData,
            dataLabelMapper: (_PieData data, _) => data.text,
            dataLabelSettings: DataLabelSettings(isVisible: true),
          ),
        ],
      ),
    );
  }
}

class _PieData {
  _PieData(this.xData, this.yData, [this.text]);
  final String xData;
  final num yData;
  String? text;
}
