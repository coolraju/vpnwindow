import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'vpn.dart';
import 'dart:convert';
import 'styling.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String username = '';
  String password = '';
  bool loading = false;
  bool hidePassword = false;
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
      // appBar: AppBar(
      //   title: Text('Smarters VPN App'),
      // ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(height: 40),
              Image.asset('assets/logo.png', width: 250),
              SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 0, 5),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Email',
                        style: LabelStyle,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                  child: TextFormField(
                    initialValue: username,
                    onChanged: (value) {
                      username = value;
                    },
                    decoration: inputBoxDecoration(context),
                  ),
                  decoration: containeBoxDecoration),

              Padding(
                padding: const EdgeInsets.fromLTRB(10, 20, 0, 5),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Password',
                        style: LabelStyle,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                  decoration: containeBoxDecoration,
                  child: TextFormField(
                      initialValue: password,
                      obscureText: hidePassword,
                      onChanged: (value) {
                        password = value;
                      },
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          icon: Icon(hidePassword == true
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              hidePassword = !hidePassword;
                            });
                          },
                        ),
                        filled: true,
                        fillColor: Theme.of(context)
                            .colorScheme
                            .onPrimary, // Set fill color from theme
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(0),
                        ),
                        // Add shadow if needed
                        contentPadding: EdgeInsets.all(16),
                        // You can customize the hintText, prefixIcon, etc., if needed
                      ))),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(0),
                child: Column(
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          _connect();
                        },
                        child: Text('Login', style: LabelStyle),
                        style: buttonStyle(context)),
                  ],
                ),
              ),
              SizedBox(height: 20),
              //circle progress
              loading
                  ? CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.onPrimary),
                    )
                  : SizedBox(
                      height: 0,
                    ),
              Container(
                child: Text(
                  '----------- or continue with -----------',
                  style: LabelStyle,
                ),
              ),
              SizedBox(height: 20),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      child: Text('Google', style: LabelStyle),
                      style: buttonStyle2(context),
                    ),
                    SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () {},
                      child: Text('Facebook', style: LabelStyle),
                      style: buttonStyle2(context),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 350.0,
                      height: 50.0,
                      child: OutlinedButton(
                        onPressed: () {},
                        child: Text('Create New Account', style: LabelStyle),
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(0.0))),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),
              // privacy policy
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: Text('Privacy Policy', style: LabelStyle1),
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0.0))),
                      ),
                    ),
                    Text(' | ', style: LabelStyle1),
                    TextButton(
                      onPressed: () {},
                      child: Text('Terms of Service', style: LabelStyle1),
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0.0))),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
