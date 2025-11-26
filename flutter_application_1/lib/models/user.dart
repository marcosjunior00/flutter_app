import 'package:flutter/material.dart';

class User {
  int? id;
  String name;
  String email;
  String? password; // hash da senha
  String? phone;
  int avatarColor; // cor armazenada como int (value)

  User({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    this.phone,
    required this.avatarColor,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      name: map['name'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
      phone: map['phone'] as String?,
      avatarColor: map['avatar_color'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'avatar_color': avatarColor,
    };
  }

  Color get avatarColorAsColor {
    return Color(avatarColor);
  }
}

