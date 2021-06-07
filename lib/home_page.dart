import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<Map<String, dynamic>> locData;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Location Detection App'),
        ),
        body: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              ElevatedButton(
                onPressed: () {
                  _queryData();
                },
                child: Text('Get Location'),
              ),
              FutureBuilder<Map<String, dynamic>>(
                future: locData,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text('Longitude'),
                        CircularProgressIndicator(),
                        Text('Latitude'),
                        CircularProgressIndicator(),
                        Center(child: CircularProgressIndicator())
                      ],
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error');
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('Longitude'),
                      Text(
                        snapshot.data['longitude'].toString(),
                        style: TextStyle(fontSize: 20.0),
                      ),
                      Text('Latitude'),
                      Text(
                        snapshot.data['latitude'].toString(),
                        style: TextStyle(fontSize: 20.0),
                      ),
                      Center(
                        child: Text(
                          snapshot.data['deviceAdress'],
                          style: TextStyle(fontSize: 36.0),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  Future<Map<String, dynamic>> _trackLocation() async {
    Position currentPosition = await _determinePosition();
    List<Placemark> adressess = await placemarkFromCoordinates(
        currentPosition.latitude, currentPosition.longitude);
    var pickedAdress = adressess[0];
    var deviceAdress =
        '${pickedAdress.name} ${pickedAdress.street} ${pickedAdress.postalCode} ${pickedAdress.locality} ${pickedAdress.country}';
    print(deviceAdress);
    return {
      "latitude": currentPosition.latitude,
      "longitude": currentPosition.longitude,
      "deviceAdress": deviceAdress
    };
  }

  _queryData() async {
    setState(() {
      locData = _trackLocation();
    });
  }
}
