import 'dart:async';
import 'package:flutter/foundation.dart';

VoidCallback debounce(VoidCallback fn, {int milliseconds = 10}) {
  Timer? timer;
  return () {
    if (timer?.isActive ?? false) timer?.cancel();
    timer = Timer(Duration(milliseconds: milliseconds), fn);
  };
}
