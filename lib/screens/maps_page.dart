import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http; // Import http
import 'dart:convert'; // Import convert cho json

class MapsPage extends StatefulWidget {
  final Function(LatLng, String) onLocationSelected;
  final int? orderId; // Thêm orderId
  final String? destinationAddress; // Thêm địa chỉ đích

  const MapsPage({
    super.key,
    required this.onLocationSelected,
    this.orderId, // Make optional initially, then decide if required
    this.destinationAddress, // Make optional initially, then decide if required
  });

  @override
  MapsPageState createState() => MapsPageState();
}

class MapsPageState extends State<MapsPage> {
  final Completer<GoogleMapController> _mapController = Completer();
  GoogleMapController? _controller;
  LatLng _initialCameraPosition = const LatLng(10.201893, 105.714324); // Sa Đéc
  LatLng? _currentLocation;
  LatLng? _pickedLocation;
  String? _pickedAddress;
  final Set<Marker> _markers = {};
  List<LatLng> _polylineCoordinates = [];
  final PolylinePoints _polylinePoints = PolylinePoints();
  final String? _googleApiKey = dotenv.env['Maps_API_KEY'];
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    // Đảm bảo có API Key trước khi sử dụng
    if (_googleApiKey == null || _googleApiKey!.isEmpty) {
      print("Lỗi: Maps_API_KEY không được cấu hình trong .env");
      // Hiển thị thông báo hoặc xử lý lỗi phù hợp
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lỗi cấu hình: Google Maps API Key không tìm thấy.'),
          ),
        );
      }
    }
    _initializeMapData(); // Gọi hàm khởi tạo dữ liệu bản đồ
  }

  @override
  void dispose() {
    _disposed = true;
    _controller?.dispose();
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

  // Hàm khởi tạo dữ liệu bản đồ (lấy vị trí hiện tại và địa chỉ đích)
  Future<void> _initializeMapData() async {
    await _getCurrentLocation(); // Lấy vị trí hiện tại của người dùng

    if (widget.orderId != null && widget.destinationAddress != null) {
      await _loadDestinationLocation(
        widget.orderId!,
        widget.destinationAddress!,
      );
    } else {
      // Nếu không có địa chỉ đích, có thể chọn vị trí hiện tại làm điểm đến ban đầu
      _safeSetState(() {
        _pickedLocation = _currentLocation ?? _initialCameraPosition;
        _setInitialMarker(_pickedLocation!);
      });
      await _getAddress(_pickedLocation!); // Lấy địa chỉ cho vị trí đã chọn
      _goToLocation(_pickedLocation!); // Di chuyển camera đến vị trí đã chọn
    }
  }

  // Lấy vị trí hiện tại của người dùng
  Future<void> _getCurrentLocation() async {
    // ... (Giữ nguyên code _getCurrentLocation của bạn) ...
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Dịch vụ vị trí bị tắt.')));
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quyền truy cập vị trí bị từ chối.')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
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

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _safeSetState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _initialCameraPosition =
            _currentLocation!; // Cập nhật vị trí camera ban đầu
        _setInitialMarker(
          _currentLocation!,
          title: 'Vị trí hiện tại của bạn',
        ); // Đặt marker cho vị trí hiện tại
      });
      // Không cần goToCurrentLocation ở đây, _initializeMapData sẽ xử lý
    } catch (e) {
      print("Lỗi khi lấy vị trí hiện tại: $e");
      // Vẫn hiển thị marker ban đầu nếu có lỗi, nhưng có thể không chính xác
      _setInitialMarker(
        _initialCameraPosition,
        title: 'Vị trí mặc định ban đầu',
      );
    }
  }

  // Tải vị trí đích từ backend hoặc Geocoding nếu chưa có
  Future<void> _loadDestinationLocation(int orderId, String addressText) async {
    // 1. Cố gắng lấy từ backend
    try {
      final response = await http.get(
        Uri.parse('${dotenv.env['BASE_URL']}/maps/get_location/$orderId'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _safeSetState(() {
          _pickedLocation = LatLng(data['latitude'], data['longitude']);
          _pickedAddress = data['formattedAddress'];
          _markers.clear();
          _markers.add(
            Marker(
              markerId: const MarkerId('destination_location'),
              position: _pickedLocation!,
              infoWindow: InfoWindow(title: _pickedAddress!),
            ),
          );
        });
        _goToLocation(_pickedLocation!); // Di chuyển camera đến vị trí đã lưu
        _drawPolyline(); // Vẽ đường đi nếu có cả current và picked
        print('Đã tải vị trí đích từ DB: $_pickedAddress');
        return; // Đã tìm thấy và xử lý, thoát
      } else if (response.statusCode == 404) {
        print(
          'Vị trí đích cho Order ID $orderId chưa có trong DB. Tiến hành Geocoding...',
        );
        // Tiếp tục xuống bước 2: Geocoding nếu chưa có trong DB
      } else {
        print(
          'Lỗi khi tải vị trí đích từ DB: ${response.statusCode} ${response.body}',
        );
        // Xử lý lỗi, có thể thông báo cho người dùng
      }
    } catch (e) {
      print('Lỗi kết nối khi tải vị trí đích từ DB: $e');
      // Xử lý lỗi kết nối
    }

    // 2. Nếu chưa có trong DB hoặc lỗi khi tải, thực hiện Geocoding
    try {
      List<Location> locations = await locationFromAddress(addressText);
      if (locations.isNotEmpty) {
        final geoLat = locations.first.latitude;
        final geoLng = locations.first.longitude;
        _pickedLocation = LatLng(geoLat, geoLng);

        // Reverse Geocoding để lấy địa chỉ chuẩn hóa từ tọa độ (của Flutter Geocoding)
        List<Placemark> placemarks = await placemarkFromCoordinates(
          geoLat,
          geoLng,
        );
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks.first;
          _pickedAddress =
              '${place.street ?? ''}, ${place.subAdministrativeArea ?? ''}, ${place.administrativeArea ?? ''}, ${place.country ?? ''}';
        } else {
          _pickedAddress =
              addressText; // Fallback nếu không lấy được địa chỉ chuẩn hóa
        }

        _safeSetState(() {
          _markers.clear();
          _markers.add(
            Marker(
              markerId: const MarkerId('destination_location'),
              position: _pickedLocation!,
              infoWindow: InfoWindow(title: _pickedAddress!),
            ),
          );
        });

        _goToLocation(
          _pickedLocation!,
        ); // Di chuyển camera đến vị trí đã Geocoding
        _drawPolyline(); // Vẽ đường đi nếu có cả current và picked

        // 3. Lưu tọa độ vừa Geocoding vào backend
        await _saveLocationToBackend(
          orderId,
          addressText,
          _pickedLocation!,
          _pickedAddress!,
        );
        print('Đã Geocoding và lưu vị trí đích vào DB: $_pickedAddress');
      } else {
        print('Không tìm thấy tọa độ cho địa chỉ: $addressText');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Không tìm thấy tọa độ cho địa chỉ giao hàng.'),
            ),
          );
        }
        // Fallback: nếu không tìm thấy địa chỉ đích, vẫn hiển thị vị trí ban đầu
        _safeSetState(() {
          _pickedLocation = _initialCameraPosition;
          _setInitialMarker(_pickedLocation!);
        });
        await _getAddress(_pickedLocation!);
      }
    } catch (e) {
      print('Lỗi Geocoding hoặc lưu vào backend: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi xử lý địa chỉ giao hàng: $e')),
        );
      }
      // Fallback
      _safeSetState(() {
        _pickedLocation = _initialCameraPosition;
        _setInitialMarker(_pickedLocation!);
      });
      await _getAddress(_pickedLocation!);
    }
  }

  // Hàm để gọi API backend để lưu tọa độ
  Future<void> _saveLocationToBackend(
    int orderId,
    String addressText,
    LatLng location,
    String formattedAddress,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('${dotenv.env['BASE_URL']}/maps/save_location'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'orderId': orderId,
          'addressText': addressText,
          'latitude': location.latitude,
          'longitude': location.longitude,
          'formattedAddress': formattedAddress,
        }),
      );
      if (response.statusCode == 200) {
        print('Lưu vị trí thành công vào backend!');
      } else {
        print(
          'Lỗi khi lưu vị trí vào backend: ${response.statusCode} ${response.body}',
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lỗi khi lưu địa chỉ vào hệ thống.')),
          );
        }
      }
    } catch (e) {
      print('Lỗi kết nối khi lưu vị trí vào backend: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lỗi kết nối khi lưu địa chỉ.')),
        );
      }
    }
  }

  // Đặt marker ban đầu (vị trí hiện tại hoặc vị trí mặc định)
  void _setInitialMarker(LatLng location, {String title = 'Vị trí'}) {
    _markers.add(
      Marker(
        markerId: MarkerId(title),
        position: location,
        infoWindow: InfoWindow(title: title),
      ),
    );
  }

  // Di chuyển camera đến một vị trí cụ thể
  Future<void> _goToLocation(LatLng location) async {
    final GoogleMapController controller = await _mapController.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: location, zoom: 15),
      ),
    );
  }

  // Xử lý sự kiện khi người dùng chọn một vị trí trên bản đồ
  Future<void> _selectLocation(LatLng position) async {
    _pickedLocation = position;
    _markers.clear();
    _markers.add(
      Marker(
        markerId: const MarkerId('selected_location'),
        position: position,
        infoWindow: const InfoWindow(title: 'Vị trí đã chọn'),
      ),
    );
    _polylineCoordinates.clear(); // Xóa polyline cũ
    await _getAddress(position); // Gọi _getAddress để lấy địa chỉ
    _safeSetState(() {});
    _drawPolyline(); // Vẽ lại đường đi sau khi chọn vị trí mới
  }

  Future<void> _getAddress(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        _pickedAddress =
            '${place.street ?? ''}, ${place.subAdministrativeArea ?? ''}, ${place.administrativeArea ?? ''}, ${place.country ?? ''}';
      } else {
        _pickedAddress = 'Không tìm thấy địa chỉ';
      }
    } catch (e) {
      _pickedAddress = 'Lỗi khi lấy địa chỉ';
      print('Lỗi Geocoding (frontend): $e');
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

    // Đảm bảo _googleApiKey đã được tải
    if (_googleApiKey == null || _googleApiKey!.isEmpty) {
      print("Lỗi: Không có Maps_API_KEY để vẽ đường đi.");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lỗi: Thiếu Google Maps API Key để vẽ đường đi.'),
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
      // Căn chỉnh camera để hiển thị toàn bộ đường đi
      _fitMapToRoute();
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

  // Căn chỉnh camera để hiển thị toàn bộ đường đi
  void _fitMapToRoute() {
    if (_polylineCoordinates.isEmpty) return;

    double minLat = _polylineCoordinates.first.latitude;
    double maxLat = _polylineCoordinates.first.latitude;
    double minLng = _polylineCoordinates.first.longitude;
    double maxLng = _polylineCoordinates.first.longitude;

    for (var point in _polylineCoordinates) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    _controller?.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        100.0, // padding
      ),
    );
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
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
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
                    if (_currentLocation != null && _pickedLocation != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: ElevatedButton(
                          onPressed: _drawPolyline,
                          child: const Text('Vẽ đường đi từ vị trí hiện tại'),
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
