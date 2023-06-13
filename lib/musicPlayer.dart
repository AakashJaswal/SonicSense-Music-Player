import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:environment_sensors/environment_sensors.dart';
import 'package:musicplayer/references.dart';
import 'dart:io';

// import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';
import 'package:proximity_sensor/proximity_sensor.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:device_display_brightness/device_display_brightness.dart';
import 'package:motion_sensors/motion_sensors.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;
import 'package:volume_control/volume_control.dart';

class MusicPlayer extends StatefulWidget {
  const MusicPlayer({Key? key}) : super(key: key);

  @override
  State<MusicPlayer> createState() => _MusicPlayerState();
}

class _MusicPlayerState extends State<MusicPlayer> {
  AudioPlayer audioPlayer = AudioPlayer();
  final environmentSensors = EnvironmentSensors();

  bool _isNear = false;
  late StreamSubscription<dynamic> _proximityStreamSubscription;
  late StreamSubscription<dynamic> _VolumeControl;
  bool isMusicPlaying = false;
  Duration dur = Duration.zero;
  Duration pos = Duration.zero;
  late Source url;

  bool _lightAvailable = false;
  bool _pressureAvailable = false;

  double _brightness = 0.0;
  double _brightnessVal = 0.0;
  late StreamSubscription<dynamic> _brightnessAdjustmentSubscription;
  int counter = 0;
  double _volVal = 0.5;

  Vector3 _accelerometer = Vector3.zero();
  Vector3 _gyroscope = Vector3.zero();
  Vector3 _userAaccelerometer = Vector3.zero();
  Vector3 _orientation = Vector3.zero();
  Vector3 _absoluteOrientation = Vector3.zero();

  Future<void> ambientSensors() async {
    bool lightAvailable;
    bool pressureAvailable;

    lightAvailable =
        await environmentSensors.getSensorAvailable(SensorType.Light);
    pressureAvailable =
        await environmentSensors.getSensorAvailable(SensorType.Pressure);

    if (mounted) {
      setState(() {
        _lightAvailable = lightAvailable;
        _pressureAvailable = pressureAvailable;
      });
    }
  }

  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  void initState() {
    super.initState();
    ambientSensors();
    setSong();
    listenProximitySensor();
    _getBrightness();
    initVolumeState();
    setUpdateInterval(Duration.microsecondsPerSecond ~/ 20);

    if (mounted) {
      audioPlayer.onPlayerStateChanged.listen((state) {
        setState(() {
          isMusicPlaying = state == PlayerState.playing;
        });
      });

      audioPlayer.onDurationChanged.listen((newDur) {
        setState(() {
          dur = newDur;
        });
      });

      audioPlayer.onPositionChanged.listen((newPos) {
        setState(() {
          pos = newPos;
        });
      });
    }
    motionSensors.gyroscope.listen((GyroscopeEvent event) {
      setState(() {
        _gyroscope.setValues(event.x, event.y, event.z);
      });
    });
    motionSensors.accelerometer.listen((AccelerometerEvent event) {
      setState(() {
        _accelerometer.setValues(event.x, event.y, event.z);
      });
    });
    motionSensors.userAccelerometer.listen((UserAccelerometerEvent event) {
      setState(() {
        _userAaccelerometer.setValues(event.x, event.y, event.z);
      });
    });

    motionSensors.isOrientationAvailable().then((available) {
      if (available) {
        motionSensors.orientation.listen((OrientationEvent event) {
          setState(() {
            _orientation.setValues(event.yaw, event.pitch, event.roll);
          });
        });
      }
    });
    motionSensors.absoluteOrientation.listen((AbsoluteOrientationEvent event) {
      setState(() {
        _absoluteOrientation.setValues(event.yaw, event.pitch, event.roll);
      });
    });
  }

  Future<void> initVolumeState() async {
    if (!mounted) return;

    //read the current volume
    _volVal = await VolumeControl.volume;
    setState(() {});
  }

  void setUpdateInterval(int interval) {
    motionSensors.accelerometerUpdateInterval = interval;
    motionSensors.userAccelerometerUpdateInterval = interval;
    motionSensors.gyroscopeUpdateInterval = interval;
    motionSensors.orientationUpdateInterval = interval;
    motionSensors.absoluteOrientationUpdateInterval = interval;
  }

  void _getBrightness() {
    DeviceDisplayBrightness.getBrightness().then((value) {
      setState(() {
        _brightness = value;
      });
    });
  }

  void brightnessONOFF() {
    counter = counter + 1;
    if (counter % 2 == 1) {
      _brightnessAdjustmentSubscription =
          environmentSensors.light.listen((double event) {
        setState(() {
          _brightnessVal = double.parse(event.toDouble().toStringAsFixed(1));
        });
      });
      _brightnessVal = _brightnessVal / 1000;
      if (_brightnessVal < 0.2) {
        _brightnessVal = 0.2;
      } else if (_brightnessVal > 1.0) {
        _brightnessVal = 1.0;
      }
      DeviceDisplayBrightness.setBrightness(_brightnessVal);
    } else {
      DeviceDisplayBrightness.resetBrightness();
    }
  }

  Future<void> listenProximitySensor() async {
    FlutterError.onError = (FlutterErrorDetails details) {
      if (foundation.kDebugMode) {
        FlutterError.dumpErrorToConsole(details);
      }
    };
    _proximityStreamSubscription = ProximitySensor.events.listen((int event) {
      setState(() {
        _isNear = (event > 0) ? true : false;
        if (_isNear == true) {
          DeviceDisplayBrightness.setBrightness(0.01);
        } else {
          DeviceDisplayBrightness.resetBrightness();
        }
        Future playpause() async {
          await audioPlayer.pause();
        }

        if (_isNear == true) {
          sleep(Duration(seconds: 1));
          if (_accelerometer.z < -7) {
            playpause();
          }
        }
      });
    });
  }

  Future setSong() async {
    audioPlayer.setReleaseMode(ReleaseMode.loop);
    audioPlayer.setSource(AssetSource('out.mp3'));
  }

  Future<void> listenVolume() async {
    VolumeControl.setVolume(
        double.parse(degrees(_absoluteOrientation.y).toStringAsFixed(1)) / 100);
    print(_volVal);
    print(degrees(_absoluteOrientation.y).toStringAsFixed(1));
  }

  @override
  void dispose() {
    super.dispose();
    audioPlayer.dispose();
    _proximityStreamSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Music Player'),
        backgroundColor: const Color(0xff005bbb),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => references()));
            },
            child: Text(
              "References",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                        flex: 5,
                        child: Container(
                            child: Row(
                          children: [
                            IconButton(
                              onPressed: () {},
                              icon: Icon(Icons.speed),
                              color: Colors.black,
                            ),
                            (_pressureAvailable)
                                ? StreamBuilder<double>(
                                    stream: environmentSensors.pressure,
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return const CircularProgressIndicator();
                                      }
                                      return Text(
                                        '${snapshot.data?.toStringAsFixed(2)} hPa',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      );
                                    })
                                : const Text('N/A hPa'),
                          ],
                        ))),
                    Expanded(
                        flex: 6,
                        child: Container(
                            // color: Colors.pink,

                            child: Row(
                          children: [
                            IconButton(
                              onPressed: brightnessONOFF,
                              icon: Icon(Icons.light_sharp),
                              color: Colors.black,
                            ),
                            (_lightAvailable)
                                ? StreamBuilder<double>(
                                    stream: environmentSensors.light,
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData)
                                        return CircularProgressIndicator();
                                      return Text(
                                        'Light: ${snapshot.data?.toStringAsFixed(2)} lx',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      );
                                    })
                                : Text('N/A lx'),
                          ],
                        ))),
                    Expanded(
                        flex: 4,
                        child: Container(
                            // color: Colors.pink,
                            child: Row(
                          children: [
                            IconButton(
                              onPressed: () {},
                              icon: Icon(Icons.account_balance_wallet),
                              color: Colors.black,
                            ),
                            Text(
                              '$_isNear',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            // child: Text('UserAccelerometer: $userAccelerometer'),
                          ],
                        ))),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                        flex: 7,
                        child: Container(
                          // color: Colors.pink,
                          child: Text(
                            'Gyroscope',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        )),
                    Expanded(
                        flex: 7,
                        child: Container(
                          // color: Colors.pink,
                          child: Text(
                            'X:${_gyroscope.x.toStringAsFixed(1)}deg/s',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        )),
                    Expanded(
                        flex: 7,
                        child: Container(
                          // color: Colors.pink,
                          child: Text(
                            'Y:${_gyroscope.y.toStringAsFixed(1)}deg/s',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        )),
                    Expanded(
                        flex: 7,
                        child: Container(
                          // color: Colors.pink,
                          child: Text(
                            'Z:${_gyroscope.z.toStringAsFixed(1)}deg/s',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        )),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Expanded(
                        flex: 1,
                        child: Container(
                          // color: Colors.pink,
                          child: Text(
                            'Accelerometer',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        )),
                    Expanded(
                        flex: 1,
                        child: Container(
                          // color: Colors.pink,
                          child: Text(
                            '${_accelerometer.x.toStringAsFixed(1)}m/s^2',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        )),
                    Expanded(
                        flex: 1,
                        child: Container(
                          // color: Colors.pink,
                          child: Text(
                            '${_accelerometer.y.toStringAsFixed(1)}m/s^2',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        )),
                    Expanded(
                        flex: 1,
                        child: Container(
                          // color: Colors.pink,
                          child: Text(
                            '${_accelerometer.z.toStringAsFixed(1)}m/s^2',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        )),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Expanded(
                        flex: 1,
                        child: Container(
                          // color: Colors.pink,
                          child: const Text(
                            'User Acceleration',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        )),
                    Expanded(
                        flex: 1,
                        child: Container(
                          // color: Colors.pink,
                          child: Text(
                            'X:${_userAaccelerometer.x.toStringAsFixed(1)}m/s^2',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        )),
                    Expanded(
                        flex: 1,
                        child: Container(
                          // color: Colors.pink,
                          child: Text(
                            'Y:${_userAaccelerometer.y.toStringAsFixed(1)}m/s^2',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        )),
                    Expanded(
                        flex: 1,
                        child: Container(
                          // color: Colors.pink,
                          child: Text(
                            'Z:${_userAaccelerometer.z.toStringAsFixed(1)}m/s^2',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        )),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Expanded(
                        flex: 1,
                        child: Container(
                          // color: Colors.pink,
                          child: const Text(
                            'Absolute Orientation',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        )),
                    Expanded(
                        flex: 1,
                        child: Container(
                          // color: Colors.pink,
                          child: Text(
                            'X:${degrees(_absoluteOrientation.x).toStringAsFixed(1)}deg',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        )),
                    Expanded(
                        flex: 1,
                        child: Container(
                          // color: Colors.pink,
                          child: Text(
                            'Y:${degrees(_absoluteOrientation.y).toStringAsFixed(1)}deg',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        )),
                    Expanded(
                        flex: 1,
                        child: Container(
                          // color: Colors.pink,
                          child: Text(
                            'Z:${degrees(_absoluteOrientation.z).toStringAsFixed(1)}deg',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        )),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Expanded(
                        flex: 1,
                        child: Container(
                          // color: Colors.pink,
                          child: Text(
                            'Orientation',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        )),
                    Expanded(
                        flex: 1,
                        child: Container(
                          // color: Colors.pink,
                          child: Text(
                            'X:${degrees(_orientation.x).toStringAsFixed(1)}deg',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        )),
                    Expanded(
                        flex: 1,
                        child: Container(
                          // color: Colors.pink,
                          child: Text(
                            'Y:${degrees(_orientation.y).toStringAsFixed(1)}deg',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        )),
                    Expanded(
                        flex: 1,
                        child: Container(
                          // color: Colors.pink,
                          child: Text(
                            'Z:${degrees(_orientation.z).toStringAsFixed(1)}deg',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        )),
                  ],
                ),
              ],
            ),
            const SizedBox(
              height: 60,
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xff005bbb),
                ),
                child: Image.asset(
                  'assets/Crest_BW.png',
                  width: 250,
                  height: 250,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            const Text(
              '♫ Out of time ♫',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'The Weeknd',
              style: TextStyle(fontSize: 20),
            ),
            Slider(
                min: 0,
                max: dur.inSeconds.toDouble(),
                value: pos.inSeconds.toDouble(),
                onChanged: (value) async {
                  final position = Duration(seconds: value.toInt());
                  await audioPlayer.seek(position);
                  await audioPlayer.resume();
                }),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_printDuration(pos)),
                  Text(_printDuration(dur - pos))
                ],
              ),
            ),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CircleAvatar(
                      radius: 35,
                      child: IconButton(
                        icon: Icon(
                            isMusicPlaying ? Icons.pause : Icons.play_arrow),
                        iconSize: 50,
                        onPressed: () async {
                          if (isMusicPlaying) {
                            await audioPlayer.pause();
                          } else {
                            await audioPlayer.resume();
                          }
                        },
                      ),
                    ),
                    const SizedBox(
                      width: 60,
                    ),
                    GestureDetector(
                      onLongPress: listenVolume,
                      onLongPressCancel: listenVolume,
                      child: CircleAvatar(
                        radius: 30,
                        child: IconButton(
                          icon: Icon(Icons.volume_up_rounded),
                          iconSize: 30,
                          onPressed: () {},
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 40,
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
