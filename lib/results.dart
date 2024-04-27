import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ping_pong_table/plot.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:vector_math/vector_math_64.dart';

class ResultsScreen extends StatefulWidget {
  final List<Vector3> points;
  const ResultsScreen({super.key, required this.points});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  Widget content = const Center(
    child: CircularProgressIndicator(),
  );
  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        content = buildContent(widget.points);
      });
    });
    super.initState();
  }

  double tableXMax = 2.74,
      tableXMin = 0,
      tableYMax = 0.7625,
      tableYMin = -0.7625;
  bool hasIntersection = false;

  bool elementHaveIntersection(Vector3 element) {
    return element.x < tableXMin ||
        element.x > tableXMax ||
        element.y < tableYMin ||
        element.y > tableYMax;
  }

  Widget buildContent(List<Vector3> points) {
    Color shabakColor = const Color(0xFF00FF00);

    if (points
        .where((element) =>
            (element.x >= 1.37 && element.x < 1.38) && element.z <= 0.1525)
        .isNotEmpty) {
      shabakColor = const Color(0xFFFF0000);
      setState(() {
        hasIntersection = true;
      });
    }

    if (points
        .where((element) => elementHaveIntersection(element))
        .isNotEmpty) {
      setState(() {
        hasIntersection = true;
      });
    }
    return ListView(
      children: [
        SfCartesianChart(
          indicators: [
            AccumulationDistributionIndicator(
              signalLineColor: const Color(0xFF00FFFF),
              dataSource: const [
                Offset(
                  1.37,
                  0,
                ),
                Offset(
                  1.37,
                  0.1525,
                ),
              ],
              // color: shabakColor,
              xValueMapper: (offset, index) => offset.dx,
              // yValueMapper: (offset, index) => offset.dy,
            ),
          ],
          // plotAreaBackgroundImage: const AssetImage('table.svg'),
          primaryXAxis: const NumericAxis(
            interval: 0.5,
            minimum: 0,
            maximum: 3,
            title: AxisTitle(text: "X", alignment: ChartAlignment.near),
          ),
          primaryYAxis: const NumericAxis(
            name: "Z",
            title: AxisTitle(text: "Z", alignment: ChartAlignment.near),
            interval: 0.5,
            minimum: 0,
            maximum: 2,
          ),
          title: const ChartTitle(text: 'X Z'),
          series: [
            SplineSeries<Offset, double>(
              opacity: 1,
              dataSource: List.generate(
                  points.length,
                  (index) => Offset(
                        points.elementAt(index).x,
                        points.elementAt(index).z,
                      )),
              xValueMapper: (offset, index) => offset.dx,
              yValueMapper: (offset, index) => offset.dy,
            ),
            LineSeries(
              opacity: 1,
              dataSource: const [
                Offset(
                  1.37,
                  0,
                ),
                Offset(
                  1.37,
                  0.1525,
                ),
              ],
              color: shabakColor,
              xValueMapper: (offset, index) => offset.dx,
              yValueMapper: (offset, index) => offset.dy,
            ),
          ],
        ),
        SfCartesianChart(
          primaryXAxis: const NumericAxis(
            interval: 0.5,
            minimum: 0,
            maximum: 3,
            title: AxisTitle(text: "X", alignment: ChartAlignment.near),
          ),
          primaryYAxis: const NumericAxis(
            name: "Y",
            title: AxisTitle(text: "Y", alignment: ChartAlignment.near),
            interval: 0.5,
            // minimum: -2,
            maximum: 2,
          ),
          title: const ChartTitle(text: 'X Y'),
          series: [
            LineSeries(
              opacity: 1,
              dataSource: points
                  .where((element) => element.z == 0)
                  .toList()
                  .map<Offset>((e) => Offset(e.x, e.y))
                  .toList(),
              color: Color.fromARGB(255, 64, 175, 30),
              xValueMapper: (offset, index) => offset.dx,
              yValueMapper: (offset, index) => offset.dy,
              width: 5,
            ),
            SplineSeries(
              dataSource: List.generate(
                  points.length,
                  (index) => Offset(
                        points.elementAt(index).x,
                        points.elementAt(index).y,
                      )),
              xValueMapper: (offset, index) => offset.dx,
              yValueMapper: (offset, index) => offset.dy,
              color: Color(0xFF0000ff),
            ),
            LineSeries(
              opacity: 1,
              dataSource: const [
                Offset(
                  2.74,
                  -0.7625,
                ),
                Offset(
                  2.74,
                  0.7625,
                ),
              ],
              color: Color.fromARGB(255, 64, 175, 30),
              xValueMapper: (offset, index) => offset.dx,
              yValueMapper: (offset, index) => offset.dy,
            ),
            LineSeries(
              opacity: 1,
              dataSource: const [
                Offset(
                  0,
                  -0.7625,
                ),
                Offset(
                  0,
                  0.7625,
                ),
              ],
              color: Color.fromARGB(255, 64, 175, 30),
              xValueMapper: (offset, index) => offset.dx,
              yValueMapper: (offset, index) => offset.dy,
            ),
            LineSeries(
              opacity: 1,
              dataSource: const [
                Offset(
                  0,
                  -0.7625,
                ),
                Offset(
                  2.74,
                  -0.7625,
                ),
              ],
              color: Color.fromARGB(255, 64, 175, 30),
              xValueMapper: (offset, index) => offset.dx,
              yValueMapper: (offset, index) => offset.dy,
            ),
            LineSeries(
              opacity: 1,
              dataSource: const [
                Offset(
                  0,
                  0.7625,
                ),
                Offset(
                  2.74,
                  0.7625,
                ),
              ],
              color: Color.fromARGB(255, 64, 175, 30),
              xValueMapper: (offset, index) => offset.dx,
              yValueMapper: (offset, index) => offset.dy,
            ),
            LineSeries(
              opacity: 1,
              dataSource: const [
                Offset(
                  1.37,
                  -0.7625,
                ),
                Offset(
                  1.37,
                  0.7625,
                ),
              ],
              color: Color.fromARGB(255, 13, 143, 203),
              xValueMapper: (offset, index) => offset.dx,
              yValueMapper: (offset, index) => offset.dy,
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Results"),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pop(context, !hasIntersection);
              },
              icon: Icon(Icons.done)),
        ],
      ),
      body: content,
    );
  }
}
