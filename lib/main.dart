import 'package:flutter/material.dart';
import 'package:safini/screens/common/core/app/app.dart';
import 'package:safini/screens/common/core/di/injection.dart';

void main() {
  configureDependencies();
  runApp(const MyApp());
}