import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'vpn.dart';
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String username = '';
  String password = '';
  bool loading = false;
  String baseurl = 'https://billing.smartersvpn.com/client-v1';
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  //init state
  initState() {
    super.initState();
  }

  _connect() async {
    //connect to vpn
    //check user is login
    if (username == '' || password == '') {
      // return error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter username and password'),
        ),
      );
      return;
    }
    //login
    setState(() {
      loading = true;
    });
    var response = await http.post(
      Uri.parse('$baseurl/login'),
      body: {
        'email': username,
        'password': password,
      },
    );
    // print(response.body);
    //parse json response
    Map<String, dynamic> jsonObj = json.decode(response.body);
    if (jsonObj['success'] == true) {
      setState(() {
        loading = false;
      });
      // print(jsonObj['user']);
      //save token
      final SharedPreferences prefs = await _prefs;
      prefs.setString('accesstoken', jsonObj['access_token']);
      prefs.setString('email', jsonObj['user']['email']);
      prefs.setString('name',
          jsonObj['user']['firstname'] + ' ' + jsonObj['user']['lastname']);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => VpnScreen()),
      );
    } else {
      setState(() {
        loading = false;
      });
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
        title: Text('Smarters VPN App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 20),
            TextFormField(
              initialValue: username,
              onChanged: (value) {
                username = value;
              },
              decoration: InputDecoration(
                labelText: 'Username',
              ),
            ),
            TextFormField(
              initialValue: password,
              onChanged: (value) {
                password = value;
              },
              decoration: InputDecoration(
                labelText: 'Password',
              ),
            ),
            ElevatedButton(
              onPressed: _connect,
              child: Text('Login'),
            ),
            SizedBox(height: 20),
            //circle progress
            loading
                ? CircularProgressIndicator()
                : SizedBox(
                    height: 0,
                  ),
          ],
        ),
      ),
    );
  }
}
