import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MapsPage extends StatefulWidget {
  final Function(LatLng, String) onLocationSelected;

  MapsPage({required this.onLocationSelected});

  @override
  MapsPageState createState() => MapsPageState();
}

class MapsPageState extends State<MapsPage> {
  GoogleMapController? _controller;
  final Completer<GoogleMapController> _mapController = Completer();

  LatLng _initialCameraPosition = LatLng(10.201893, 105.714324); // Sa Đéc
  LatLng? _currentLocation;
  LatLng? _pickedLocation;
  String? _pickedAddress;
  Set<Marker> _markers = {};
  List<LatLng> _polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();

  final String? _googleApiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Kiểm tra xem dịch vụ vị trí có được bật không.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Nếu dịch vụ vị trí bị tắt, hãy yêu cầu người dùng bật.
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Dịch vụ vị trí bị tắt.')));
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Quyền bị từ chối, thông báo cho người dùng.
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Quyền truy cập vị trí bị từ chối.')));
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Quyền bị từ chối vĩnh viễn, hướng dẫn người dùng bật thủ công.
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Quyền truy cập vị trí bị từ chối vĩnh viễn, vui lòng bật trong cài đặt.')));
      return;
    }

    // Khi có quyền, lấy vị trí hiện tại.
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _initialCameraPosition = _currentLocation!;
        _goToCurrentLocation();
        _setInitialMarker(_currentLocation!);
      });
    } catch (e) {
      print("Lỗi khi lấy vị trí hiện tại: $e");
      _setInitialMarker(_initialCameraPosition); // Vẫn hiển thị marker ban đầu nếu lỗi
    }
  }

  void _setInitialMarker(LatLng location) {
    _markers.add(
      Marker(
        markerId: MarkerId('current_location'),
        position: location,
        infoWindow: InfoWindow(title: 'Vị trí hiện tại của bạn'),
      ),
    );
  }

  Future<void> _goToCurrentLocation() async {
    final GoogleMapController controller = await _mapController.future;
    await controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: _currentLocation ?? _initialCameraPosition,
        zoom: 15,
      ),
    ));
  }

  Future<void> _selectLocation(LatLng position) async {
    _pickedLocation = position;
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
        // localeIdentifier: 'vi_VN',
      );
      if (placemarks.isNotEmpty) {
        final Placemark place = placemarks.first;
        _pickedAddress =
        '${place.street ?? ''}, ${place.subAdministrativeArea ?? ''}, ${place.administrativeArea ?? ''}';
      } else {
        _pickedAddress = 'Không tìm thấy địa chỉ';
      }
    } catch (e) {
      _pickedAddress = 'Lỗi khi lấy địa chỉ';
      print('Lỗi geocoding: $e');
    }

    setState(() {
      _markers.clear(); // Xóa marker cũ
      _markers.add(
        Marker(
          markerId: MarkerId('selected_location'),
          position: position,
          infoWindow: InfoWindow(title: _pickedAddress ?? 'Vị trí đã chọn'),
        ),
      );
      _polylineCoordinates.clear(); // Xóa polyline cũ khi chọn vị trí mới
    });
  }

  void _drawPolyline() async {
    if (_currentLocation != null && _pickedLocation != null) {
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey: _googleApiKey!,
        request: PolylineRequest(
          origin:  PointLatLng(_currentLocation!.latitude, _currentLocation!.longitude),
          destination:  PointLatLng(_pickedLocation!.latitude, _pickedLocation!.longitude),
          mode: TravelMode.driving,
        ),

      );

      if (result.points.isNotEmpty) {
        setState(() {
          _polylineCoordinates = result.points
              .map((p) => LatLng(p.latitude, p.longitude))
              .toList();
        });
      } else {
        print("Không tìm thấy đường đi: ${result.errorMessage}");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Google Maps"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _initialCameraPosition,
              zoom: 14.0,
            ),
            onMapCreated: (controller) {
              _mapController.complete(controller);
              _controller = controller;
            },
            markers: _markers,
            polylines: {
              Polyline(
                polylineId: PolylineId("route"),
                points: _polylineCoordinates,
                color: Colors.blue,
                width: 5,
              ),
            },
            onTap: _selectLocation,
            myLocationEnabled: true, // Hiển thị vị trí hiện tại của người dùng
            myLocationButtonEnabled: true, // Nút để di chuyển đến vị trí hiện tại
          ),
          if (_pickedLocation != null)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      _pickedAddress ?? 'Đang lấy địa chỉ...',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (_pickedLocation != null && _pickedAddress != null) {
                          widget.onLocationSelected(_pickedLocation!, _pickedAddress!);
                          Navigator.pop(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Vui lòng chọn một vị trí trên bản đồ')),
                          );
                        }
                      },
                      child: Text('Xác nhận vị trí'),
                    ),
                    if (_currentLocation != null && _pickedLocation != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: ElevatedButton(
                          onPressed: _drawPolyline,
                          child: Text('Vẽ đường đi'),
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}