import 'package:flutter/material.dart';
import 'package:immo24calculator/factors_page.dart';
import 'package:immo24calculator/values_page.dart';
import 'package:immo24calculator/summary_page.dart';
import 'package:immo24calculator/payment_history_page.dart';
import 'package:provider/provider.dart';
import 'package:immo24calculator/calculations/annuität.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final String title;

  AppScaffold({required this.body, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: body,
    );
  }
}
