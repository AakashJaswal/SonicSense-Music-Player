import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:musicplayer/musicPlayer.dart';
import 'package:audioplayers/audioplayers.dart';

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FingerprintApp(),
    ));

class FingerprintApp extends StatefulWidget {
  const FingerprintApp({Key? key}) : super(key: key);

  @override
  State<FingerprintApp> createState() => _FingerprintAppState();
}

class _FingerprintAppState extends State<FingerprintApp> {
  LocalAuthentication auth = LocalAuthentication();
  late bool _canVerify;

  late List<BiometricType> _available;
  String isAuthorized = "Not Authorized";

  Future<void> _checkBiometric() async {
    late bool canVerify;
    try {
      canVerify = await auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      print(e);
    }

    if (!mounted) return;
    setState(() {
      _canVerify = canVerify;
    });
  }

  Future<void> _getAllBiometric() async {
    late List<BiometricType> available;
    try {
      available = await auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      print(e);
    }
    setState(() {
      _available = available;
    });
  }

  Future<void> checkAuthorized() async {
    bool authenticated = false;
    try {
      authenticated = await auth.authenticate(
          localizedReason: "Kindly scan your finger to authenticate",
          options: const AuthenticationOptions(
            useErrorDialogs: true,
          ));
    } on PlatformException catch (e) {
      print(e);
    }
    if (!mounted) return;

    setState(() {
      isAuthorized = authenticated ? "Authorized" : "Not Authorized";
      print(isAuthorized);
      if (authenticated) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => MusicPlayer()));
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _checkBiometric();
    _getAllBiometric();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xff005bbb),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(
                margin: const EdgeInsets.symmetric(vertical: 50.0),
                child: Column(
                  children: <Widget>[
                    Image.asset(
                      'assets/Crest_BW.png',
                      width: 200,
                    ),
                    const SizedBox(height: 40),
                    Image.asset(
                      'assets/UB_Horizontal_SUNY.png',
                      width: 500,
                    ),
                    const SizedBox(height: 30),
                    Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                                flex: 1,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 0, horizontal: 10),
                                  child: const Text(
                                    'Aakash Jaswal',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )),
                            Expanded(
                                flex: 1,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 0, horizontal: 10),
                                  child: const Text(
                                    'UB ID: 50478725',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                                flex: 3,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 0, horizontal: 10),
                                  child: const Text(
                                    'ajaswal@buffalo.edu',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )),
                            Expanded(
                                flex: 1,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 0, horizontal: 10),
                                  child: const Text(
                                    'EE526',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 100),
                    Image.asset(
                      'assets/fp.png',
                      width: 120.0,
                    ),
                    const Text(
                      "Fingerprint Auth Required",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: checkAuthorized,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30))),
                          child: const Padding(
                            padding: EdgeInsets.all(10),
                            child: Text("Authenticate",
                                style: TextStyle(color: Color(0xff005bbb)),
                                textScaleFactor: 1.2),
                          ),
                        )),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
