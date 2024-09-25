class LoginModel {
  final String userId;
  final String password;
  final String role;
       String? type;
  LoginModel({
    required this.userId,
    required this.password,
    required this.role,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      userId: json['userId'] as String,
      password: json['password'] as String,
      role: json['role'] as String,
    );
  }
}

class User{
    final String userId;

  final String role;
   final    String type;
  User({
    required this.userId,
  
    required this.role,
     required this.type,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'] as String,
      type: json['type'] as String,
      role: json['role'] as String,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'role': role,
      'type': type,
    };
  }
}



class UserLogDetails {
  final int id;
  final String userId;
  final String type;
  final String role;
  final String loginTime;
  final String loginDate;
  final String logoutTime;
  final String logoutDate;

  UserLogDetails({
     required this.id,
    required this.userId,
    required this.type,
    required this.role,
    required this.loginTime,
    required this.loginDate,
    required this.logoutTime,
    required this.logoutDate,
  });

  factory UserLogDetails.fromJson(Map<String, dynamic> json) {
    return UserLogDetails(
        id: json['id'] ,
      userId: json['Userid'] ?? '',
      type: json['Type'] ?? '',
      role: json['Role'] ?? '',
      loginTime: json['login_time'] ?? '',
      loginDate: json['login_date'] ?? '',
      logoutTime: json['logout_time'] ?? '',
      logoutDate: json['logout_date'] ?? '',
    );
  }
    Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'role': role,
      'type': type,
      'loginTime':loginTime,
      'loginDate':loginDate,
      'logoutTime':logoutTime,
      'logoutDate':logoutDate
    };
  }
}


class AddUser{
    final String userId;

  final String role;
   final    String password;
   final String created_By;
  AddUser({
    required this.userId,
  
    required this.role,
     required this.password,
      required this.created_By,
  });

  factory AddUser.fromJson(Map<String, dynamic> json) {
    return AddUser(
      userId: json['userId'] as String,
      password: json['password'] as String,
      role: json['role'] as String,
      created_By: json['created_By'] as String,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'role': role,
      'password': password,
      'created_By':created_By
    };
  }
}
