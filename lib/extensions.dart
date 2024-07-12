import 'dart:math';

import 'package:flutter/material.dart';

extension XContext on BuildContext {
  double get preferredScreenSize {
    return min(
      MediaQuery.of(this).size.width,
      MediaQuery.of(this).size.height,
    );
  }
}
