import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TrippyBrandAnimation extends StatefulWidget {
  const TrippyBrandAnimation({Key? key}) : super(key: key);

  @override
  State<TrippyBrandAnimation> createState() => _TrippyBrandAnimationState();
}

class _TrippyBrandAnimationState extends State<TrippyBrandAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _scaleAnim = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnim.value.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: _scaleAnim.value,
            child: child,
          ),
        );
      },
      child: SvgPicture.asset(
        'assets/images/tripyy_logo.svg',
        width: 220,
        fit: BoxFit.contain,
      ),
    );
  }
}
