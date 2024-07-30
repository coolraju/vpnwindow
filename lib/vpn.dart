import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smartersvpn/servicedetails.dart';

class VpnScreen extends StatefulWidget {
  @override
  _VpnScreenState createState() => _VpnScreenState();
}

class _VpnScreenState extends State<VpnScreen> {
  String? _configFilePath;
  Process? _vpnProcess;
  String _log = '';
  String baseurl = 'https://billing.smartersvpn.com/client-v1';
  List services = [];
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  //init state
  initState() {
    super.initState();
    _prefs.then((SharedPreferences prefs) {
      getServices(prefs);
    });
  }

  getServices(prefs) async {
    //get services
    var response = await http.get(
      Uri.parse('$baseurl/services'),
      headers: {
        'Authorization': 'Bearer ' + prefs.getString('accesstoken'),
      },
    );
    //parse json response
    Map<String, dynamic> jsonObj = json.decode(response.body);
    if (jsonObj['success'] == true) {
      setState(() {
        services = jsonObj['services']['data'];
        print(services);
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
            //list of services
            Expanded(
              child: ListView.builder(
                itemCount: services.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(services[index]['products']['title']),
                    subtitle: Text("Status: " + services[index]['status']),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ServiceDetailScreen(service: services[index]),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null) {
        setState(() {
          _configFilePath = result.files.single.path;
        });
      } else {
        // User canceled the picker
      }
    } catch (e) {
      print('Failed to pick file: $e');
    }
  }
}
