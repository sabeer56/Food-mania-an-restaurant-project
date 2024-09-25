import 'package:csv/csv.dart';

class SalesModel {
  final String billNo;
  final String medicineName;
  final String billDate;
  final int quantity;
  final int netPrice;    

  SalesModel({
    required this.billNo,
    required this.billDate,
    required this.medicineName,
    required this.netPrice,
    required this.quantity,
  });

  factory SalesModel.fromJson(Map<String, dynamic> json) {
    return SalesModel(
      billNo: json['Bill_No'] as String,
      medicineName: json['Medicine_Name'] as String,
      billDate: json['Bill_Date'] as String,
      netPrice: json['netprice'] as int,
      quantity: json['Quantity'] as int,
    );
  }
   // Convert SalesModel to Map
  Map<String, dynamic> toMap() {
    return {
      'bill_no': billNo,
      'bill_date': billDate,
      'medicine_name': medicineName,
      'quantity': quantity,
      'netprice': netPrice,
    };
  }
  
}


class TodaySalesByBiller {
  final double todaytotalsale;
  final String login_id;

  TodaySalesByBiller({
    required this.login_id,
    required this.todaytotalsale,
  });

  factory TodaySalesByBiller.fromJson(Map<String, dynamic> json) {
    return TodaySalesByBiller(
      todaytotalsale: (json['todaytotalsale'] as num).toDouble(),
      login_id: json['login_id'] as String,
    );
  }
}

class CurrentInventryValue {
  int inventryval;

  CurrentInventryValue({required this.inventryval});

  factory CurrentInventryValue.fromJson(Map<String, dynamic> json) {
    return CurrentInventryValue(
      inventryval: json['inventryval'] as int,
    );
  }
}
