import 'package:flutter/material.dart';

// Dart
import 'dart:async';

// API Google Maps Flutter
import 'package:google_maps_flutter/google_maps_flutter.dart';

// Flutter Maps
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

// Utils
import 'package:book_suggester/utils/router.dart';

// todo
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';

class GetLocationView extends StatefulWidget {
  const GetLocationView({super.key});
  @override
  State<GetLocationView> createState() => _GetLocationViewState();
}

class _GetLocationViewState extends State<GetLocationView> {
  final Completer<GoogleMapController> _controller = Completer();
  final _routerController = RouterWidget();

  static const CameraPosition _myPlace = CameraPosition(
      target: LatLng(-5.088544046019581, -42.81123803149089), zoom: 14);

  final List<Marker> _markers = <Marker>[];
  final List<LatLng> _ranges = <LatLng>[];

  final _polygons = <Polygon>{};
  final _polylines = <Polyline>{};

  double? lat;
  double? lng;
  String? myLocation = "...";
  List<String?> myPlaceStats = [];

  List<dynamic> nearbyPlaces = [];

  final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];

  final _locationController = TextEditingController();

  Position? _capturedPosition;

  int? radius;

  /*
    // todo: 
    "pos" can be acquired throught "then" after using 
    getUserCurrenntLocation().then((value)
  */
  Future<void> searchNearbyPlaces(
      Position? pos, List<String> placeType, String location) async {
    if (pos == null) return;

    final String url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?'
        'location=${pos.latitude},${pos.longitude}'
        '&radius=${placeType[1]}'
        '&type=${placeType[0]}'
        '&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          setState(() {
            // todo: all queries from the search are placed here
            nearbyPlaces = data['results'] as List;

            // todo: and iterated
            for (var place in nearbyPlaces) {
              String? isPlaceOpen;
              if (place['opening_hours']?['open_now'] != null) {
                isPlaceOpen =
                    place['opening_hours']?['open_now'] ? 'aberto' : 'fechado';
              } else {
                isPlaceOpen = 'não classificado';
              }

              _markers.add(Marker(
                  markerId: MarkerId('place_${_markers.length}'),
                  position: LatLng(place['geometry']['location']['lat'] ?? 0.0,
                      place['geometry']['location']['lng'] ?? 0.0),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueGreen),
                  infoWindow: InfoWindow(
                      title: place['name'],
                      snippet: isPlaceOpen,
                      onTap: () async {
                        List<Placemark> placemark =
                            await placemarkFromCoordinates(
                                place['geometry']['location']['lat'] ?? 0.0,
                                place['geometry']['location']['lng'] ?? 0.0);
                        String foundPlaceLocation =
                            getLocationString(placemark);
                        // Show it in a sort of banner
                        showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                                title: const Text('Sobre o local:'),
                                content: Text(foundPlaceLocation)));
                      })));
            }
          });
        }
      }
    } catch (e) {
      print('Erro ao buscar lugares próximos: $e');
    }
  }

  void setupPolyline() {
    setState(() {
      _ranges.clear();
      _polylines.clear();

      // Check for at least two markers
      if (_markers.length >= 2) {
        // Add the position of each marker into the LatLng array
        for (var marker in _markers) {
          _ranges
              .add(LatLng(marker.position.latitude, marker.position.longitude));
        }

        // Make a polyline out of them and place into the set of polylines
        _polylines.add(Polyline(
            polylineId:
                PolylineId('polyline_${DateTime.now().millisecondsSinceEpoch}'),
            points: _ranges,
            color: const Color.fromARGB(255, 33, 66, 99),
            width: 2));
      }
    });
  }

  void setupPolygon() {
    setState(() {
      _ranges.clear();
      _polygons.clear();

      // Check for at least three markers
      if (_markers.length >= 3) {
        // Add the position of each marker into the LatLng array
        for (var marker in _markers) {
          _ranges
              .add(LatLng(marker.position.latitude, marker.position.longitude));
        }

        // Make a polygon out of them and place into the set of polygons
        _polygons.add(Polygon(
            polygonId: PolygonId(_markers[_markers.length - 1].toString()),
            points: _ranges,
            fillColor: Colors.black.withOpacity(0.5),
            geodesic: true,
            strokeColor: const Color.fromARGB(255, 33, 66, 99),
            strokeWidth: 1));
      }
    });
  }

  Future<Position> getUserCurrenntLocation() async {
    await Geolocator.requestPermission()
        .then((value) {})
        .onError((error, stackTrace) {
      print('===== ERRO =====\n${error.toString()}');
    });
    return await Geolocator.getCurrentPosition();
  }

  void renderLocation() {
    getUserCurrenntLocation().then((value) async {
      CameraPosition cameraPosition = CameraPosition(
          zoom: 14, target: LatLng(value.latitude, value.longitude));

      final GoogleMapController controller = await _controller.future;

      controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

      lat = value.latitude;
      lng = value.longitude;
      _capturedPosition = value;

      List<Placemark> placemark = await placemarkFromCoordinates(lat!, lng!);

      setState(() {
        // All data from your location as string
        myLocation = getLocationString(placemark);

        // Add user's last location to the list of markers
        _markers.add(Marker(
            markerId: MarkerId(_markers.length.toString()),
            position: LatLng(value.latitude, value.longitude),
            infoWindow: InfoWindow(
                title: 'clique p/ expandir',
                onTap: () {
                  // Show it in a sort of banner
                  showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                          title: const Text('Sobre o local:'),
                          content: Text(myLocation!)));
                })));
      });

      // searchNearbyPlaces(value, 'library', myLocation!);
    });
  }

  String getLocationString(List<Placemark> placemarkInstance) {
    List<String?> myPlaceStats = [
      placemarkInstance.first.name,
      placemarkInstance.first.street,
      placemarkInstance.first.locality,
      placemarkInstance.first.subLocality,
      placemarkInstance.first.postalCode,
      placemarkInstance.first.country,
      placemarkInstance.first.isoCountryCode,
      placemarkInstance.first.administrativeArea,
      placemarkInstance.first.subAdministrativeArea,
      placemarkInstance.first.thoroughfare,
      placemarkInstance.first.subThoroughfare,
    ];

    return myPlaceStats.join(' ');
  }

  @override
  void initState() {
    super.initState();
    renderLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Upper area
      appBar: AppBar(
        // toolbarHeight: 50,
        backgroundColor: const Color.fromARGB(255, 99, 33, 66),
        actions: [
          // tag: Search bar
          SizedBox(
            height: 40,
            width: 250,
            child: TextField(
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "ex: library",
                  filled: true,
                  fillColor: Color.fromARGB(255, 22, 22, 44),
                  labelStyle: TextStyle(color: Colors.white)),
              controller: _locationController,
            ),
          ),
          const SizedBox(width: 3),

          // tag: Return previous page
          IconButton(
              style: IconButton.styleFrom(backgroundColor: Colors.white),
              icon: const Icon(Icons.logout),
              onPressed: () {
                _routerController.redirect('user-panel', context);
              }),
        ],
      ),
      body: Stack(
        children: [
          // tag: Map
          GoogleMap(
            initialCameraPosition: _myPlace,
            markers: Set<Marker>.of(_markers),
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            polygons: _polygons,
            polylines: _polylines,
            // POF: Create new mark and put in the map
            onTap: (argument) async {
              lat = argument.latitude;
              lng = argument.longitude;

              List<Placemark> placemark =
                  await placemarkFromCoordinates(lat!, lng!);

              String tappedLocation = getLocationString(placemark);

              final newMarker = Marker(
                  markerId: MarkerId(_markers[_markers.length - 1].toString()),
                  position: argument,
                  infoWindow: InfoWindow(
                      title: 'clique p/ expandir',
                      onTap: () {
                        // Show it in a sort of banner
                        showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                                title: const Text('Sobre o local:'),
                                content: Text(tappedLocation)));
                      }),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueAzure));

              setState(() {
                _markers.add(newMarker);
              });
            },
          ),
          // tag: Book floating button
          Positioned(
              top: 10,
              left: 10,
              child: FloatingActionButton(
                  onPressed: () {
                    searchNearbyPlaces(
                        _capturedPosition, ['library', '1500'], myLocation!);
                  },
                  tooltip: 'bibliotecas próximas (até 1.5km)',
                  child: const Icon(Icons.book))),
          // tag: Plus button
          Positioned(
            top: 5,
            right: 5,
            child: FloatingActionButton(
                onPressed: () {
                  setState(() {
                    if (radius == null) {
                      radius = 0;
                      radius = radius! + 500;
                    } else {
                      radius = radius! + 500;
                    }
                  });
                },
                backgroundColor: const Color.fromARGB(255, 150, 33, 66),
                foregroundColor: Colors.white,
                mini: true,
                tooltip: 'raio + 500 metros',
                child: const Icon(Icons.add)),
          ),
          // tag: Minus button
          Positioned(
            top: 50,
            right: 5,
            child: FloatingActionButton(
              onPressed: () {
                setState(() {
                  if (radius != null && radius! > 500) {
                    radius = radius! - 500;
                  }
                });
              },
              backgroundColor: const Color.fromARGB(255, 150, 33, 66),
              foregroundColor: Colors.white,
              mini: true,
              tooltip: 'raio - 500 metros',
              child: const Icon(Icons.remove),
            ),
          ),

          // tag: Current radius
          Positioned(
            top: 100,
            right: 5,
            child: TextButton(
                style: TextButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 150, 33, 66)),
                onPressed: () {
                  radius = 0;
                },
                child: Text('${radius ?? '0 metros'}',
                    style: const TextStyle(color: Colors.amber))),
          ),

          // tag: Polyline creation trigger
          Positioned(
            bottom: 0,
            left: 5,
            child: TextButton(
              style: TextButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 150, 33, 66)),
              onPressed: () {
                setupPolyline();
              },
              child: const Text(
                'rotas',
                style: TextStyle(color: Colors.amber, fontSize: 10),
              ),
            ),
          ),

          // tag: Polygon creation trigger
          Positioned(
              bottom: 50,
              left: 5,
              child: TextButton(
                style: TextButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 150, 33, 66)),
                onPressed: () {
                  setupPolygon();
                },
                child: const Text(
                  'polígono',
                  style: TextStyle(color: Colors.amber, fontSize: 10),
                ),
              ))
        ],
      ),
      // Lower area
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          searchNearbyPlaces(_capturedPosition,
              // _locationController.text.split('.'), myLocation!);
              [_locationController.text, '$radius'], myLocation!);
          // renderLocation();
        },
        child: const Icon(Icons.search),
      ),
    );
  }
}
