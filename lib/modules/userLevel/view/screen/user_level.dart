import 'package:flutter/material.dart';

import '../../../../core/utils/localization/app_localization.dart';
import '../../../../widgets/custom_app_bar.dart';

class UserLevel extends StatelessWidget {
  const UserLevel({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 20, left: 18, right: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomAppBar(loc: loc, title: loc.translate("user_level_screen_appbar_title"))
          ],
        ),
      ),
    );
  }
}
