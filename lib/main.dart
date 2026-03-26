import 'package:flutter/material.dart';
import 'package:safini/core/app/app.dart';
import 'package:safini/core/di/injection.dart';

void main() {
  configureDependencies();
  runApp(const MyApp());
}