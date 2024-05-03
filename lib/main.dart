// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:gauge_indicator/gauge_indicator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true),
        home: const HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int temp = 1;
  int hum = 1;
  SerialPort? _port;
  SerialPortReader? _reader;
  bool _isListening = false;
  List<DateTime> Schedule = [];
  int selected = 0;
  PageController _pagecontroller = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();
    _openSerialPort();
  }

  Future<void> _openSerialPort() async {
    _port = SerialPort('COM4');
    bool isOpen = await _port!.openReadWrite();
    if (isOpen) {
      _port!.config.baudRate = 9600;
      _reader = SerialPortReader(_port!);
      _startListening();
    } else {
      print('Failed to open Port');
    }
  }

  void _startListening() {
    if (!_isListening) {
      _isListening = true;
      StringBuffer buffer = StringBuffer();
      _reader!.stream.listen((data) {
        buffer.write(String.fromCharCodes(data));
        if (buffer.toString().contains(';') &&
            buffer.toString().contains('{')) {
          String jsonString = buffer.toString().split(';')[0];
          buffer.clear();
          try {
            Map<String, dynamic> jtemp = jsonDecode(jsonString);
            int ttemp = jtemp["Temperature"];
            int htemp = jtemp["Humidity"];
            setState(() {
              temp = ttemp;
              hum = htemp;
            });
          } catch (err) {}
        }
      }, onError: (error) {
        print('Error reading serial port: $error');
      });
    }
  }

  @override
  void dispose() {
    _isListening = false;
    _port?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (temp > 35 && hum < 60) {
      Schedule.add(DateTime.now());
    }
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: size.width * 0.3,
            height: size.height,
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    "Irrigation System".toUpperCase(),
                    style: GoogleFonts.montserrat(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  height: 40,
                ),
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _pagecontroller.jumpToPage(0);
                          selected = 0;
                        });
                      },
                      child: Container(
                        height: 60,
                        width: size.width * 0.3,
                        decoration: BoxDecoration(
                            color: selected == 0 ? Colors.black : Colors.white,
                            borderRadius: BorderRadius.circular(10)),
                        child: Row(
                          children: [
                            Icon(Icons.dashboard,
                                size: 40,
                                color: selected == 0
                                    ? Colors.white
                                    : Colors.grey.shade500),
                            Padding(
                              padding: const EdgeInsets.only(left: 15.0),
                              child: Text(
                                "DashBoard",
                                style: GoogleFonts.montserrat(
                                    fontSize: 40,
                                    fontWeight: FontWeight.w400,
                                    color: selected == 0
                                        ? Colors.white
                                        : Colors.grey.shade500),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _pagecontroller.jumpToPage(1);
                      selected = 1;
                    });
                  },
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: 60,
                        width: size.width * 0.3,
                        decoration: BoxDecoration(
                            color: selected == 1 ? Colors.black : Colors.white,
                            borderRadius: BorderRadius.circular(10)),
                        child: Row(
                          children: [
                            Icon(Icons.schedule,
                                size: 40,
                                color: selected == 1
                                    ? Colors.white
                                    : Colors.grey.shade500),
                            Padding(
                              padding: const EdgeInsets.only(left: 15.0),
                              child: Text(
                                "Scheduler",
                                style: GoogleFonts.montserrat(
                                    fontSize: 40,
                                    fontWeight: FontWeight.w400,
                                    color: selected == 1
                                        ? Colors.white
                                        : Colors.grey.shade500),
                              ),
                            ),
                          ],
                        ),
                      )),
                ),
              ],
            ),
          ),
          Container(
            width: size.width * 0.7,
            height: size.height,
            color: Colors.grey.shade200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: 100,
                ),
                SizedBox(
                  width: size.width * 0.7,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: 300,
                        height: 250,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              MyGauge(
                                min: 0,
                                max: 100,
                                value: temp.toDouble(),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "Temperature",
                                  style: GoogleFonts.poppins(fontSize: 32),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          Container(
                            width: 300,
                            height: 250,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20)),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  MyGauge(
                                    min: 0,
                                    max: 100,
                                    value: hum.toDouble(),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      "Humidity",
                                      style: GoogleFonts.poppins(fontSize: 32),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 100,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: size.width * 0.7,
                    height: size.height - 500,
                    child: PageView(
                      controller: _pagecontroller,
                      children: [
                        Container(
                          width: size.width * 0.7,
                          height: size.height - 500,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                width: size.width * 0.45,
                                height: size.height - 500,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20)),
                                child: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "My Schedules",
                                        style:
                                            GoogleFonts.poppins(fontSize: 32),
                                      ),
                                      Container(
                                        width: size.width * 0.45,
                                        height: size.height - 600,
                                        child: ListView.builder(
                                            itemCount: Schedule.length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Container(
                                                  width: size.width * 0.45,
                                                  height: 60,
                                                  decoration: BoxDecoration(
                                                      color: Colors.black45,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20)),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceAround,
                                                    children: [
                                                      Text(
                                                        DateFormat(
                                                                'MMM d hh:mm:ss')
                                                            .format(
                                                                Schedule[index])
                                                            .toString(),
                                                        style:
                                                            GoogleFonts.poppins(
                                                                fontSize: 28,
                                                                color: Colors
                                                                    .white),
                                                      ),
                                                      Text("15s",
                                                          style: GoogleFonts
                                                              .poppins(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 28,
                                                                  color: Colors
                                                                      .black))
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                width: size.width * 0.2,
                                height: size.height - 500,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20)),
                                child: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Forecased Data",
                                        style:
                                            GoogleFonts.poppins(fontSize: 32),
                                      ),
                                      Container(
                                        width: size.width * 0.2,
                                        height: size.height - 600,
                                        child: ListView.builder(
                                            itemCount: 7,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Container(
                                                  width: size.width * 0.2,
                                                  height: 60,
                                                  decoration: BoxDecoration(
                                                      color:
                                                          Colors.grey.shade200,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20)),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceAround,
                                                    children: [
                                                      Text(
                                                        DateFormat('MMM d')
                                                            .format(DateTime
                                                                    .now()
                                                                .add(Duration(
                                                                    days:
                                                                        index)))
                                                            .toString(),
                                                        style:
                                                            GoogleFonts.poppins(
                                                                fontSize: 28,
                                                                color: Colors
                                                                    .grey
                                                                    .shade400),
                                                      ),
                                                      Text("Sunny",
                                                          style: GoogleFonts
                                                              .poppins(
                                                                  fontSize: 28,
                                                                  color: Colors
                                                                      .black))
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: size.width * 0.7,
                          height: size.height - 500,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20)),
                          child: Container(
                            width: size.width * 0.45,
                            height: size.height - 500,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20)),
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "My Schedules",
                                    style: GoogleFonts.poppins(fontSize: 32),
                                  ),
                                  Container(
                                    width: size.width * 0.45,
                                    height: size.height - 600,
                                    child: ListView.builder(
                                        itemCount: Schedule.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Container(
                                              width: size.width * 0.45,
                                              height: 60,
                                              decoration: BoxDecoration(
                                                  color: Colors.black45,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20)),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  Text(
                                                    DateFormat('MMM d hh:mm:ss')
                                                        .format(Schedule[index])
                                                        .toString(),
                                                    style: GoogleFonts.poppins(
                                                        fontSize: 28,
                                                        color: Colors.white),
                                                  ),
                                                  Text("15s",
                                                      style:
                                                          GoogleFonts.poppins(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 28,
                                                              color:
                                                                  Colors.black))
                                                ],
                                              ),
                                            ),
                                          );
                                        }),
                                  )
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class MyGauge extends StatelessWidget {
  const MyGauge(
      {super.key, required this.min, required this.max, required this.value});

  final double min;
  final double max;
  final double value;

  @override
  Widget build(BuildContext context) {
    return AnimatedRadialGauge(
      duration: Duration(seconds: 1),
      curve: Curves.elasticOut,
      value: value,
      radius: 100,
      axis: GaugeAxis(
        min: min,
        max: max,
        degrees: 240,
        style: GaugeAxisStyle(
          blendColors: true,
          thickness: 20,
          background: Color.fromARGB(255, 255, 255, 255),
          segmentSpacing: 10,
        ),
        pointer: GaugePointer.triangle(
            width: 16, height: 100, borderRadius: 16, color: Colors.black),
        progressBar: GaugeRoundedProgressBar(
            placement: GaugeProgressPlacement.inside,
            gradient: GaugeAxisGradient(
                colorStops: const [0, 0.5, 1],
                colors: const [Colors.green, Colors.yellow, Colors.red])),
        segments: const [
          GaugeSegment(
            from: 0,
            to: 33.3,
            color: Color.fromARGB(50, 79, 83, 95),
            cornerRadius: Radius.circular(20),
          ),
          GaugeSegment(
            from: 33.3,
            to: 66.6,
            color: Color.fromARGB(50, 79, 83, 95),
            cornerRadius: Radius.circular(20),
          ),
          GaugeSegment(
            from: 66.6,
            to: 100,
            color: Color.fromARGB(50, 79, 83, 95),
            cornerRadius: Radius.circular(20),
          ),
        ],
      ),
      builder: (context, child, value) {
        return RadialGaugeLabel(
          value: value,
          style: GoogleFonts.poppins(fontSize: 40, fontWeight: FontWeight.bold),
        );
      },
    );
  }
}
