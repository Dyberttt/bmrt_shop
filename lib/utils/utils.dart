import 'package:flutter/material.dart';

class Utils {
  static const Color mainThemeColor = Color(0xFF171717);

  static bool validateEmail(String? value) {
    String pattern =
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$";
    RegExp regex = RegExp(pattern);
    return value != null && value.isNotEmpty && regex.hasMatch(value);
  }

  static Widget generateInputField(
    String hintText,
    IconData iconData,
    TextEditingController controller,
    bool isPasswordField,
    Function onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(5),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.grey.withAlpha(51),
        borderRadius: BorderRadius.circular(50),
      ),
      child: TextField(
        onChanged: (text) => onChanged(text),
        obscureText: isPasswordField,
        obscuringCharacter: "*",
        decoration: InputDecoration(
          prefixIcon: Icon(iconData, color: mainThemeColor),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
          hintText: hintText,
        ),
        controller: controller,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  static String getAssetImageForProduct(String productName) {
    final name = productName.toUpperCase();
    
    if (name.contains('G-SHOCK')) {
      if (name.contains('BASIC')) {
        return 'assets/images/gshock_basic.jpeg';
      }
      return 'assets/images/gshock.jpg';
    }
    else if (name.contains('SEIKO')) {
      if (name.contains('SHARP EDGE')) {
        return 'assets/images/seiko2.jpeg';
      }
      return 'assets/images/seiko.jpeg';
    }
    else if (name.contains('FOSSIL')) {
      return 'assets/images/fossil.jpeg';
    }
    else if (name.contains('MICHAEL KORS')) {
      return 'assets/images/mk.jpg';
    }
    else if (name.contains('APPLE')) {
      return 'assets/images/apple.jpeg';
    }
    else if (name.contains('TISSOT')) {
      return 'assets/images/tissot.jpeg';
    }
    else if (name.contains('TIMEX')) {
      if (name.contains('DIGITAL')) {
        return 'assets/images/timex_digital.jpg';
      }
      return 'assets/images/timex.jpeg';
    }
    else if (name.contains('CITIZEN')) {
      return 'assets/images/citizen.jpeg';
    }
    else if (name.contains('EDIFICE')) {
      return 'assets/images/edifice.jpg';
    }
    else if (name.contains('BABY-G')) {
      return 'assets/images/babyg.jpeg';
    }
    
    // Default fallback image
    return 'assets/bmrt.png';
  }
}
