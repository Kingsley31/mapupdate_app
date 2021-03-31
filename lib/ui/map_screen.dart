

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:location/location.dart';
import 'dart:async';

import 'package:mapupdate_app/view_model/map_screen_view_model.dart';
import 'package:provider/provider.dart';

class MapScreen extends StatefulWidget{
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>{


  @override
  Widget build(BuildContext context) {
    return Container(
      child: Consumer<MapScreenViewModel>(
        builder:(context, mapScreenViewModel, child){
          return GoogleMap(
                onMapCreated: mapScreenViewModel.onMapCreated,
                initialCameraPosition: mapScreenViewModel.getInitialCameraPosition(),
                markers: mapScreenViewModel.markers,
                polylines: mapScreenViewModel.polylines,
                mapType: MapType.normal,
            );
        }

      ),
    );
  }

  @override
  void initState() {
    super.initState();
    MapScreenViewModel mapScreenViewModel = context.read<MapScreenViewModel>();
    mapScreenViewModel.listenForLocationChange();
  }

}