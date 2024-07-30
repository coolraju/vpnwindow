import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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
    print("Loading111..");
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Service Detail'),
            Text('Product Name: ${widget.service['products']['title']}'),
            Text('Service Type: ${widget.service['period']}'),
            Text('Service Status: ${widget.service['status']}'),
            Text('Service Created At: ${widget.service['created_at']}'),
            Text('Service Updated At: ${widget.service['updated_at']}'),
            //circle button to connect
            ElevatedButton(
              onPressed: () {
                _configFilePath = '';
                _connectVpn();
              },
              child: Text('Connect'),
            ),
            isconnected == true
                ? (ElevatedButton(
                    onPressed: () {
                      _disconnectVpn();
                    },
                    child: Text('Disconnect')))
                : SizedBox(height: 0),
            //show logs
            Text('Status: ' + loading),
            Expanded(
              child: SingleChildScrollView(
                child: Text(_log),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
