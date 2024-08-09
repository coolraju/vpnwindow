// dynamic_colors.dart
import 'package:flutter/material.dart';
import 'theme.dart';

bool _isDarkMode = true;
final containeBoxDecoration = BoxDecoration(
  boxShadow: [
    BoxShadow(
      color: Color.fromRGBO(124, 124, 124, 0.1),
      spreadRadius: 0,
      blurRadius: 57,
      offset: Offset(11.5, 11.5), // changes position of shadow
    ),
  ],
);

final LabelStyle = TextStyle(
  fontSize: 15,
  fontWeight: FontWeight.normal,
  color: _isDarkMode ? Color(0xFFEDEDED) : lightTheme.colorScheme.onPrimary,
);
final LabelStyle1 = TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.normal,
  color: _isDarkMode ? Color(0xFFEDEDED) : lightTheme.colorScheme.onPrimary,
);
final LabelStyle2 = TextStyle(
  fontSize: 10,
  fontWeight: FontWeight.normal,
  color: _isDarkMode ? Color(0xFFEDEDED) : lightTheme.colorScheme.onPrimary,
);
InputDecoration inputBoxDecoration(BuildContext context) {
  return InputDecoration(
    filled: true,
    fillColor:
        Theme.of(context).colorScheme.onPrimary, // Set fill color from theme
    border: OutlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius: BorderRadius.circular(0),
    ),
    // Add shadow if needed
    contentPadding: EdgeInsets.all(16),
    // You can customize the hintText, prefixIcon, etc., if needed
  );
}

ButtonStyle buttonStyle(BuildContext context) {
  return ButtonStyle(
    backgroundColor: MaterialStateProperty.all<Color>(
      _isDarkMode
          ? darkTheme.colorScheme.onSecondary
          : lightTheme.colorScheme.onSecondary,
    ),
    foregroundColor: MaterialStateProperty.all<Color>(
      _isDarkMode
          ? darkTheme.colorScheme.onPrimary
          : lightTheme.colorScheme.onPrimary,
    ),
    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
      EdgeInsets.symmetric(horizontal: 100, vertical: 5),
    ),
    textStyle: MaterialStateProperty.resolveWith<TextStyle>(
      (states) => TextStyle(
        color: _isDarkMode
            ? darkTheme.colorScheme.onSecondary
            : lightTheme.colorScheme.onSecondary,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),
    minimumSize: MaterialStateProperty.all<Size>(Size(500, 60)),
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    ),
  );
}

ButtonStyle buttonStyle2(BuildContext context) {
  return ButtonStyle(
    backgroundColor: MaterialStateProperty.all<Color>(
      _isDarkMode
          ? darkTheme.colorScheme.onPrimary
          : lightTheme.colorScheme.onPrimary,
    ),
    foregroundColor: MaterialStateProperty.all<Color>(
      _isDarkMode
          ? darkTheme.colorScheme.onPrimary
          : lightTheme.colorScheme.onPrimary,
    ),
    textStyle: MaterialStateProperty.resolveWith<TextStyle>(
      (states) => TextStyle(
        color: _isDarkMode
            ? darkTheme.colorScheme.onSecondary
            : lightTheme.colorScheme.onSecondary,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),
    fixedSize: MaterialStateProperty.all<Size>(Size(165, 60)),
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    ),
  );
}

ButtonStyle buttonStyle3(BuildContext context) {
  return ButtonStyle(
    backgroundColor: MaterialStateProperty.all<Color>(
      _isDarkMode
          ? darkTheme.colorScheme.onSecondary
          : lightTheme.colorScheme.onSecondary,
    ),
    foregroundColor: MaterialStateProperty.all<Color>(
      _isDarkMode
          ? darkTheme.colorScheme.onPrimary
          : lightTheme.colorScheme.onPrimary,
    ),
    textStyle: MaterialStateProperty.resolveWith<TextStyle>(
      (states) => TextStyle(
        color: _isDarkMode
            ? darkTheme.colorScheme.onSecondary
            : lightTheme.colorScheme.onSecondary,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
      ),
    ),
  );
}
