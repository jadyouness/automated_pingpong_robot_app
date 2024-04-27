import 'dart:developer';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'package:ping_pong_table/plot.dart';
import 'package:ping_pong_table/results.dart';
import 'package:vector_math/vector_math_64.dart';

class PingPongTable extends StatelessWidget {
  const PingPongTable({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ping Pong Table',
        ),
      ),
      body: const PingPongGrid(),
    );
  }
}

class PingPongGrid extends StatefulWidget {
  const PingPongGrid({super.key});

  @override
  State<PingPongGrid> createState() => _PingPongGridState();
}

class _PingPongGridState extends State<PingPongGrid> {
  TextEditingController xCont = TextEditingController(text: "7.5");
  TextEditingController yCont = TextEditingController(text: "7.5");
  ExpansionTileController sideViewController = ExpansionTileController();
  double? selectedRow = 7.5;
  double? selectedColumn = 7.5;
  double? initialPosition = 7.5;
  late Function() listener;
  TextEditingController initialPositionCont =
      TextEditingController(text: "7.5");
  late Function() initialPositionListener;
  TextEditingController sideSpinController = TextEditingController();
  TextEditingController topSpinController = TextEditingController();
  TextEditingController xyAngleController = TextEditingController();
  TextEditingController zAngleController = TextEditingController();
  TextEditingController speedController = TextEditingController();
  @override
  void initState() {
    listener = () {
      if (xCont.text.isNotEmpty && yCont.text.isNotEmpty) {
        setState(() {
          selectedRow = double.parse(yCont.text);
          selectedColumn = double.parse(xCont.text);
        });
      } else {
        setState(() {
          selectedRow = null;
          selectedColumn = null;
        });
      }
    };
    initialPositionListener = () {
      setState(() {
        initialPosition = double.parse(initialPositionCont.text);
      });
    };
    xCont.addListener(listener);
    yCont.addListener(listener);
    initialPositionCont.addListener(initialPositionListener);
    super.initState();
  }

  @override
  void dispose() {
    xCont.removeListener(listener);
    yCont.removeListener(listener);
    initialPositionCont.removeListener(initialPositionListener);
    super.dispose();
  }

  getPoints() {}
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView(
        children: [
          Row(
            children: [
              Expanded(
                flex: 5,
                child: Slider(
                  value: selectedColumn?.toDouble() ?? 0,
                  onChanged: (x) {
                    setState(() {
                      xCont.text = x.toString();
                      selectedColumn = x;
                    });
                  },
                  min: 0,
                  max: 15,
                ),
              ),
              Expanded(
                flex: 1,
                child: TextField(
                  textInputAction: TextInputAction.continueAction,
                  controller: xCont,
                  decoration: const InputDecoration(labelText: "X"),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                flex: 5,
                child: Slider(
                  value: selectedRow?.toDouble() ?? 0,
                  onChanged: (y) {
                    setState(() {
                      yCont.text = y.toString();
                      selectedRow = y;
                    });
                  },
                  min: 0,
                  max: 15,
                ),
              ),
              Expanded(
                flex: 1,
                child: TextField(
                  textInputAction: TextInputAction.continueAction,
                  controller: yCont,
                  decoration: const InputDecoration(labelText: "Y"),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Expanded(
                flex: 5,
                child: Slider(
                    min: 0,
                    max: 15,
                    value: initialPosition ?? 0,
                    onChanged: (i) {
                      setState(() {
                        initialPosition = i;
                        initialPositionCont.text = i.toString();
                      });
                    }),
              ),
              Expanded(
                flex: 1,
                child: TextField(
                  controller: initialPositionCont,
                  textInputAction: TextInputAction.continueAction,
                  decoration:
                      const InputDecoration(labelText: "Initial Postion"),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: speedController,
            textInputAction: TextInputAction.continueAction,
            decoration: const InputDecoration(labelText: "Speed"),
          ),
          TextField(
            controller: xyAngleController,
            textInputAction: TextInputAction.continueAction,
            decoration: const InputDecoration(labelText: "XY Angle"),
          ),
          TextField(
            controller: zAngleController,
            textInputAction: TextInputAction.continueAction,
            decoration: const InputDecoration(labelText: "Z Angle"),
          ),
          TextField(
            controller: sideSpinController,
            textInputAction: TextInputAction.continueAction,
            decoration: const InputDecoration(labelText: "Side spin"),
          ),
          TextField(
            controller: topSpinController,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(labelText: "Top spin"),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () async {
              List<List<double>> points = await calculateTrajectory(
                pos: [
                  0,
                  double.tryParse(initialPositionCont.text) ?? 0,
                  0.1,
                ],
                spin: [
                  0,
                  -(double.tryParse(topSpinController.text) ?? 100),
                  -(double.tryParse(sideSpinController.text) ?? 300),
                ],
                position: [2.040304e+00, -4.863169e-01, -7.593353e-05],
                speed: double.tryParse(speedController.text) ?? 2.9402,
                zAngle: double.tryParse(zAngleController.text) ?? 128.1508,
                xyAngle: double.tryParse(xyAngleController.text) ?? -26,
              );

              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ResultsScreen(
                        points: List.generate(
                            points.length,
                            (index) => Vector3(points[index][0],
                                points[index][1], points[index][2]))),
                  )).then((value) async {
                if (value == true) {
                  DatabaseReference ref = FirebaseDatabase.instance.ref('/app');
                  await ref.update({
                    "initial": double.tryParse(initialPositionCont.text) ?? 0,
                    "side_spin":
                        -(double.tryParse(sideSpinController.text) ?? 300),
                    "speed": double.tryParse(speedController.text) ?? 2.9402,
                    "top_spin":
                        -(double.tryParse(topSpinController.text) ?? 100),
                    "x": 2.040304e+00,
                    "xy_angle": double.tryParse(xyAngleController.text) ?? -26,
                    "z_angle": double.tryParse(zAngleController.text) ?? -26,
                    "y": -4.863169e-01,
                  });
                }
              });
            },
            child: const Icon(
              Icons.done,
            ),
          )
        ],
      ),
    );
  }
}
