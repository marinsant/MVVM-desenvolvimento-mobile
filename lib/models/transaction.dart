import 'package:flutter/material.dart';

class Transaction {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  Transaction({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });
}