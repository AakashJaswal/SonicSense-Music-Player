import 'package:flutter/material.dart';

class references extends StatelessWidget {
  const references({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("References"),
        backgroundColor: const Color(0xff005bbb),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              children: [
                const SizedBox(
                  height: 10,
                ),
                Expanded(
                    flex: 3,
                    child: Container(
                      // color: Colors.pink,
                      child: Text(
                        'Library',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    )),
                Expanded(
                    flex: 4,
                    child: Container(
                      // color: Colors.pink,
                      child: Text(
                        'Purpose',
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
                    flex: 3,
                    child: Container(
                      // color: Colors.pink,
                      child: Text(
                        'local_auth: v2.1.0',
                      ),
                    )),
                Expanded(
                    flex: 4,
                    child: Container(
                      // color: Colors.pink,
                      child: Text(
                        'Used for Fingerprint Auth',
                      ),
                    )),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            Row(
              children: [
                Expanded(
                    flex: 3,
                    child: Container(
                      // color: Colors.pink,
                      child: Text(
                        'environment_sensors: v0.1.1',),
                      ),
                    ),
                Expanded(
                    flex: 4,
                    child: Container(
                      // color: Colors.pink,
                      child: Text(
                        'Used for Ambient Sensors',
                      ),
                    )),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    // color: Colors.pink,
                    child: Text(
                      'sensors_plus: v2.0.0',),
                  ),
                ),
                Expanded(
                    flex: 4,
                    child: Container(
                      // color: Colors.pink,
                      child: Text(
                        'Used for Gyroscope and Acellerometer',
                      ),
                    )),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    // color: Colors.pink,
                    child: Text(
                      'proximity_sensorL v1.0.2',),
                  ),
                ),
                Expanded(
                    flex: 4,
                    child: Container(
                      // color: Colors.pink,
                      child: Text(
                        'Used for Proximity Sensor',
                      ),
                    )),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    // color: Colors.pink,
                    child: Text(
                      'device_display_brightness: v0.0.6',),
                  ),
                ),
                Expanded(
                    flex: 4,
                    child: Container(
                      // color: Colors.pink,
                      child: Text(
                        'Used for Adjusting brightness',
                      ),
                    )),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                const SizedBox(
                  height: 10,
                ),
                Expanded(
                    flex: 3,
                    child: Container(
                      // color: Colors.pink,
                      child: Text(
                        'Blogs, Documentations and Book.',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    )),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    // color: Colors.pink,
                    child: Text(
                      'Flutter Community Plus Plugins(https://plus.fluttercommunity.dev/)',),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    // color: Colors.pink,
                    child: Text(
                      'Flutter library wiki (https://pub.dev/)',),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    // color: Colors.pink,
                    child: Text(
                      'Local Auth docs (https://pub.dev/documentation/local_auth/latest/)',),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    // color: Colors.pink,
                    child: Text(
                      'Flutter Tutorial for Beginners - https://www.youtube.com/c/TheNetNinja',),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    // color: Colors.pink,
                    child: Text(
                      'Android Sensor Programming By Example - Varun Nagpal',),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(1),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xff005bbb),
                ),
                child: Image.asset(
                  'assets/book.png',
                  width: 300,
                  height: 350,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
