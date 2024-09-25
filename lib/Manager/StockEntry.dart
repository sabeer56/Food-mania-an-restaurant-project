import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medapp/LoginModel.dart';
import 'package:medapp/Manager/StockView.dart';
import 'package:medapp/StockModel.dart';
import 'package:medapp/Repositary.dart' as repo;

class StockEntry extends StatefulWidget {
  final User currentuser;

  StockEntry({required this.currentuser});

  @override
  StockEntryPage createState() => StockEntryPage();
}

class StockEntryPage extends State<StockEntry> {
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  String? _selectedCategory;
  String? _selectedMedicineName;
  String? _selectedMedicineBrand;
  late Future<List<Map<String, dynamic>>> _categories;

  @override
  void initState() {
    super.initState();
    _categories = _fetchCategories(); // Fetch categories on initialization
  }

  Future<List<Map<String, dynamic>>> _fetchCategories() async {
    try {
      final List<dynamic> rawStock = await repo.fetchStockDetails();
      return rawStock.map((item) => item as Map<String, dynamic>).toSet().toList();
    } catch (e) {
      print('Error fetching stock details: $e');
      return [];
    }
  }

  Future<void> _updateStockDetails(BuildContext context) async {
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a category.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    final parts = _selectedCategory!.split('/');
    _selectedMedicineName = parts[0];
    _selectedMedicineBrand = parts[1];

    final quantity = int.tryParse(_quantityController.text) ?? 0;
    final price = int.tryParse(_priceController.text) ?? 0;

    if (quantity < 0 || price < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Enter valid quantity and price.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    final newStock = UpdateStock(
      brand:_selectedMedicineBrand!,
      medicine_name: _selectedMedicineName!,
      quantity: quantity,
      unit_price: price,
      updated_by: widget.currentuser.userId,
    );

    try {
      await repo.updateNewStockDetails(context, newStock);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Stock updated successfully.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
        Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StockEntry(currentuser: widget.currentuser)),
                );
    } catch (e) {
      print('Error updating stock details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update stock.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _updateFields(Map<String, dynamic> stock) {
    setState(() {
      _selectedMedicineName = stock['medicine_name'];
      _quantityController.text = stock['quantity'].toString();
      _priceController.text = stock['unit_price'].toString();
      _brandController.text = stock['brand'].toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: FaIcon(FontAwesomeIcons.home, size: 15),
          ),
        ],
        backgroundColor: Color.fromRGBO(45, 40, 192, 1),
      ),
      body: Column(
        children: [
          Stack(
            children: [
              // Purple Container
              Container(
                width: double.infinity,
                height: screenHeight * 0.4,
                color: Color.fromRGBO(45, 40, 192, 1),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/form1.png',
                      width: 250,
                      height: 180,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),
              // Amber Container with Curve
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: ClipPath(
                  clipper: CustomClipPath(),
                  child: Container(
                    width: screenWidth,
                    height: 60,
                    color: Colors.amber,
                  ),
                ),
              ),
              // Button Positioned
              Positioned(
                bottom: 40.0,
                left: 16.0,
                right: 16.0,
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AddStockDialog(currentuser: widget.currentuser);
                      },
                    );
                  },
                  child: Text('Add Stock'),
                ),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  FutureBuilder<List<Map<String, dynamic>>>(
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
                          items: snapshot.data!.map((Map<String, dynamic> stock) {
                            return DropdownMenuItem<String>(
                              value: '${stock['medicine_name']}/${stock['brand']}',
                              child: Text('${stock['medicine_name']} (Brand: ${stock['brand']})'),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedCategory = newValue;
                              if (newValue != null) {
                                final parts = newValue.split('/');
                                _selectedMedicineName = parts[0];
                                _selectedMedicineBrand = parts[1];
                 final selectedStock = snapshot.data!.firstWhere(
          (stock) =>
              stock['medicine_name'].toString().toLowerCase() ==
                  _selectedMedicineName!.toLowerCase() &&
              stock['brand'].toString().toLowerCase() ==
                  _selectedMedicineBrand!.toLowerCase(),
          orElse: () => <String, dynamic>{},
        );
        print(selectedStock);
                                  _updateFields(selectedStock);
                                
                              }
                            });
                          },
                          decoration: InputDecoration(
                            labelText: 'Category',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                          ),
                        );
                      }
                    },
                  ),
                  SizedBox(height: 16.0),
                  TextField(
                    controller: _brandController,
                    decoration: InputDecoration(
                      labelText: 'Enter The Brand',
                      prefixIcon: Icon(Icons.branding_watermark),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromRGBO(45, 40, 192, 1),
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1.0),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  TextField(
                    controller: _quantityController,
                    decoration: InputDecoration(
                      labelText: 'Enter The Quantity',
                      prefixIcon: Icon(Icons.confirmation_number),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromRGBO(45, 40, 192, 1),
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1.0),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 16.0),
                  TextField(
                    controller: _priceController,
                    decoration: InputDecoration(
                      labelText: 'Enter The Price',
                      prefixIcon: Icon(Icons.monetization_on),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromRGBO(45, 40, 192, 1),
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1.0),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                  ),
                  SizedBox(height: 16.0),
                  Container(
                    width: 80,
                    height: 28,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Color.fromRGBO(45, 40, 192, 1),
                    ),
                    child: TextButton(
                      onPressed: () => _updateStockDetails(context),
                      child: Text(
                        'Update',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomClipPath extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 20);
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height - 20);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class AddStockDialog extends StatefulWidget {
  final User currentuser;

  AddStockDialog({required this.currentuser});

  @override
  AddStockDialogPage createState() => AddStockDialogPage();
}

class AddStockDialogPage extends State<AddStockDialog> {
  final TextEditingController medicineNameController = TextEditingController();
  final TextEditingController brandController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late Future<List<dynamic>> _stocks;

  @override
  void initState() {
    super.initState();
    _stocks = _fetchLogDetails(); // Fetch stocks on initialization
  }

  Future<List<dynamic>> _fetchLogDetails() async {
    try {
      return await repo.fetchStockDetails();
    } catch (e) {
      print('Error fetching log details: $e');
      return [];
    }
  }

  Future<bool> handleAddStock() async {
    try {
      final stockList = await _stocks;
      bool exists = stockList.any((ele) => 
          ele['brand'].toString().toLowerCase() == brandController.text.toString().toLowerCase() && 
          ele['medicine_name'].toString().toLowerCase() == medicineNameController.text.toString().toLowerCase());

      if (!exists) {
        AddStock newStock = AddStock(
          medicine_name: medicineNameController.text,
          brand: brandController.text,
          created_by: widget.currentuser.userId,
        );
        await repo.addNewStockDetails(newStock);
        return true; // Successfully added
      } else {
        return false; // Stock already exists
      }
    } catch (e) {
      print(e);
      return false; // Error occurred
    }
  }

  void _submitForm(BuildContext context) async {
    if (formKey.currentState?.validate() ?? false) {
      bool success = await handleAddStock();

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Stock added successfully.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
       Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StockEntry(currentuser: widget.currentuser)),
                );

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Stock already exists or failed to add.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please correct the errors before submitting.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _cancel(BuildContext context) {
    Navigator.of(context).pop(); // Close the dialog
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add New Stock'),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: medicineNameController,
              decoration: InputDecoration(
                labelText: 'Medicine Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter the medicine name.';
                }
                if (RegExp(r'^\d').hasMatch(value.trim())) {
                  return 'Field cannot start with a number.';
                }
                if (RegExp(r'^[\s.]*$').hasMatch(value.trim())) {
                  return 'Field cannot contain only spaces or dots.';
                }
                if (RegExp(r'[^a-zA-Z0-9\s]').hasMatch(value.trim())) {
                  return 'Field cannot contain special characters.';
                }
                return null;
              },
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: brandController,
              decoration: InputDecoration(
                labelText: 'Brand Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter the brand name.';
                }
                if (RegExp(r'^\d').hasMatch(value.trim())) {
                  return 'Field cannot start with a number.';
                }
                if (RegExp(r'^[\s.]*$').hasMatch(value.trim())) {
                  return 'Field cannot contain only spaces or dots.';
                }
                if (RegExp(r'[^a-zA-Z0-9\s]').hasMatch(value.trim())) {
                  return 'Field cannot contain special characters.';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => _cancel(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => _submitForm(context),
          child: Text('Add Stock'),
        ),
      ],
    );
  }
}
