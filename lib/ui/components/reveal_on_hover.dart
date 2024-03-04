import 'package:flutter/material.dart';

class RevealOnHover extends StatefulWidget {
  final Widget child;
  final double hiddenOpacity;
  final bool revealByDefault;

  const RevealOnHover({
    super.key,
    required this.child,
    this.hiddenOpacity = 0.5,
    this.revealByDefault = false,
  });

  @override
  State<RevealOnHover> createState() => _RevealOnHoverState();
}

class _RevealOnHoverState extends State<RevealOnHover> {
  late bool _showMoreReveal;

  @override
  void initState() {
    super.initState();
    _showMoreReveal = false;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) {
        setState(() {
          _showMoreReveal = true;
        });
      },
      onExit: (event) {
        setState(() {
          _showMoreReveal = false;
        });
      },
      child: AnimatedOpacity(
        opacity: widget.revealByDefault || _showMoreReveal
            ? 1.0
            : widget.hiddenOpacity,
        duration: const Duration(milliseconds: 200),
        child: widget.child,
      ),
    );
  }
}
