import 'package:flutter/material.dart';
import 'package:immo24calculator/welcome_page.dart';
import 'package:provider/provider.dart';
import 'package:immo24calculator/calculations/annuität.dart';
import 'factors_page.dart';
import 'values_page.dart';
import 'summary_page.dart';
import 'payment_history_page.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final String title;

  AppScaffold({required this.body, required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 1200),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: body,
          ),
        ),
      ),
    );
  }
}
