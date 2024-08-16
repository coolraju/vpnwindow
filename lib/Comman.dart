import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartersvpn/login.dart';
import 'Setting.dart';
import 'styling.dart';
import 'servers.dart';

// more menu items
final List<String> menuItems = ['Setting', 'Refresh Servers', 'Logout'];

PopupMenuButton<String> moreMenu(_prefs, context) {
  return PopupMenuButton<String>(
    onSelected: (String result) async {
      // Handle the selected value here
      if (result == 'Setting') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SettingScreen(),
          ),
        );
      } else if (result == 'Refresh Servers') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ServersScreen(),
          ),
        );
      } else if (result == 'Logout') {
        //confirm alert dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Logout', style: LabelStyle),
              content:
                  Text('Are you sure you want to logout?', style: LabelStyle),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel', style: TextStyle(color: Colors.red)),
                ),
                TextButton(
                  onPressed: () async {
                    //logout user
                    final SharedPreferences prefs = await _prefs;
                    prefs.remove('accesstoken');
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginScreen(),
                      ),
                    );
                  },
                  child: Text('Logout', style: TextStyle(color: Colors.red)),
                ),
              ],
            );
          },
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

// more menu items
final List<String> menuItems1 = ['Logout'];

PopupMenuButton<String> moreMenu1(_prefs, context) {
  return PopupMenuButton<String>(
    onSelected: (String result) async {
      //confirm alert dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Logout', style: LabelStyle),
            content:
                Text('Are you sure you want to logout?', style: LabelStyle),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancel', style: TextStyle(color: Colors.red)),
              ),
              TextButton(
                onPressed: () async {
                  //logout user
                  final SharedPreferences prefs = await _prefs;
                  prefs.remove('accesstoken');
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginScreen(),
                    ),
                  );
                },
                child: Text('Logout', style: TextStyle(color: Colors.red)),
              ),
            ],
          );
        },
      );
    },
    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
      for (var item in menuItems1)
        PopupMenuItem<String>(
          value: item,
          child: Text(item),
        ),
    ],
  );
}
