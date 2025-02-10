import 'package:flutter/material.dart';

class Paint {
  
  Color getInk(String label) {
    if (label == 'index_page_form') {
      return const Color.fromARGB(255, 200, 200, 0);
    }
    return const Color.fromARGB(255, 255, 255, 255);
  }
}
