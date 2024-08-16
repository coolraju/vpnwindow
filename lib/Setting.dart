import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartersvpn/link.dart';
import 'styling.dart';
import 'Comman.dart';
import 'vpnprotocol.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SettingScreen extends StatefulWidget {
  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  bool isSwitched = false;
  String baseurl = 'https://billing.smartersvpn.com/client-v1';
  List servicedata = [];
  var textValue = 'Switch is OFF';
  String productname = '';
  String expiredate = '';
  String activedevices = '';
  String email = '';

  initState() {
    super.initState();
    _prefs.then((SharedPreferences prefs) {
      setState(() {
        productname = prefs.getString('productname')!;
        expiredate = prefs.getString('next_due_date')!;
        activedevices = prefs.getString('activedevices')!;
        email = prefs.getString('email')!;
      });
    });
  }

  void toggleSwitch(bool value) {
    if (isSwitched == false) {
      setState(() {
        isSwitched = true;
        textValue = 'Switch Button is ON';
      });
      print('Switch Button is ON');
    } else {
      setState(() {
        isSwitched = false;
        textValue = 'Switch Button is OFF';
      });
      print('Switch Button is OFF');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Center(
            child: Text(
              'Settings',
              style: LabelStyle,
            ),
          ),
          // automaticallyImplyLeading: false,
          actions: <Widget>[
            //hide back button
            Theme(
              data: Theme.of(context).copyWith(
                cardColor: const Color.fromARGB(255, 94, 88, 88),
              ),
              child: moreMenu(_prefs, context),
            ),
          ],
        ),
        body: Container(
          width: double.maxFinite,
          margin: EdgeInsets.only(top: 20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  width: double.maxFinite,
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.maxFinite,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 20),
                              child: Text(
                                'Account Details',
                                style: LabelStyle,
                              ),
                            ),
                            SizedBox(height: 20),
                            SizedBox(
                              width: double.maxFinite,
                              child: ListView.separated(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: 4,
                                itemBuilder: (context, index) {
                                  return Container(
                                    height: 55,
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                    child: Row(
                                      children: [
                                        SizedBox(width: 20),
                                        Image.asset(
                                          index == 0
                                              ? 'assets/profile.png'
                                              : index == 1
                                                  ? 'assets/service.png'
                                                  : index == 2
                                                      ? 'assets/smart-devices.png'
                                                      : 'assets/expired.png',
                                          width: 30,
                                          height: 30,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                index == 0
                                                    ? 'Email ID'
                                                    : index == 1
                                                        ? 'Manage Services'
                                                        : index == 2
                                                            ? 'Active Devices'
                                                            : 'Expires On',
                                                style: LabelStyle1,
                                              ),
                                              Text(
                                                index == 0
                                                    ? email
                                                    : index == 1
                                                        ? productname
                                                        : index == 2
                                                            ? activedevices
                                                            : expiredate,
                                                style: LabelStyle2,
                                              ),
                                            ],
                                          ),
                                        ),
                                        index == 3
                                            ? const Spacer()
                                            : Container(),
                                        index == 3
                                            ? Padding(
                                                padding:
                                                    EdgeInsets.only(right: 10),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      '30 Days',
                                                      style: LabelStyle1,
                                                    ),
                                                    Text(
                                                      'remains',
                                                      style: LabelStyle1,
                                                    ),
                                                  ],
                                                ),
                                              )
                                            : Container(),
                                      ],
                                    ),
                                  );
                                },
                                separatorBuilder: (context, index) {
                                  return Divider(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                    height: 10,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  width: double.maxFinite,
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.maxFinite,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 20),
                              child: Text(
                                'VPN Settings',
                                style: LabelStyle,
                              ),
                            ),
                            SizedBox(height: 20),
                            SizedBox(
                              width: double.maxFinite,
                              child: ListView.separated(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: 3,
                                itemBuilder: (context, index) {
                                  return Container(
                                    height: 55,
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                    child: Row(
                                      children: [
                                        SizedBox(width: 20),
                                        Image.asset(
                                          index == 0
                                              ? 'assets/smartphone.png'
                                              : index == 1
                                                  ? 'assets/shield.png'
                                                  : 'assets/link.png',
                                          width: 30,
                                          height: 30,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                index == 0
                                                    ? 'Allowed/Disallowed Apps'
                                                    : index == 1
                                                        ? 'VPN Protocols'
                                                        : 'Network Protection',
                                                style: LabelStyle1,
                                              ),
                                              Text(
                                                index == 0
                                                    ? ''
                                                    : index == 1
                                                        ? 'Automatic'
                                                        : '',
                                                style: LabelStyle2,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Spacer(),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      index == 1
                                                          ? VPNprotocol()
                                                          : LinkScreen()),
                                            );
                                          },
                                          child: Padding(
                                            padding: EdgeInsets.only(right: 10),
                                            child: Image.asset(
                                                'assets/arrow.png',
                                                width: 20,
                                                height: 20),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                separatorBuilder: (context, index) {
                                  return Divider(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                    height: 10,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  width: double.maxFinite,
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.maxFinite,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 20),
                              child: Text(
                                'App Informations',
                                style: LabelStyle,
                              ),
                            ),
                            SizedBox(height: 20),
                            SizedBox(
                              width: double.maxFinite,
                              child: ListView.separated(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: 4,
                                itemBuilder: (context, index) {
                                  return Container(
                                    height: 55,
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                    child: Row(
                                      children: [
                                        SizedBox(width: 20),
                                        Image.asset(
                                          index == 0
                                              ? 'assets/term.png'
                                              : index == 1
                                                  ? 'assets/privacy.png'
                                                  : index == 2
                                                      ? 'assets/theme.png'
                                                      : 'assets/version.png',
                                          width: 30,
                                          height: 30,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                index == 0
                                                    ? 'Terms & Conditions'
                                                    : index == 1
                                                        ? 'Privacy Policy'
                                                        : index == 2
                                                            ? 'Dark Theme'
                                                            : 'App Version',
                                                style: LabelStyle1,
                                              ),
                                              Text(
                                                index == 0
                                                    ? ''
                                                    : index == 1
                                                        ? ''
                                                        : index == 2
                                                            ? ''
                                                            : '1.0.0',
                                                style: LabelStyle2,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Spacer(),
                                        //Switch button
                                        index == 2
                                            ? Switch(
                                                onChanged: toggleSwitch,
                                                value: isSwitched,
                                                activeColor: Colors.blue,
                                                activeTrackColor: Colors.yellow,
                                                inactiveThumbColor:
                                                    Colors.redAccent,
                                                inactiveTrackColor:
                                                    Colors.orange,
                                              )
                                            : Container(),
                                      ],
                                    ),
                                  );
                                },
                                separatorBuilder: (context, index) {
                                  return Divider(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                    height: 10,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
