import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'servicedetails.dart';
import 'styling.dart';
import 'Comman.dart';

class VpnScreen extends StatefulWidget {
  @override
  _VpnScreenState createState() => _VpnScreenState();
}

class _VpnScreenState extends State<VpnScreen> {
  String baseurl = 'https://billing.smartersvpn.com/client-v1';
  List services = [];
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  //init state
  @override
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
        // print(services);
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
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'VPN Services List',
            style: LabelStyle,
          ),
        ),
        automaticallyImplyLeading: false,
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            //list of services
            Expanded(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: services.length,
                itemBuilder: (context, index) {
                  return Container(
                    height: 55,
                    color: Theme.of(context).colorScheme.onPrimary,
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Image.asset(
                              'assets/smalllogo.png',
                              width: 30,
                              height: 30,
                            ),
                            Expanded(
                              child: Container(
                                width: double.maxFinite,
                                padding: EdgeInsets.only(left: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      services[index]['products']['title'],
                                      style: LabelStyle1,
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Due on ${services[index]['next_due_date']}',
                                      style: LabelStyle2,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {},
                              child: Text('${services[index]['status']}',
                                  style: LabelStyle),
                              style: buttonStyle3(context),
                            ),
                            Padding(
                                padding: EdgeInsets.only(left: 10),
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ServiceDetailScreen(
                                            service: services[index],
                                          ),
                                        ),
                                      );
                                    },
                                    child: Image.asset('assets/arrow.png',
                                        width: 20, height: 20),
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) =>
                    const SizedBox(height: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
