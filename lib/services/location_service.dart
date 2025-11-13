// import 'package:geolocator/geolocator.dart';
//
// class LocationService {
//   Future<Position?> fetchLocationAsString() async {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) return null;
//
//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
//         return null;
//       }
//     }
//
//     // Lấy vị trí hiện tại
//     return await Geolocator.getCurrentPosition(); // không cần truyền gì
//   }
// }

import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Lấy vị trí hiện tại dưới dạng Position
  Future<Position?> fetchCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("❌ Dịch vụ GPS chưa bật");
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        print("❌ Quyền truy cập vị trí bị từ chối");
        return null;
      }
    }

    try {
      final locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high, // Hoặc bestForNavigation
        distanceFilter: 10, // Chỉ cập nhật khi di chuyển > 10m
      );

      final position = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );

      return position;
    } catch (e) {
      print("⚠ Lỗi khi lấy vị trí: $e");
      return null;
    }
  }

  /// Lấy vị trí dưới dạng String "lat,lng"
  Future<String?> fetchLocationAsString() async {
    final position = await fetchCurrentPosition();
    if (position != null) {
      return "${position.latitude},${position.longitude}";
    }
    return null;
  }
}

