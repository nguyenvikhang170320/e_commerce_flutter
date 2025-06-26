import 'package:flutter/foundation.dart';
import 'package:app_ecommerce/services/location_service.dart'; // hoặc đường dẫn tương ứng

class LocationProvider with ChangeNotifier {
  String? currentLocation;
  final LocationService _locationService = LocationService();

  Future<void> fetchCurrentLocation() async {
    try {
      final location = await _locationService.fetchLocationAsString();
      if (location != null) {
        currentLocation = location;
        print("📍 Lấy được vị trí mới từ LocationService: $location");
        notifyListeners();
      } else {
        print("❌ Không lấy được vị trí từ LocationService");
      }
    } catch (e) {
      print("⚠ Lỗi từ LocationProvider: $e");
    }
  }
}
