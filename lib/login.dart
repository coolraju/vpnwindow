import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'vpn.dart';
import 'dart:async';
import 'dart:convert';
import 'styling.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis/people/v1.dart' as people;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String username = '';
  String password = '';
  bool loading = false;
  bool hidePassword = true;
  String baseurlapi = '';
  String baseurl = '';
  String appleclientid = '';
  String appleredirecturl = '';
  String googleclientid = '';
  String googlescret = '';
  bool isAuthorized = false;

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  //init state
  initState() {
    super.initState();
    baseurl = dotenv.get('BASEURL').toString();
    baseurlapi = dotenv.get('BASEURL_API').toString();
  }

  Future<void> getSocialLogin() async {
    var response = await http.get(
      Uri.parse('$baseurlapi/client-v1/getsocialloginurl'),
      headers: {
        'Content-Type': 'application/json',
      },
    );
    //parse json response
    Map<String, dynamic> jsonObj = json.decode(response.body);
    if (jsonObj['success'] == true) {
      setState(() {
        appleclientid = jsonObj['appleclientid'];
        appleredirecturl = jsonObj['appleredirecturl'];
        googleclientid = jsonObj['googleclientid'];
        googlescret = jsonObj['googlescret'];
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

  _connect() async {
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
    // print(baseurlapi);
    var response = await http.post(
      Uri.parse('$baseurlapi/login'),
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
      prefs.setString('userid', jsonObj['user']['id'].toString());
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
                    cursorColor: Theme.of(context).colorScheme.secondary,
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
                      cursorColor: Theme.of(context).colorScheme.secondary,
                      initialValue: password,
                      obscureText: hidePassword,
                      onChanged: (value) {
                        password = value;
                      },
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          icon: Icon(hidePassword == false
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              hidePassword = !hidePassword;
                            });
                          },
                          color: Theme.of(context).colorScheme.secondary,
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
                        child: loading == false
                            ? Text('Login', style: LabelStyle)
                            : CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).colorScheme.onPrimary),
                              ),
                        style: buttonStyle(context)),
                  ],
                ),
              ),
              SizedBox(height: 20),

              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                        child: Divider(
                      color: Theme.of(context).colorScheme.secondary,
                    )),
                    SizedBox(width: 10),
                    Text("or connect with", style: LabelStyle1),
                    SizedBox(width: 10),
                    Expanded(
                        child: Divider(
                      color: Theme.of(context).colorScheme.secondary,
                    )),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          final clientId =
                              ClientId(googleclientid, googlescret);
                          // user info scopes
                          const scopes = [
                            'email',
                            'profile',
                          ];
                          final authClient = await clientViaUserConsent(
                              clientId, scopes, prompt);
                          //get user info
                          final peopleApi = people.PeopleServiceApi(authClient);
                          final response = await peopleApi.people.get(
                            'people/me',
                            personFields: 'emailAddresses,names,photos',
                          );
                          // print(jsonEncode(response));
                          var response1 = await http.post(
                            Uri.parse('$baseurlapi/login'),
                            body: {
                              'email': response.emailAddresses![0].value,
                              'given_name': response.names![0].givenName,
                              'family_name': response.names![0].familyName,
                              'avatar': response.photos![0].url,
                              'oauth_uid': response
                                  .emailAddresses![0].metadata!.source!.id,
                              'oauth_provider': 'google',
                            },
                          );
                          print(response1.body);
                          //parse json response
                          Map<String, dynamic> jsonObj =
                              json.decode(response1.body);
                          if (jsonObj['success'] == true) {
                            //save token
                            final SharedPreferences prefs = await _prefs;
                            prefs.setString(
                                'accesstoken', jsonObj['access_token']);
                            prefs.setString('email', jsonObj['user']['email']);
                            prefs.setString(
                                'userid', jsonObj['user']['id'].toString());
                            prefs.setString(
                                'name',
                                jsonObj['user']['firstname'] +
                                    ' ' +
                                    jsonObj['user']['lastname']);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => VpnScreen()),
                            );
                          } else {
                            // return error message
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(jsonObj['message']),
                              ),
                            );
                          }
                        } catch (e) {
                          print('Sign in failed: $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Sign in failed:'),
                            ),
                          );
                        }
                      },
                      child: Row(
                        children: [
                          Image.asset('assets/google.png', width: 20),
                          SizedBox(width: 10),
                          Text('Google', style: LabelStyle),
                        ],
                      ),
                      style: buttonStyle2(context),
                    ),
                    SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () async {
                        final credential =
                            await SignInWithApple.getAppleIDCredential(
                          scopes: [
                            AppleIDAuthorizationScopes.email,
                            AppleIDAuthorizationScopes.fullName,
                          ],
                          webAuthenticationOptions: WebAuthenticationOptions(
                            clientId: appleclientid, // your service ID
                            redirectUri: Uri.parse(appleredirecturl),
                          ),
                        );

                        print(credential);
                        var response1 = await http.post(
                          Uri.parse('$baseurlapi/client-v1/mobilelogin'),
                          body: {
                            'code': credential.authorizationCode,
                            if (credential.givenName != null)
                              'given_name': credential.givenName ?? '',
                            if (credential.familyName != null)
                              'family_name': credential.familyName ?? '',
                            'oauth_provider': 'apple',
                          },
                        );
                        print(response1.body);
                        //parse json response
                        Map<String, dynamic> jsonObj =
                            json.decode(response1.body);
                        if (jsonObj['success'] == true) {
                          //save token
                          final SharedPreferences prefs = await _prefs;
                          prefs.setString(
                              'accesstoken', jsonObj['access_token']);
                          prefs.setString('email', jsonObj['user']['email']);
                          prefs.setString(
                              'userid', jsonObj['user']['id'].toString());
                          prefs.setString(
                              'name',
                              jsonObj['user']['firstname'] +
                                  ' ' +
                                  jsonObj['user']['lastname']);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => VpnScreen()),
                          );
                        } else {
                          // return error message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(jsonObj['message']),
                            ),
                          );
                        }
                      },
                      child: Row(
                        children: [
                          Image.asset('assets/apple.png', width: 20),
                          SizedBox(width: 10),
                          Text('Apple', style: LabelStyle),
                        ],
                      ),
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
                        onPressed: () async {
                          //url scheme
                          var baseurl1 = baseurl.replaceAll('https://', '');
                          final Uri toLaunch = Uri(
                              scheme: 'https',
                              host: baseurl1,
                              path: '/auth/signup');
                          //redirect to outersite
                          if (!await launchUrl(toLaunch)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Could not launch https://smartersvpn.com'),
                              ),
                            );
                          }
                        },
                        child: Text('Create New Account', style: LabelStyle),
                        style: ButtonStyle(
                          //border color
                          side: MaterialStateProperty.all(BorderSide(
                              color: Theme.of(context).colorScheme.secondary)),
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
                      onPressed: () async {
                        //url scheme
                        var baseurl1 = baseurl.replaceAll('https://', '');
                        final Uri toLaunch = Uri(
                            scheme: 'https',
                            host: baseurl1,
                            path: '/privacy-policy');
                        //redirect to outersite
                        if (!await launchUrl(toLaunch)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Could not launch'),
                            ),
                          );
                        }
                      },
                      child: Text('Privacy Policy', style: LabelStyle1),
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0.0))),
                      ),
                    ),
                    Text('|', style: LabelStyle1),
                    TextButton(
                      onPressed: () async {
                        var baseurl1 = baseurl.replaceAll('https://', '');
                        final Uri toLaunch = Uri(
                            scheme: 'https',
                            host: baseurl1,
                            path: '/term-service');
                        //redirect to outersite
                        if (!await launchUrl(toLaunch)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Could not launch'),
                            ),
                          );
                        }
                      },
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

  prompt(String url) async {
    print('Please go to the following URL and grant access:');
    print('  => $url' + '&access_type=offline');
    final Uri _url = Uri.parse(url + '&access_type=offline');
    if (await launchUrl(_url)) {
      print('Authorization successful');
    } else {
      print('Authorization failed');
    }
  }
}
