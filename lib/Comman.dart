import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartersvpn/login.dart';

// more menu items
final List<String> menuItems = ['Setting', 'Refresh Servers', 'Logout'];

PopupMenuButton<String> moreMenu(_prefs, context) {
  return PopupMenuButton<String>(
    onSelected: (String result) async {
      // Handle the selected value here
      if (result == 'Setting') {
        print('Setting');
      } else if (result == 'Refresh Servers') {
        print('Refresh Servers');
      } else if (result == 'Logout') {
        //logout user
        final SharedPreferences prefs = await _prefs;
        prefs.remove('accesstoken');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LoginScreen(),
          ),
        );
      }
    },
    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
      for (var item in menuItems)
        PopupMenuItem<String>(
          value: item,
          child: Text(item),
        ),
    ],
  );
}
