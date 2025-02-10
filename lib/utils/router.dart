

import 'package:flutter/material.dart';

class RouterWidget {
  
  void redirect(String urlName, BuildContext context) {
    Navigator.pushReplacementNamed(context, urlName);
  }

}
