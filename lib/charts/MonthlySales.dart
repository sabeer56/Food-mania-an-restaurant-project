import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:http/http.dart' as http;

class Monthlysales extends StatefulWidget {
  @override
  _MonthlysalesState createState() => _MonthlysalesState();
}

class _MonthlysalesState extends State<Monthlysales> {
  late List<ChartData> _chartData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchMonthlySalesData();
  }

  Future<void> _fetchMonthlySalesData() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:9090/monthlyapi'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['status'].isEmpty) {
          final List<dynamic> monthArr = data['montharr'];

          // Debug print the data to verify it
          print('API Data: $monthArr');

          final List<ChartData> chartData = monthArr.map((item) => ChartData(
            item['month'].toString(), // Ensure 'month' is a string
            (item['monthlysale'] as num).toDouble(), // Convert 'monthlysale' to double
          )).toList();

          setState(() {
            _chartData = chartData;
            _isLoading = false;
          });
        } else {
          setState(() {
            _error = data['errmsg'];
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _error = 'Failed to load data';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : _error != null
                ? Text(_error!)
                : Container(
                    padding: EdgeInsets.all(16),
                    child: SfCartesianChart(
                      title: ChartTitle(
                        text: 'Monthly Sales',
                        textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      primaryXAxis: CategoryAxis(
                        title: AxisTitle(
                          text: 'Month',
                          textStyle: TextStyle(
                            color: Colors.blue,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      primaryYAxis: NumericAxis(
                        title: AxisTitle(
                          text: 'Sales',
                          textStyle: TextStyle(
                            color: Colors.blue,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        numberFormat: NumberFormat.compact(), // Ensure proper formatting
                      ),
                      series: <CartesianSeries<ChartData, String>>[
                        ColumnSeries<ChartData, String>(
                          dataSource: _chartData,
                          xValueMapper: (ChartData data, _) => data.x,
                          yValueMapper: (ChartData data, _) => data.y,
                          color: Colors.blue, // You can change the color if needed
                        ),
                      ],
                      tooltipBehavior: TooltipBehavior(enable: true),
                      plotAreaBorderWidth: 0,
                      borderColor: Colors.grey,
                      borderWidth: 1,
                    ),
                  ),
      ),
    );
  }
}

class ChartData {
  ChartData(this.x, this.y);
  final String x; // Month name
  final double y; // Monthly sale
}
