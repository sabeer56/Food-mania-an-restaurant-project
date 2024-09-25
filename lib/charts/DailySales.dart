import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_charts/charts.dart';

class Dailysales extends StatefulWidget {
  @override
  _DailysalesState createState() => _DailysalesState();
}

class _DailysalesState extends State<Dailysales> {
  List<SalesData> _salesData = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final response = await http.get(Uri.parse('http://localhost:9090/monthlyapi'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      final List<dynamic> dayArr = data['dayarr'];
      final List<SalesData> salesData = dayArr.map((json) {
        return SalesData(json['day'], json['daily'].toDouble());
      }).toList();

      setState(() {
        _salesData = salesData;
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
   
      body: Center(
        child: SfCartesianChart(
          title: ChartTitle(text: 'Daily Sales'),
          legend: Legend(isVisible: true),
          tooltipBehavior: TooltipBehavior(enable: true),
          primaryXAxis: CategoryAxis(
            labelStyle: TextStyle(fontSize: 12),
            majorGridLines: MajorGridLines(width: 0),
            axisLine: AxisLine(width: 0),
          ),
          primaryYAxis: NumericAxis(
            labelStyle: TextStyle(fontSize: 12),
            majorGridLines: MajorGridLines(width: 0.5, color: Colors.grey[300]),
            axisLine: AxisLine(width: 0),
          ),
          series: <LineSeries<SalesData, String>>[
            LineSeries<SalesData, String>(
              dataSource: _salesData,
              xValueMapper: (SalesData sales, _) => sales.day,
              yValueMapper: (SalesData sales, _) => sales.daily,
              markerSettings: MarkerSettings(
                isVisible: true,
                height: 10,
                width: 10,
                shape: DataMarkerType.circle,
                borderWidth: 2,
                borderColor: Colors.blue,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SalesData {
  SalesData(this.day, this.daily);

  final String day;
  final double daily;
}
