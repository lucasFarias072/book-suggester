

import 'package:flutter/material.dart';

class MessageWidget {
  
  void informUser(String txt, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(txt)),
    );
  }

}

