import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:http/http.dart' as http;

class Monthlysalesbybiller extends StatefulWidget {
  @override
  _MonthlysalesbybillerState createState() => _MonthlysalesbybillerState();
}

class _MonthlysalesbybillerState extends State<Monthlysalesbybiller> {
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
      final response = await http.get(Uri.parse('http://localhost:9090/todaysales?date=2024-08-30'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['status'] == 'S') {
          final List<dynamic> monthlySales = data['monthlysales'];

          // Debug print the data to verify it
          print('API Data: $monthlySales');

          final List<ChartData> chartData = monthlySales.map((item) => ChartData(
            item['login_id'].toString(), // Convert 'login_id' to string
            (item['monthlytotalsale'] as num).toDouble(), // Convert 'monthlytotalsale' to double
            0,  // Placeholder values for additional series
            0,  // Placeholder values for additional series
            0,  // Placeholder values for additional series
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
                        text: 'Monthly Sales By Biller',
                        textStyle: TextStyle(
                          color: Colors.blue,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      primaryXAxis: CategoryAxis(
                        labelStyle: TextStyle(
                          color: Colors.blue,
                          fontSize: 12,
                        ),
                      ),
                      primaryYAxis: NumericAxis(
                        title: AxisTitle(
                          text: 'Monthly Sales',
                          textStyle: TextStyle(
                            color: Colors.blue,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        labelFormat: '{value}',
                      ),
                      series: <CartesianSeries<ChartData, String>>[
                        StackedColumnSeries<ChartData, String>(
                          dataLabelSettings: DataLabelSettings(
                            isVisible: true,
                            showCumulativeValues: true,
                          ),
                          dataSource: _chartData,
                          xValueMapper: (ChartData data, _) => data.x,
                          yValueMapper: (ChartData data, _) => data.y1,
                          color: Colors.blue,
                          name: 'Biller 1',
                        ),
                        StackedColumnSeries<ChartData, String>(
                          dataLabelSettings: DataLabelSettings(
                            isVisible: true,
                            showCumulativeValues: true,
                          ),
                          dataSource: _chartData,
                          xValueMapper: (ChartData data, _) => data.x,
                          yValueMapper: (ChartData data, _) => data.y2,
                          color: Colors.green,
                          name: 'Biller 2',
                        ),
                        StackedColumnSeries<ChartData, String>(
                          dataLabelSettings: DataLabelSettings(
                            isVisible: true,
                            showCumulativeValues: true,
                          ),
                          dataSource: _chartData,
                          xValueMapper: (ChartData data, _) => data.x,
                          yValueMapper: (ChartData data, _) => data.y3,
                          color: Colors.red,
                          name: 'Biller 3',
                        ),
                        StackedColumnSeries<ChartData, String>(
                          dataLabelSettings: DataLabelSettings(
                            isVisible: true,
                            showCumulativeValues: true,
                          ),
                          dataSource: _chartData,
                          xValueMapper: (ChartData data, _) => data.x,
                          yValueMapper: (ChartData data, _) => data.y4,
                          color: Colors.orange,
                          name: 'Biller 4',
                        ),
                      ],
                      plotAreaBorderWidth: 0,
                      legend: Legend(isVisible: true),
                      tooltipBehavior: TooltipBehavior(enable: true),
                    ),
                  ),
      ),
    );
  }
}

class ChartData {
  ChartData(this.x, this.y1, this.y2, this.y3, this.y4);
  final String x; // Biller's email
  final double y1; // Monthly total sale
  final double y2; // Placeholder for additional series
  final double y3; // Placeholder for additional series
  final double y4; // Placeholder for additional series
}
