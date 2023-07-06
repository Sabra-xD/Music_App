import 'package:flutter/material.dart';

import '../controllers/playercontroller.dart';

PlayxController controller = PlayxController();
Color progressIndicatorColor = Colors.purple.shade300;
var gradientColor1 = controller.setColorDependingOnDay().withOpacity(0.8);
var gradientColor2 = Colors.grey.shade900.withOpacity(0.95);
