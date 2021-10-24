import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pendulum/dotted_background.dart';
import 'package:pendulum/pendulum.dart';

/// Application based on [this repository](https://github.com/DinoZ1729/Double-Pendulum)
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  /// Remove OS Bottom Overlay and Staus Bar System Overlay
  SystemChrome.setEnabledSystemUIOverlays([]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const _length1 = 1.0;
  static const _length2 = 1.0;

  static const _weight1 = 10.0;
  static const _weight2 = 10.0;

  static const gravity = 9.81;

  static const fps = 60.0;
  static const delta = 1.0 / fps;

  static const _backgroundDotColor = Color(0x33CCCCCC);
  static const _backgroundDotSpacing = 0.94;
  static const _backgroundDotSize = 10.0;

  static const _tickDuration = Duration(milliseconds: 1000 ~/ fps);

  var _angle1 = 2.0 * math.pi / 2.0;
  var _angle2 = 2.0 * math.pi / 3.0;

  var _angularVelocity1 = 0.0;
  var _angularVelocity2 = 0.0;

  late StreamSubscription<int> _listener;

  final nodes = ValueNotifier<List<Offset>>(List.filled(2, Offset.zero));

  @override
  void initState() {
    super.initState();

    _setupTicker();

    _nextFrame();
  }

  void _setupTicker() {
    final ticker =
        Stream<int>.periodic(_tickDuration, (computation) => computation);

    _listener = ticker.listen(_onTick);
  }

  void _onTick(int computation) => _nextFrame();

  double _calculateAlpha1() {
    /// Maybe someday I'll be able to figure out what it does, but for now it's just working
    return (-gravity * (2 * _weight1 + _weight2) * math.sin(_angle1) -
            gravity * _weight2 * math.sin(_angle1 - 2 * _angle2) -
            2 *
                _weight2 *
                math.sin(_angle1 - _angle2) *
                (_angularVelocity2 * _angularVelocity2 * _length2 +
                    _angularVelocity1 *
                        _angularVelocity1 *
                        _length1 *
                        math.cos(_angle1 - _angle2))) /
        (_length1 *
            (2 * _weight1 +
                _weight2 -
                _weight2 * math.cos(2 * _angle1 - 2 * _angle2)));
  }

  double _calculateAlpha2() {
    return (2 * math.sin(_angle1 - _angle2)) *
        (_angularVelocity1 *
                _angularVelocity1 *
                _length1 *
                (_weight1 + _weight2) +
            gravity * (_weight1 + _weight2) * math.cos(_angle1) +
            _angularVelocity2 *
                _angularVelocity2 *
                _length2 *
                _weight2 *
                math.cos(_angle1 - _angle2)) /
        _length2 /
        (2 * _weight1 +
            _weight2 -
            _weight2 * math.cos(2 * _angle1 - 2 * _angle2));
  }

  /// Update pendulum state
  void _nextFrame() {
    final alfa1 = _calculateAlpha1();

    final alfa2 = _calculateAlpha2();

    _angularVelocity1 += delta * alfa1;
    _angularVelocity2 += delta * alfa2;

    _angle1 += delta * _angularVelocity1;
    _angle2 += delta * _angularVelocity2;

    final x1 = math.sin(_angle1) * _length1;
    final y1 = math.cos(_angle1) * _length1;

    final x2 = x1 + math.sin(_angle2) * _length2;
    final y2 = y1 + math.cos(_angle2) * _length2;

    nodes.value = [Offset(x1, y1), Offset(x2, y2)];
  }

  @override
  void dispose() {
    _listener.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: DottedBackground(
            spacing: _backgroundDotSpacing,
            size: _backgroundDotSize,
            color: _backgroundDotColor,
          ),
        ),
        Center(
          child: AspectRatio(
            aspectRatio: 1,
            child: AnimatedBuilder(
              animation: nodes,
              builder: (context, child) {
                return Pendulum(nodes: [Offset.zero, ...nodes.value]);
              },
            ),
          ),
        ),
      ],
    );
  }
}
