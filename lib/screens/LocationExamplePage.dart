import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:geocoding/geocoding.dart' as geocoding;

class MapWithDestinationPage extends StatefulWidget {
  final String destinationAddress;

  const MapWithDestinationPage({
    Key? key,
    required this.destinationAddress,
  }) : super(key: key);

  @override
  _MapWithDestinationPageState createState() => _MapWithDestinationPageState();
}

class _MapWithDestinationPageState extends State<MapWithDestinationPage> {
  final loc.Location _location = loc.Location();
  loc.LocationData? _currentLocation;
  GoogleMapController? _mapController;
  LatLng? _destination;

  bool _isMapReady = false; // Kiểm tra map đã ready chưa

  @override
  void initState() {
    super.initState();
    _initCoordinates();
    _initLocation();
  }

  // Lấy LatLng từ địa chỉ
  Future<LatLng> getLatLngFromAddress(String address) async {
    List<geocoding.Location> locations = await geocoding.locationFromAddress(address);
    if (locations.isNotEmpty) {
      return LatLng(locations.first.latitude, locations.first.longitude);
    }
    throw Exception("Không tìm thấy tọa độ từ địa chỉ");
  }

  Future<void> _initCoordinates() async {
    try {
      _destination = await getLatLngFromAddress(widget.destinationAddress);
      if (mounted) setState(() {});
    } catch (e) {
      print("Lỗi lấy tọa độ destination: $e");
    }
  }

  Future<void> _initLocation() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) serviceEnabled = await _location.requestService();

    loc.PermissionStatus permissionGranted = await _location.hasPermission();
    if (permissionGranted == loc.PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
    }

    if (!serviceEnabled || permissionGranted != loc.PermissionStatus.granted) return;

    _currentLocation = await _location.getLocation();
    if (mounted) setState(() {});

    _location.onLocationChanged.listen((newLoc) {
      if (!mounted) return;
      setState(() => _currentLocation = newLoc);

      if (_mapController != null && _isMapReady) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(newLoc.latitude!, newLoc.longitude!),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Chờ cả currentLocation và destination load xong
    if (_currentLocation == null || _destination == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Bản đồ')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Bản đồ + Điểm đến')),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
          zoom: 15,
        ),
        markers: _buildMarkers(),
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        onMapCreated: (controller) {
          _mapController = controller;
          _isMapReady = true;
        },
      ),
    );
  }

  Set<Marker> _buildMarkers() {
    final markers = <Marker>{};

    if (_currentLocation != null) {
      markers.add(
        Marker(
          markerId: MarkerId('currentLocation'),
          position: LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
          infoWindow: InfoWindow(title: 'Bạn đang ở đây'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }

    if (_destination != null) {
      markers.add(
        Marker(
          markerId: MarkerId('destination'),
          position: _destination!,
          infoWindow: InfoWindow(title: 'Điểm đến đặt hàng'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }

    return markers;
  }
}
