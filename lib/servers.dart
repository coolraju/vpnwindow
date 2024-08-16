import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'styling.dart';
import 'Comman.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ServersScreen extends StatefulWidget {
  @override
  _ServersScreenState createState() => _ServersScreenState();
}

class _ServersScreenState extends State<ServersScreen> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  List<dynamic> servers = [];
  String baseurl = 'https://billing.smartersvpn.com/client-v1';

  initState() {
    super.initState();
    _prefs.then((SharedPreferences prefs) {
      getServiceDetail(prefs);
    });
  }

  getServiceDetail(prefs) async {
    //get servers
    print(
        '$baseurl/addon-modules/smartersvpn?action=getservice&serviceid=${prefs.getString('serviceid')}&userid=${prefs.getString('userid')}');
    var response = await http.get(
      Uri.parse(
          '$baseurl/addon-modules/smartersvpn?action=getservice&serviceid=${prefs.getString('serviceid')}&userid=${prefs.getString('userid')}'),
      headers: {
        // ignore: prefer_interpolation_to_compose_strings
        'Authorization': 'Bearer ' + prefs.getString('accesstoken'),
      },
    );
    //parse json response
    Map<String, dynamic> jsonObj = json.decode(response.body);
    if (jsonObj['success'] == true) {
      setState(() {
        servers = jsonObj['service']['server'];
        print(servers);
      });
    } else {
      // return error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(jsonObj['message'], style: LabelStyle),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Center(
            child: Text(
              'Servers',
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
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              //search box
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: TextField(
                  style: LabelStyle,
                  decoration: InputDecoration(
                    hintText: 'Search',
                    hintStyle: LabelStyle,
                    prefixIcon: Icon(
                      Icons.search,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: servers.length,
                  itemBuilder: (context, index) {
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SvgPicture.network(
                            'https:' + servers[index]['flag'],
                            width: 20,
                            height: 20,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    servers[index]['server_name'],
                                    style: LabelStyle,
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  SizedBox(
                                    width: double.infinity,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(
                                          'Status: 9',
                                          style: LabelStyle,
                                        ),
                                        Text(
                                          'Load: 2',
                                          style: LabelStyle,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 60,
                          ),
                          ElevatedButton(
                            style: buttonStyle5(context),
                            onPressed: () {},
                            child: Text(
                              'Connect',
                              style: LabelStyle,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return SizedBox(
                      height: 20,
                    );
                  },
                ),
              ),
              SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
