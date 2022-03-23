import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WorkplaceScreen extends StatefulWidget {
  WorkplaceScreen({
    required this.workplaceName,
  });
  String workplaceName;

  @override
  State<WorkplaceScreen> createState() => _WorkplaceScreenState();
}

class _WorkplaceScreenState extends State<WorkplaceScreen> {

  late Future<Position> defaultPosition;
  GoogleMapController? controller;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  LatLng? markerPosition;
  MarkerId? selectedMarker;
  late SharedPreferences prefs;

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
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

  void _onMarkerTapped(MarkerId markerId) {
    print('tapped');
    final Marker? tappedMarker = markers[markerId];
    if (tappedMarker != null) {
      setState(() {
        final MarkerId? previousMarkerId = selectedMarker;
        if (previousMarkerId != null && markers.containsKey(previousMarkerId)) {
          final Marker resetOld = markers[previousMarkerId]!
              .copyWith(iconParam: BitmapDescriptor.defaultMarker);
          markers[previousMarkerId] = resetOld;
        }
        selectedMarker = markerId;
        final Marker newMarker = tappedMarker.copyWith(
          iconParam: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        );
        markers[markerId] = newMarker;

        markerPosition = null;
      });
    }
  }

  Future<void> _onMarkerDragEnd(MarkerId markerId, LatLng newPosition) async {
    final Marker? tappedMarker = markers[markerId];
    print('new position $newPosition');
    if (tappedMarker != null) {
      setState(() {
        // markerPosition = null;
        Marker newMarker = tappedMarker.copyWith(positionParam: newPosition);
        markers[markerId] = newMarker;
      });
      // await showDialog<void>(
      //     context: context,
      //     builder: (BuildContext context) {
      //       return AlertDialog(
      //           actions: <Widget>[
      //             TextButton(
      //               child: const Text('OK'),
      //               onPressed: () => Navigator.of(context).pop(),
      //             )
      //           ],
      //           content: Padding(
      //               padding: const EdgeInsets.symmetric(vertical: 66),
      //               child: Column(
      //                 mainAxisSize: MainAxisSize.min,
      //                 children: <Widget>[
      //                   Text('Old position: ${tappedMarker.position}'),
      //                   Text('New position: $newPosition'),
      //                 ],
      //               )));
      //     });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    this.controller = controller;
  }

  Future<void> _onMarkerDrag(MarkerId markerId, LatLng newPosition) async {
    // setState(() {
    //   markerPosition = newPosition;
    // });
  }

  Future<SharedPreferences> getWorkplaceList() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs;
  }

  @override
  void initState()  {

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    final String markerIdVal = 'marker_id_1';
    final MarkerId markerId = MarkerId(markerIdVal);
    defaultPosition = _determinePosition();
    return Scaffold(
      body: Center(
        child:
        FutureBuilder(
            future: defaultPosition,
            builder: (context,AsyncSnapshot<Position> snapshot){
              if (snapshot.hasData ){
                print(snapshot.data);
                // final String markerIdVal = 'marker_id_1';
                // final MarkerId markerId = MarkerId(markerIdVal);



                if (markers[markerId]==null) {
                  final Marker marker = Marker(
                      markerId: markerId,
                      position: LatLng(
                        snapshot.data!.latitude,
                        snapshot.data!.longitude,
                      ),
                      infoWindow: InfoWindow(title: markerIdVal, snippet: '*'),
                      onTap: () => _onMarkerTapped(markerId),
                      onDragEnd: (LatLng position) => _onMarkerDragEnd(markerId, position),
                      onDrag: (LatLng position) => _onMarkerDrag(markerId, position),
                      draggable: true
                  );
                  markers[markerId] = marker;
                };
                return Column(
                  children: [
                    Container(
                      height: height * 0.9,
                      child: GoogleMap(
                          initialCameraPosition: CameraPosition(
                              target: LatLng(snapshot.data!.latitude,snapshot.data!.longitude), zoom: 17),
                          onMapCreated: _onMapCreated,
                          markers: Set<Marker>.of(markers.values)),
                    ),
                    Container(
                      height: height * 0.1,
                      width: double.infinity,
                      padding: EdgeInsets.all(5.0),
                      child: ElevatedButton(onPressed: () async {
                        print(' marker location ${markers[markerId]!.position}');
                        final position =markers[markerId]!.position;
                        String lat = position.latitude.toString();
                        String long = position.longitude.toString();
                        prefs = await getWorkplaceList();
                        await prefs.setStringList(widget.workplaceName, <String>[lat,long]);
                        Navigator.pop(context);
                      },
                      child: Text('Set Workplace'),),
                    )
                  ],
                );
              }

              print('snapshot ${snapshot.data} ${snapshot.error} ${snapshot.hasError}');
              if (snapshot.hasError){
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(snapshot.error.toString()),
                    Text('Please enable gps and allow location services'),
                    ElevatedButton(onPressed: (){
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context)=>WorkplaceScreen(workplaceName: widget.workplaceName,)));
                    }, child: Text('Refresh'))
                  ],
                );

              }
              return CircularProgressIndicator();

            }
            ),
      ),
    );
  }
}
