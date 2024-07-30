import 'package:flutter/material.dart';
import 'package:smartersvpn/login.dart';
import 'vpn.dart';
import 'dart:io' show Platform;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {}
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
  @override
  void initState() {
    super.initState();
    //check user is login
    _prefs.then((SharedPreferences prefs) {
      final String? accesstoken = prefs.getString('accesstoken');
      if (accesstoken != null) {
        isLogin = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VPN Connection App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: isLogin ? VpnScreen() : LoginScreen(),
    );
  }
}
