import 'package:flutter/material.dart';

class TimelineTile extends StatelessWidget {
  final Widget icon;
  final Widget child;
  final bool isLast;

  const TimelineTile({
    super.key,
    required this.icon,
    required this.child,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            icon,

            // 👇 dotted vertical line
            if (!isLast)
              Column(
                children: List.generate(
                  8,
                  (index) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Container(
                      width: 2,
                      height: 3,
                      color: Colors.grey.shade300,
                    ),
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(width: 10),

        Expanded(child: child),
      ],
    );
  }
}