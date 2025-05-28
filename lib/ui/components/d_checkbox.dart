import 'package:flutter/material.dart';

const dCbDefaultSize = 24.0;
const dCbDefaultContainerSize = 40.0;

class DCheckbox extends StatefulWidget {
  final bool value;
  final void Function(bool? done) onChanged;
  final double size;
  final double containerSize;

  const DCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.size = dCbDefaultSize,
  }) : containerSize = (size * dCbDefaultContainerSize / dCbDefaultSize);

  @override
  State<DCheckbox> createState() => _DCheckboxState();
}

class _DCheckboxState extends State<DCheckbox> {
  bool get isChecked => widget.value;
  double get size => widget.size;
  double get containerSize => widget.containerSize;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: containerSize,
      height: containerSize,
      child: actualCheckbox(),
    );
  }

  Widget actualCheckbox() {
    return IconButton(
      iconSize: size,
      onPressed: () => widget.onChanged(!isChecked),
      icon: Icon(
        isChecked ? Icons.check : Icons.circle_outlined,
      ),
    );
  }
}
