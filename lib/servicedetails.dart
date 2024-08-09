import 'package:flutter/material.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'styling.dart';
import 'Comman.dart';

class ServiceDetailScreen extends StatefulWidget {
  final service;
  ServiceDetailScreen({Key? key, required this.service}) : super(key: key);
  @override
  _ServiceDetailScreenState createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  String? _configFilePath;
  Process? _vpnProcess;
  String username = '';
  String password = '';
  String _log = '';
  bool isconnected = false;
  String loading = 'Fetching service detail...';
  String baseurl = 'https://billing.smartersvpn.com/client-v1';
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  //init state
  initState() {
    super.initState();
    _prefs.then((SharedPreferences prefs) {
      getServiceDetail(prefs);
    });
  }

  getServiceDetail(prefs) async {
    loading = 'Loading...';
    //get service detail
    print(prefs.getString('accesstoken'));
    var response = await http.get(
      Uri.parse(
          '$baseurl/addon-modules/smartersvpn?action=getservice&serviceid=${widget.service['id']}&userid=${widget.service['user_id']}'),
      headers: {
        'Authorization': 'Bearer ' + prefs.getString('accesstoken'),
      },
    );
    // print(response.body);
    //parse json response
    Map<String, dynamic> jsonObj = json.decode(response.body);
    // print("Loading111..");
    if (jsonObj['success'] == true) {
      username = widget.service['username'];
      password = widget.service['password'];
      // print("serviceovpn");
      // print(jsonObj['service']['server'][0]);
      //create config file in temp directory
      String ovpncontent = jsonObj['service']['server'][0]['ovpn'];
      Directory tempDir = Directory.systemTemp;
      // print('${tempDir.path}\\${widget.service['id']}.ovpn');
      File file = File('${tempDir.path}\\${widget.service['id']}.ovpn');
      await file.writeAsString(ovpncontent);
      setState(() {
        loading = 'Service detail loaded. Click connect to connect VPN.';
      });
    } else {
      // return error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(jsonObj['message']),
        ),
      );
    }
  }

  void _connectVpn() async {
    _log = '';

    try {
      // previous connections
      // _vpnProcess?.kill();
      // get temp directory
      Directory tempDir = Directory.systemTemp;
      // Save username and password to a file for OpenVPN
      File file = File('${tempDir.path}\\auth.txt');
      await file.writeAsString('$username\n$password');
      _configFilePath = '${tempDir.path}\\${widget.service['id']}.ovpn';
      print(_configFilePath);
      //run as admin openvpn
      // check if device is windows or macos
      if (Platform.isWindows) {
        _vpnProcess = await Process.start(
          'openvpn',
          [
            '--config',
            _configFilePath!,
            '--auth-user-pass',
            tempDir.path + '\\auth.txt'
          ],
          runInShell: true,
        );

        _vpnProcess?.stdout.transform(SystemEncoding().decoder).listen((data) {
          setState(() {
            isconnected = true;
            _log += data;
          });
        });

        _vpnProcess?.stderr.transform(SystemEncoding().decoder).listen((data) {
          setState(() {
            _log += data;
          });
        });
      } else if (Platform.isMacOS) {
        setState(() {
          _log += 'Mac Detected\n';
        });
      }

      setState(() {
        _log += 'Connecting to VPN...\n';
      });
    } catch (e) {
      setState(() {
        _log += 'Failed to start OpenVPN process: $e\n';
      });
    }
  }

  void _disconnectVpn() async {
    _vpnProcess?.kill();
    await Process.start('taskkill', ['/F', '/IM', 'openvpn.exe']);
    setState(() {
      _log += 'Disconnected from VPN.\n';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('VPN Connection App'),
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(height: 20),
              Image.asset('assets/logo.png', width: 200),
              SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Text('Connected Time', style: LabelStyle)],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('00:00:00',
                      style: TextStyle(fontSize: 30, color: Colors.white)),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Lodon Server', style: LabelStyle),
                ],
              ),
              SizedBox(height: 20),
              //big circular button
              GestureDetector(
                onTap: () {
                  if (isconnected == true) {
                    _disconnectVpn();
                    setState(() {
                      isconnected = false;
                    });
                    return;
                  }
                  _configFilePath = '';
                  _connectVpn();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 50),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.onPrimary,
                      style: BorderStyle.solid,
                      width: 5.0,
                    ),
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 5),
                      Image.asset('assets/start.png'),
                      SizedBox(height: 10),
                      Text('Tap to connect',
                          style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //dropdown of servers list
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    decoration: BoxDecoration(
                      // borderRadius: BorderRadius.circular(15.0),
                      border: Border.all(
                          // color: Theme.of(context).colorScheme.onPrimary,
                          style: BorderStyle.solid,
                          width: 0.80),
                    ),
                    width: 350,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton(
                        isExpanded: true,
                        items: [
                          DropdownMenuItem(
                            child: Text('Server 1'),
                            value: 1,
                          ),
                          DropdownMenuItem(
                            child: Text('Server 2'),
                            value: 2,
                          ),
                          DropdownMenuItem(
                            child: Text('Server 3'),
                            value: 3,
                          ),
                        ],
                        onChanged: (value) {},
                        value: 1,
                      ),
                    ),
                  ),
                ],
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  //text butotn
                  TextButton(
                    onPressed: () {},
                    child: Text('Resent Location', style: LabelStyle),
                  ),
                  SizedBox(width: 20),
                  //text butotn
                  TextButton(
                    onPressed: () {},
                    child: Text('Smarter Location', style: LabelStyle),
                  ),
                ],
              ),

              // Text('Product Name: ${widget.service['products']['title']}',
              //     style: LabelStyle),
              // Text('Service Type: ${widget.service['period']}',
              //     style: LabelStyle),
              // Text('Service Status: ${widget.service['status']}',
              //     style: LabelStyle),
              // Text('Service Created At: ${widget.service['created_at']}',
              //     style: LabelStyle),
              // Text('Service Updated At: ${widget.service['updated_at']}',
              //     style: LabelStyle),
              //circle button to connect
              // ElevatedButton(
              //   onPressed: () {
              //     _configFilePath = '';
              //     _connectVpn();
              //   },
              //   child: Text('Connect', style: LabelStyle),
              // ),
              // isconnected == true
              //     ? (ElevatedButton(
              //         onPressed: () {
              //           _disconnectVpn();
              //         },
              //         child: Text('Disconnect', style: LabelStyle)))
              //     : SizedBox(height: 0),
              //show logs
              Text('Status: ' + loading, style: LabelStyle),
              // Expanded(
              //   child: SingleChildScrollView(
              //     child: Text(_log, style: LabelStyle),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
