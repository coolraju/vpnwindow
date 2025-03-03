import 'package:flutter/material.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'styling.dart';
import 'Comman.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';

class ServiceDetailScreen extends StatefulWidget {
  final service;
  ServiceDetailScreen({Key? key, required this.service}) : super(key: key);
  @override
  _ServiceDetailScreenState createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen>
    with SingleTickerProviderStateMixin {
  String? _configFilePath;
  Process? _vpnProcess;
  String username = '';
  String password = '';
  String ovpncontent = '';
  String _log = '';
  bool isconnected = false;
  String loading = 'Fetching service detail...';
  String baseurl = 'https://billing.smartersvpn.com/client-v1';
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late AnimationController _controller;
  late Animation<double> _animation;
  bool isclicked = false;
  List<dynamic> servers = [];
  int? _selectedItem;
  Duration duration = Duration(hours: 0); // Set initial duration here
  Timer? timer;

  //init state
  initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _prefs.then((SharedPreferences prefs) {
      getServiceDetail(prefs);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    timer?.cancel();
    _animation.removeListener(() {});
    // _disconnectVpn();
    super.dispose();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (mounted) {
          duration = duration + const Duration(seconds: 1);
        }
      });
    });
  }

  checkVPnisconnected() async {
    //check if vpn is connected
    try {
      var result =
          await Process.run('tasklist', ['/FI', 'IMAGENAME eq openvpn.exe']);
      if (result.stdout.toString().contains('openvpn.exe')) {
        setState(() {
          isconnected = true;
        });
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  getServiceDetail(prefs) async {
    loading = 'Loading...';
    //get service detail
    // print(prefs.getString('accesstoken'));
    var response = await http.get(
      Uri.parse(
          '$baseurl/addon-modules/smartersvpn?action=getservice&serviceid=${widget.service['id']}&userid=${widget.service['user_id']}'),
      headers: {
        // ignore: prefer_interpolation_to_compose_strings
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
      ovpncontent = jsonObj['service']['server'][0]['ovpn'];
      Directory tempDir = Directory.systemTemp;
      // print('${tempDir.path}\\${widget.service['id']}.ovpn');
      File file = File('${tempDir.path}\\${widget.service['id']}.ovpn');
      await file.writeAsString(ovpncontent);
      setState(() {
        servers = jsonObj['service']['server'];
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
      _controller.repeat();
      setState(() {
        isclicked = true;
      });
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
            '${tempDir.path}\\auth.txt'
          ],
          runInShell: true,
        );

        _vpnProcess?.stdout.transform(SystemEncoding().decoder).listen((data) {
          setState(() {
            isconnected = true;
            isclicked = false;
            _controller.stop();
            // startTimer();
            _log += data;
            print(data);
          });
        });

        _vpnProcess?.stderr.transform(SystemEncoding().decoder).listen((data) {
          setState(() {
            _log += data;
            print(data);
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
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
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
                  Text('$hours:$minutes:$seconds',
                      style: TextStyle(fontSize: 30, color: Colors.white)),
                ],
              ),
              SizedBox(height: 20),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     Text('Lodon Server', style: LabelStyle),
              //   ],
              // ),
              // SizedBox(height: 20),
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
                child: RippleAnimation(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).colorScheme.primary,
                              // border: Border.all(color: Colors.blue, width: 5),
                            ),
                            child: Center(child: Text('Circle')),
                          ),
                          AnimatedBuilder(
                            animation: _animation,
                            builder: (context, child) {
                              return CustomPaint(
                                painter: CircularBorderPainter(
                                    isclicked == true ? _animation.value : 1),
                                child: SizedBox(
                                  width: 200,
                                  height: 200,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(height: 5),
                                      Image.asset('assets/start.png'),
                                      SizedBox(height: 10),
                                      Text(
                                          isconnected == true
                                              ? 'Tap to Disconnect'
                                              : 'Tap to Connect',
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  color: Colors.deepOrange,
                  delay: const Duration(milliseconds: 200),
                  repeat: true,
                  minRadius: isconnected == true ? 100 : 0,
                  ripplesCount: 3,
                  duration: const Duration(milliseconds: 6 * 200),
                ),
              ),
              const SizedBox(height: 20),

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
                      child: Center(
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            canvasColor: Theme.of(context).colorScheme.primary,
                          ),
                          child: DropdownButton(
                            value: _selectedItem,
                            isExpanded: true,
                            hint: Text('Select Server', style: LabelStyle),
                            items: servers.map((server) {
                              return DropdownMenuItem(
                                child: Row(
                                  children: [
                                    SvgPicture.network(
                                      'https:' + server['flag'],
                                      width: 20,
                                      height: 20,
                                    ),
                                    SizedBox(width: 10),
                                    Text(server['server_name'],
                                        style: LabelStyle),
                                  ],
                                ),
                                value: server['id'],
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedItem = value as int?;
                                int index = servers.indexWhere(
                                    (element) => element['id'] == value);
                                ovpncontent = servers[index]['ovpn'];
                                // print(ovpncontent);
                              });
                            },
                          ),
                        ),
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
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: Row(
                        children: [
                          Image.asset('assets/nolocation.png', width: 20),
                          SizedBox(width: 10),
                          Text('No location', style: LabelStyle),
                        ],
                      ),
                      style: buttonStyle4(context),
                    ),
                    SizedBox(width: 20),
                    TextButton(
                      onPressed: () {},
                      child: Row(
                        children: [
                          Image.asset('assets/nolocation.png', width: 20),
                          SizedBox(width: 10),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Smart Location', style: LabelStyle),
                                  Text('192.168.1.2', style: LabelStyle2),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      style: buttonStyle4(context),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Container(
                width: double.maxFinite,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/upload.png', width: 20),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('0.0', style: LabelStyle),
                            Text('Upload', style: LabelStyle2),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Text('|', style: LabelStyle),
                    SizedBox(width: 10),
                    Image.asset('assets/download.png', width: 20),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('0.0', style: LabelStyle),
                            Text('Download', style: LabelStyle2),
                          ],
                        ),
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
    );
  }
}

class CircularBorderPainter extends CustomPainter {
  final double progress;

  CircularBorderPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0;

    final double radius = size.width / 2;
    final Rect rect =
        Rect.fromCircle(center: Offset(radius, radius), radius: radius);
    final double startAngle = -90 * (3.1415927 / 180);
    final double sweepAngle = 2 * 3.1415927 * progress;

    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(CircularBorderPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
