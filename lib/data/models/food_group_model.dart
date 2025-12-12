import 'package:flutter/material.dart';

class FoodGroup {
  final String id;
  final String name;
  final Color color;
  final bool isChecked;

  FoodGroup({
    required this.id,
    required this.name,
    required this.color,
    this.isChecked = false,
  });

  FoodGroup copyWith({bool? isChecked}) {
    return FoodGroup(
      id: id,
      name: name,
      color: color,
      isChecked: isChecked ?? this.isChecked,
    );
  }
}
