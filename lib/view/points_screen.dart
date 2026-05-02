import 'package:flutter/material.dart';
import 'package:trippy_customer/core/utils/localization/app_localization.dart';
import 'package:trippy_customer/widgets/custom_appBar.dart';

class PointsScreen extends StatelessWidget {
  const PointsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [CustomAppBar(loc: loc, title: "Points")],
          ),
        ),
      ),
    );
  }
}
