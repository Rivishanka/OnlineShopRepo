import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

//Resuable map screen to view the location selected by admin or user
//APIs => Maps API and Places API from Google
class MallLocatorMap extends StatefulWidget {
  MallLocatorMap({Key key, this.title, this.longitude, this.latitude, this.locationName}) : super(key: key);
  final String title;
  final double longitude;
  final double latitude;
  final String locationName;

  @override
  _MallLocatorMapState createState() => _MallLocatorMapState();
}

class _MallLocatorMapState extends State<MallLocatorMap> {
  Completer<GoogleMapController> _googleMapController = Completer();
  //GoogleMapController _googleMapController;
  static LatLng _center;
  Set<Marker> _markers = {};
  String _title;
  double _longitude;
  double _latitude;
  String _locationName;
  static String kGoogleApiKey = "AIzaSyBMNXK98PInVNh3qXKOu4SRTaxoy3SBBdw";
  GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);
  String _placeId;


  @override
  void initState() {
    _title= widget.title;
    _longitude= widget.longitude;
    _latitude= widget.latitude;
    _center = LatLng(_latitude, _longitude);
    _locationName = widget.locationName;
    super.initState();
  }

  void _onMapCreated(GoogleMapController controller) {
    _googleMapController.complete(controller);
    //_googleMapController = controller;
  }

  void navigate(double latitude, double longitude) async{
    final mapUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(mapUrl)){
      await launch(mapUrl);
    } else {
      throw 'Could not load';
    }
  }

  void refresh(){
    //final center = await getUserLocation();

    //_googleMapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: _center, zoom: 15.0)));
    getNearbyMalls();
  }

  void getNearbyMalls() async{
    final location = Location(_center.latitude, _center.longitude);
    final result = await _places.searchNearbyWithRadius(location, 500, type: "shopping_mall");
    //BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue)
    setState(() {
      //_markers = null;
      if(result.status == "OK"){
        places = result.results;
        places.forEach((f){
          _markers.add(
              Marker(
                  markerId: MarkerId(f.id),
                  position: LatLng(f.geometry.location.lat, f.geometry.location.lng),
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
                  infoWindow: InfoWindow(
                      title: f.name,
                      snippet: f.vicinity
                  ),
                  onTap: () {
                    setState(() {
                      _placeId = f.placeId;
                    });
                    _showNearByLocationDetailsSheet(context, _placeId);
                  }
              )
          );
        });
      }
    });
  }

  Widget locationPhoto(BuildContext context, String reference) {
    String photoUrl = _places.buildPhotoUrl(photoReference: reference);
    return Image.network(
      photoUrl,
    );
  }

  _showNearByLocationDetailsSheet(BuildContext context, String placeId) async{
    //final location = Location(_center.latitude, _center.longitude);
    var result;
    try {
      result = await _places.getDetailsByPlaceId(placeId);
    }catch(e){
      throw e;
    }

    showModalBottomSheet(
        context: context,
        builder: (context) => Container(
          //constraints: BoxConstraints(maxHeight: 600, maxWidth: 100),
          height: 300,
          color: Colors.white,
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.my_location, color: Colors.indigo[600],),
                title: Text("Shopping Mall: " + result.result.name),
              ),
              ListTile(
                leading: Icon(Icons.place, color: Colors.indigo[600]),
                title: Text("Address: " + result.result.vicinity,),
              ),
              ListTile(
                leading: Icon(Icons.featured_video, color: Colors.indigo[600]),
                title: Text("Type: " + result.result.types[0]),
              ),
            ] ,
          ),
        ));
  }

  _showDetailsSheet(BuildContext context) async{
    Position position = Position(latitude:_center.latitude, longitude: _center.longitude);
    List<Placemark> placemark = await Geolocator().placemarkFromCoordinates(_center.latitude, _center.longitude);
    showModalBottomSheet(
        context: context,
        builder: (context) => Container(
          height: 300,
          color: Colors.white,
          child: new Column(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.my_location),
                title: Text("Shopping Mall: " + _locationName),
              ),
              ListTile(
                leading: Icon(Icons.place),
                title: Text("Address: " + placemark[0].thoroughfare),
              ),
              ListTile(
                leading: Icon(Icons.landscape),
                title: Text(placemark[0].subLocality),
              ),
              ListTile(
                leading: Icon(Icons.crop_landscape),
                title: Text(placemark[0].administrativeArea),
              ),
              ListTile(
                leading: Icon(Icons.local_post_office),
                title: Text(placemark[0].postalCode),
              ),
            ] ,
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      _markers.add(
          Marker(
              markerId: MarkerId(_locationName),
              position: _center,
              icon: BitmapDescriptor.defaultMarker,
              infoWindow: InfoWindow(
                title: _locationName,
              ),
              onTap: (){
                //_showDetailsSheet(context);
              }
          )
      );
    });

    return Scaffold(
        appBar: AppBar(
          title: Text('Polestar MAP'),
          backgroundColor: Colors.indigo[600],
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.location_searching),
              onPressed: (){
                Navigator.pop(
                  context,
                  //MaterialPageRoute(builder: (context) => AdminMenu(title: 'Admin Menu')),
                );
              },)
          ],
        ),
        body: Stack(
          children: <Widget>[
            GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 15.0,
              ),
              markers: _markers,

            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.topRight,
                child: FloatingActionButton(
                  onPressed: (){
                    //navigate(_latitude, _longitude);
                    refresh();
                  },
                  shape: CircleBorder(),
                  materialTapTargetSize: MaterialTapTargetSize.padded,
                  backgroundColor: Colors.indigo[400],
                  child: const Icon(Icons.open_in_new, size: 20.0),
                  tooltip: 'Open in Google Maps',
                ),
              ),
            ),
          ],
        )



    );
  }

}