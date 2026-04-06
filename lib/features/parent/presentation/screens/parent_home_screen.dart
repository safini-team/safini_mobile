import 'package:flutter/material.dart';
import 'package:safini/generated/l10n.dart';

class ParentHomeScreen extends StatelessWidget {
  const ParentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text(S.of(context).parentHomeScreen)));
  }
}
