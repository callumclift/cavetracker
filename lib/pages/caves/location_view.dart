import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import '../../shared/global_config.dart';

class LocationView extends StatefulWidget {

  final String latitude;
  final String longitude;
  final bool cave;

  LocationView(this.latitude, this.longitude, this.cave);

  @override
  State<LocationView> createState() => LocationViewState();
}

class LocationViewState extends State<LocationView> {
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = {};
  Key _directionsKey = Key('directions');
  Key _mapTypeKey = Key('mapType');
  String selectedLat;
  String selectedLong;
  CameraPosition _initialCameraPosition;
  MapType mapType = MapType.hybrid;



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _setUpInitialCameraPosition();
  }



  _setUpInitialCameraPosition(){
    _initialCameraPosition = CameraPosition(
      target: LatLng(double.parse(widget.latitude), double.parse(widget.longitude)),
      zoom: 15.4746,
    );
  }


  _handleTap(LatLng point) {
    setState(() {
      _markers.clear();
      _markers.add(Marker(
        markerId: MarkerId(point.toString()),
        position: point,
        infoWindow: InfoWindow(
          title: widget.cave ? 'Cave Location' : 'Parking Location',
        ),
        icon:
        BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ));
      selectedLat = point.latitude.toString();
      selectedLong = point.longitude.toString();
    });
  }

  _loadInitialMarker(){
      LatLng latLng = LatLng(double.parse(widget.latitude), double.parse(widget.longitude));
      setState(() {
        _markers.add(Marker(
          markerId: MarkerId(latLng.toString()),
          position: latLng,
          infoWindow: InfoWindow(
            title: widget.cave ? 'Cave Location' : 'Parking Location',
          ),
          icon:
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ));
      });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(backgroundColor: whiteGreen,
      appBar: AppBar(backgroundColor: mintGreen, iconTheme: IconThemeData(color: darkBlue),
        title: Text(widget.cave ? 'Cave Map' : 'Parking Map', style: TextStyle(color: darkBlue, fontWeight: FontWeight.bold),),),
      body: Stack(
        children: [
          GoogleMap(
            markers: Set<Marker>.of(_markers),

            myLocationButtonEnabled: false,
            mapType: mapType,
            initialCameraPosition: _initialCameraPosition,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              _loadInitialMarker();
              print(_markers.length);
            },
            onTap: _handleTap,
          ),
          Positioned(
            left: Platform.isAndroid ? 5 : null,
            top:50,
            right: Platform.isAndroid ? null : 5,
            child: Column(children: <Widget>[
              Container(padding: EdgeInsets.all(10), child: FloatingActionButton(heroTag: null, key: _directionsKey,backgroundColor: Colors.white,onPressed: _goToCurrentLocation,
                child: Icon(Icons.location_searching, color: Colors.grey,),),),
              Container(padding: EdgeInsets.all(10), child: FloatingActionButton(heroTag: null, key: _mapTypeKey,backgroundColor: Colors.white,onPressed: _changeMapType,
                child: Icon(Icons.layers, color: Colors.grey,),),),
            ],),)
        ],
      ),
    );
  }

  _changeMapType(){
    setState(() {
      mapType = mapType == MapType.normal? MapType.hybrid : MapType.normal;
    });
  }

  Future<void> _goToCurrentLocation() async {
    final GoogleMapController controller = await _controller.future;
    Location location = new Location();
    LocationData currentLocation = await location.getLocation();
    if (currentLocation.latitude != null &&
        currentLocation.longitude != null){
      controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(currentLocation.latitude, currentLocation.longitude),
        zoom: 15.4746,
      )));


    }
  }
}