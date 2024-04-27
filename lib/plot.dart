import 'dart:isolate';
import 'dart:math';

Future<List<List<double>>> calculateTrajectory(
    {required List<double> pos,
    required List<double> spin,
    required List<double> position,
    required double speed,
    required double zAngle,
    required double xyAngle}) async {
  return await Isolate.run<List<List<double>>>(() {
    const double dt = 0.0001;
    const double mass = 0.0027;
    const double airDensity = 1.225;
    const double radius = 0.04;
    double area = pi * pow(radius, 2);
    const double gravField = 9.81;
    List<double> gravForce = [0, 0, -mass * gravField];
    List<List<double>> trajectory = [];

    double radZAngle = zAngle * pi / 180;
    double radXyAngle = xyAngle * pi / 180;
    List<double> velocity = [
      speed * sin(radZAngle) * cos(radXyAngle),
      speed * sin(radZAngle) * sin(radXyAngle),
      speed * cos(radZAngle)
    ];

    while ((position[0] - pos[0]) > 5e-4) {
      double x = norm(spin) / norm(velocity);
      x = min(x, 2.9);
      double cd = 0.0073535 * pow(x, 10) -
          0.085194 * pow(x, 9) +
          0.31131 * pow(x, 8) +
          0.12452 * pow(x, 7) -
          4.3065 * pow(x, 6) +
          14.2655 * pow(x, 5) -
          22.9748 * pow(x, 4) +
          19.677 * pow(x, 3) -
          8.0998 * pow(x, 2) +
          1.186 * x +
          0.42961;
      double cl = -0.03178 * pow(x, 10) +
          0.50078 * pow(x, 9) -
          3.3817 * pow(x, 8) +
          12.7512 * pow(x, 7) -
          29.2528 * pow(x, 6) +
          41.486 * pow(x, 5) -
          34.7882 * pow(x, 4) +
          14.5788 * pow(x, 3) -
          1.0985 * pow(x, 2) -
          0.46494 * x +
          0.011107;
      List<double> vhat = normalize(velocity);
      List<double> dragForce = List.generate(
          3,
          (i) =>
              0.5 *
              airDensity *
              cd *
              area *
              pow(norm(velocity), 2) *
              (-vhat[i]));
      List<double> spinHat = normalize(spin);
      List<double> vhatPerp = crossProduct(spinHat, vhat);
      List<double> liftForce = List.generate(
          3,
          (i) =>
              0.5 *
              airDensity *
              cl *
              area *
              pow(norm(velocity), 2) *
              vhatPerp[i]);
      List<double> force =
          List.generate(3, (i) => gravForce[i] + dragForce[i] + liftForce[i]);

      position = List.generate(
          3,
          (i) =>
              position[i] -
              velocity[i] * dt -
              0.5 * (force[i] / mass) * pow(dt, 2));
      velocity = List.generate(3, (i) => velocity[i] - (force[i] / mass) * dt);

      trajectory.add(List.from(position));
    }

    return trajectory;
  });
}

double norm(List<double> vector) {
  return sqrt(vector.fold(
      0, (previousValue, element) => previousValue + pow(element, 2)));
}

List<double> normalize(List<double> vector) {
  double magnitude = norm(vector);
  return vector.map((e) => e / magnitude).toList();
}

List<double> crossProduct(List<double> a, List<double> b) {
  return [
    a[1] * b[2] - a[2] * b[1],
    a[2] * b[0] - a[0] * b[2],
    a[0] * b[1] - a[1] * b[0],
  ];
}
