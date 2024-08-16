import 'package:flutter/material.dart';
import 'package:smartersvpn/login.dart';
import 'vpn.dart';
import 'dart:io' show Platform;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:desktop_window/desktop_window.dart';
import 'theme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    DesktopWindow.setWindowSize(const Size(500, 900));
    //disable maximize button
    DesktopWindow.setMinWindowSize(const Size(500, 900));
  }
  await dotenv.load(fileName: "assets/.env");
  runApp(SmarterVPNConnect());
}

class SmarterVPNConnect extends StatefulWidget {
  const SmarterVPNConnect({super.key});
  @override
  _SmarterVPNConnectState createState() => _SmarterVPNConnectState();
}

class _SmarterVPNConnectState extends State<SmarterVPNConnect> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  bool isLogin = false;
  final bool _isDarkMode = true;
  @override
  void initState() {
    super.initState();
    //check user is login
    _prefs.then((SharedPreferences prefs) {
      final String? accesstoken = prefs.getString('accesstoken');
      if (accesstoken != null) {
        setState(() {
          isLogin = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smarter VPN app',
      theme: _isDarkMode ? darkTheme : lightTheme,
      home: isLogin ? VpnScreen() : LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
