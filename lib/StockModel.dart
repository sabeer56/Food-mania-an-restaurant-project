
class Stock{
   final String medicine_Name;

  final String quantity;
   final    String unit_price;
   final String brand;
  Stock({
    required this.medicine_Name,
  
    required this.quantity,
     required this.unit_price,
      required this.brand,
  });

  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(
      medicine_Name: json['medicine_Name'] as String,
      quantity: json['quantity'] as String,
      unit_price: json['unit_price'] as String,
      brand: json['brand'] as String,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'userId': medicine_Name,
      'quantity': quantity,
      'unit_price': unit_price,
      'brand':brand
    };
  }
}


class AddStock{
   final String medicine_name;

  
   final String brand;
   final String created_by;
  AddStock({
    required this.medicine_name,
      required this.brand,
       required this.created_by,
  });

  factory AddStock.fromJson(Map<String, dynamic> json) {
    return AddStock(
      medicine_name: json['medicine_name'] as String,
      brand: json['brand'] as String,
      created_by: json['created_by'] as String,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'medicine_name': medicine_name,
      'brand':brand,
      'created_by':created_by
    };
  }
}


class UpdateStock{
final String medicine_name;
final String brand;
   final int quantity;
   final int unit_price;
   final String updated_by;
  UpdateStock({
    required this.brand,
    required this.medicine_name,
     required this.quantity,
      required this.unit_price,
       required this.updated_by,
  });

  factory UpdateStock.fromJson(Map<String, dynamic> json) {
    return UpdateStock(
        brand: json['brand'] as String,
      medicine_name: json['medicine_name'] as String,
      unit_price: json['unit_price'] as int,
      quantity: json['quantity'] as int,
      updated_by: json['updated_by'] as String,
    );
  }
  Map<String, dynamic> toJson() {
    return {
       'brand': brand,
      'medicine_name': medicine_name,
         'unit_price':unit_price,
      'quantity':quantity,
      'updated_by':updated_by
    };
  }

}