import 'package:flutter/material.dart';

import '../utils/colors_code.dart';

class YellowStarBadge extends StatelessWidget {
  const YellowStarBadge({super.key, required this.iconSize});
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: AppColors.pointsScreenPointsIconContainer,
        shape: BoxShape.circle,
      ),
      child: Align(
        alignment: Alignment.center,
        child: Icon(
          Icons.star,
          size: iconSize,
          color: AppColors.pointsScreenPointsIcon,
        ),
      ),
    );
  }
}