import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AttendWorkplace extends StatelessWidget {

  AttendWorkplace({
    required this.workplaceName
  });
  final String workplaceName;

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    print('gps enabled $serviceEnabled');
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  Future<double> getDistance() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? officePosition =  prefs.getStringList(workplaceName);
    if (officePosition == null){
      return Future.error('error accessing office position');
    }
    double sLat = double.parse(officePosition[0]);
    double sLong = double.parse(officePosition[1]);
    Position currentPosition = await _determinePosition();
    double eLat = currentPosition.latitude;
    double eLong = currentPosition.longitude;
    double distance = Geolocator.distanceBetween(sLat, sLong, eLat, eLong);
    return distance;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: getDistance(),
        builder: (context,AsyncSnapshot<double> snapshot){
          if(snapshot.hasData){
            if(snapshot.data! > 50.0) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                        width: 200,
                        height: 200,
                        child: FittedBox(
                            fit: BoxFit.cover,
                            child: Icon(Icons.error))),
                    Text('Failed to attend to this workplace'),
                  ],
                ),
              );
            }
            if(snapshot.data! <= 50.0){
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                        width: 200,
                        height: 200,
                        child: FittedBox(
                            fit: BoxFit.cover,
                            child: Icon(Icons.check))),
                    Text('Attend success'),
                  ],
                ),
              );
            }
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
