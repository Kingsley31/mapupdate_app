
import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:mapupdate_app/constants/google_map_constants.dart';

class MapScreenViewModel extends ChangeNotifier{

  LatLng _SOURCE_LOCATION = LatLng(5.516829,7.518261);
  
  void setSourceLocation({LatLng position}) => {_SOURCE_LOCATION=position};
  LatLng _DEST_LOCATION = LatLng(5.503818,7.487297);
  void setDestinationLocation({LatLng position}) => {_DEST_LOCATION=position};

  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = Set<Marker>();

  Set<Polyline> _polylines = Set<Polyline>();
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints= PolylinePoints();

  BitmapDescriptor sourceIcon;
  BitmapDescriptor destinationIcon;

  LocationData currentLocation;
  LocationData destinationLocation;
  final Location location =  new Location();

  void setSourceAndDestinationIcons() async {
    sourceIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/driving_pin.png');

    destinationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/destination_map_marker.png');
  }

  void listenForLocationChange(){

    location.onLocationChanged().listen((LocationData cLoc) {
      currentLocation = cLoc;
      updatePinOnMap();
      print("locatin updated");
    });

    setSourceAndDestinationIcons();

  }

  CameraPosition getInitialCameraPosition(){
    CameraPosition initialCameraPosition = CameraPosition(
        zoom: GoogleMapConstants.CAMERA_ZOOM,
        tilt: GoogleMapConstants.CAMERA_TILT,
        bearing: GoogleMapConstants.CAMERA_BEARING,
        target: _SOURCE_LOCATION);
    if (currentLocation != null) {
      initialCameraPosition = CameraPosition(
          target: LatLng(currentLocation.latitude, currentLocation.longitude),
          zoom: GoogleMapConstants.CAMERA_ZOOM,
          tilt: GoogleMapConstants.CAMERA_TILT,
          bearing: GoogleMapConstants.CAMERA_BEARING);
    }

    return initialCameraPosition;
  }

  void showPinsOnMap() async{
    currentLocation = await location.getLocation();
    var pinPosition;
    if(currentLocation==null){
      currentLocation = await location.getLocation();
      pinPosition = LatLng(_SOURCE_LOCATION.latitude, _SOURCE_LOCATION.longitude);
    }else{
      pinPosition=LatLng(currentLocation.latitude, currentLocation.longitude);
    }

    destinationLocation = LocationData.fromMap({
      "latitude": _DEST_LOCATION.latitude,
      "longitude": _DEST_LOCATION.longitude
    });


    // get a LatLng out of the LocationData object
    var destPosition =
    LatLng(destinationLocation.latitude, destinationLocation.longitude);

    // add the initial source location pin
    _markers.add(Marker(
        markerId: MarkerId('sourcePin'),
        position: pinPosition,
        onTap: () {
        },
        icon: sourceIcon
    ));
    // destination pin
    _markers.add(Marker(
        markerId: MarkerId('destPin'),
        position: destPosition,
        onTap: () {
        },
        icon: destinationIcon
    ));
    // set the route lines on the map from source to destination
    // for more info follow this tutorial
    setPolylines();
  }

  void setPolylines() async {
    List<PointLatLng> result = await polylinePoints.getRouteBetweenCoordinates(
       GoogleMapConstants.GOOGLE_API_KEY,
        currentLocation.latitude,
        currentLocation.longitude,
        destinationLocation.latitude,
        destinationLocation.longitude);

    if (result.isNotEmpty) {
      result.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });

      _polylines.add(Polyline(
          width: 8, // set the width of the polylines
          polylineId: PolylineId("poly"),
          color: GoogleMapConstants.POLYLINE_COLOR,
          points: polylineCoordinates));

    }
    notifyListeners();
  }

  void updatePinOnMap() async {

    CameraPosition cPosition = CameraPosition(
      zoom: GoogleMapConstants.CAMERA_ZOOM,
      tilt: GoogleMapConstants.CAMERA_TILT,
      bearing: GoogleMapConstants.CAMERA_BEARING,
      target: LatLng(currentLocation.latitude, currentLocation.longitude),
    );
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));
    // do this inside the setState() so Flutter gets notified
    // that a widget update is due

      // updated position
      var pinPosition =
      LatLng(currentLocation.latitude, currentLocation.longitude);

      //sourcePinInfo.location = pinPosition;

      // the trick is to remove the marker (by id)
      // and add it again at the updated location
      _markers.removeWhere((m) => m.markerId.value == 'sourcePin');
      _markers.add(Marker(
          markerId: MarkerId('sourcePin'),
          onTap: () {
            // setState(() {
            //   currentlySelectedPin = sourcePinInfo;
            //   pinPillPosition = 0;
            // });
          },
          position: pinPosition, // updated position
          icon: sourceIcon
      ));
      notifyListeners();
  }

  get polylines => _polylines;

  get markers => _markers;

  void onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
    showPinsOnMap();
  }


}