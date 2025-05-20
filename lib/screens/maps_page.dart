import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MapsPage extends StatefulWidget {
  final Function(LatLng, String) onLocationSelected;

  const MapsPage({super.key, required this.onLocationSelected});

  @override
  MapsPageState createState() => MapsPageState();
}

class MapsPageState extends State<MapsPage> {
  // Completer để lấy GoogleMapController sau khi bản đồ được tạo
  final Completer<GoogleMapController> _mapController = Completer();
  GoogleMapController? _controller; // Thêm biến này
  // Vị trí ban đầu của bản đồ (có thể là một vị trí mặc định hoặc vị trí hiện tại)
  LatLng _initialCameraPosition = const LatLng(10.201893, 105.714324); // Sa Đéc
  // Vị trí hiện tại của người dùng
  LatLng? _currentLocation;
  // Vị trí được chọn trên bản đồ
  LatLng? _pickedLocation;
  // Địa chỉ của vị trí được chọn
  String? _pickedAddress;
  // Tập hợp các markers trên bản đồ
  final Set<Marker> _markers = {};
  // Danh sách các điểm để vẽ đường đi
  List<LatLng> _polylineCoordinates = [];
  // Đối tượng để lấy thông tin đường đi
  final PolylinePoints _polylinePoints = PolylinePoints();
  // Khóa API Google Maps (được tải từ .env)
  final String? _googleApiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _disposed = true;
    _controller?.dispose(); // Dispose controller
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    if (!_mapController.isCompleted) {
      _mapController.complete(controller);
    }
    _controller = controller;
  }

  void _safeSetState(VoidCallback fn) {
    if (!_disposed && mounted) {
      setState(fn);
    }
  }

  // Lấy vị trí hiện tại của người dùng
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Kiểm tra xem dịch vụ vị trí có được bật không.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Nếu dịch vụ vị trí bị tắt, hiển thị thông báo lỗi.
      if (!mounted) return; // Check mounted
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Dịch vụ vị trí bị tắt.')));
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Quyền bị từ chối, hiển thị thông báo lỗi.
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quyền truy cập vị trí bị từ chối.')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Quyền bị từ chối vĩnh viễn, hiển thị thông báo lỗi và hướng dẫn người dùng.
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Quyền truy cập vị trí bị từ chối vĩnh viễn, vui lòng bật trong cài đặt.',
          ),
        ),
      );
      return;
    }

    // Lấy vị trí hiện tại.
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _safeSetState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _initialCameraPosition = _currentLocation!;
        _setInitialMarker(_currentLocation!);
      });
      _goToCurrentLocation(); // Gọi hàm này để di chuyển đến vị trí hiện tại
    } catch (e) {
      print("Lỗi khi lấy vị trí hiện tại: $e");
      _setInitialMarker(
        _initialCameraPosition,
      ); // Vẫn hiển thị marker ban đầu nếu có lỗi
    }
  }

  // Đặt marker ban đầu (vị trí hiện tại)
  void _setInitialMarker(LatLng location) {
    _markers.add(
      Marker(
        markerId: const MarkerId('current_location'),
        position: location,
        infoWindow: const InfoWindow(title: 'Vị trí hiện tại của bạn'),
      ),
    );
  }

  // Di chuyển camera đến vị trí hiện tại
  Future<void> _goToCurrentLocation() async {
    final GoogleMapController controller = await _mapController.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: _currentLocation ?? _initialCameraPosition,
          zoom: 15,
        ),
      ),
    );
  }

  // Xử lý sự kiện khi người dùng chọn một vị trí trên bản đồ
  Future<void> _selectLocation(LatLng position) async {
    _pickedLocation = position;
    _markers.clear(); // Clear previous markers
    _markers.add(
      Marker(
        markerId: const MarkerId('selected_location'),
        position: position,
        infoWindow: const InfoWindow(title: 'Vị trí đã chọn'),
      ),
    );
    _polylineCoordinates.clear(); // Clear polyline
    _getAddress(position); // Gọi _getAddress để lấy địa chỉ
    _safeSetState(() {}); // Cập nhật giao diện sau khi thay đổi
  }

  Future<void> _getAddress(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
        // localeIdentifier: 'vi_VN', // tùy chọn, có thể gây lỗi nếu thiết bị không hỗ trợ
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        _pickedAddress =
            '${place.street ?? ''}, ${place.subAdministrativeArea ?? ''}, ${place.administrativeArea ?? ''}';
      } else {
        _pickedAddress = 'Không tìm thấy địa chỉ';
      }
    } catch (e) {
      _pickedAddress = 'Lỗi khi lấy địa chỉ';
      print('Lỗi Geocoding: $e');
    }
    _safeSetState(() {});
  }

  // Vẽ đường đi giữa vị trí hiện tại và vị trí đã chọn
  void _drawPolyline() async {
    if (_currentLocation == null || _pickedLocation == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng chọn vị trí hiện tại và vị trí đến.'),
          ),
        );
      }
      return;
    }

    PolylineResult result = await _polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: _googleApiKey!,
      request: PolylineRequest(
        origin: PointLatLng(
          _currentLocation!.latitude,
          _currentLocation!.longitude,
        ),
        destination: PointLatLng(
          _pickedLocation!.latitude,
          _pickedLocation!.longitude,
        ),
        mode: TravelMode.driving,
      ),
    );

    if (result.points.isNotEmpty) {
      _safeSetState(() {
        _polylineCoordinates =
            result.points.map((p) => LatLng(p.latitude, p.longitude)).toList();
      });
    } else {
      print("Không tìm thấy đường đi: ${result.errorMessage}");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Không tìm thấy đường đi: ${result.errorMessage ?? 'Lỗi không xác định'}',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Google Maps"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            // Cung cấp controller cho GoogleMap
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _initialCameraPosition,
              zoom: 14.0,
            ),
            markers: _markers,
            polylines: {
              Polyline(
                polylineId: const PolylineId("route"),
                points: _polylineCoordinates,
                color: Colors.blue,
                width: 5,
              ),
            },
            onTap: _selectLocation,
            myLocationEnabled: true, // Hiển thị vị trí hiện tại của người dùng
            myLocationButtonEnabled:
                true, // Nút để di chuyển đến vị trí hiện tại
          ),
          // Hiển thị thông tin vị trí đã chọn và nút xác nhận
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
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (_pickedLocation != null && _pickedAddress != null) {
                          widget.onLocationSelected(
                            _pickedLocation!,
                            _pickedAddress!,
                          );
                          Navigator.pop(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Vui lòng chọn một vị trí trên bản đồ',
                              ),
                            ),
                          );
                        }
                      },
                      child: const Text('Xác nhận vị trí'),
                    ),
                    if (_currentLocation != null &&
                        _pickedLocation != null) // Thêm điều kiện
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: ElevatedButton(
                          onPressed: _drawPolyline,
                          child: const Text('Vẽ đường đi'),
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
