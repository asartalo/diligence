// Diligence - A Task Management App
//
// Copyright (C) 2024 Wayne Duran <asartalo@gmail.com>
//
// This program is free software: you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later
// version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with
// this program. If not, see <https://www.gnu.org/licenses/>.

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
        child: Focus(
          onFocusChange: (hasFocus) {
            setState(() {
              _showMoreReveal = hasFocus;
            });
          },
          child: widget.child,
        ),
      ),
    );
  }
}
