import 'package:rumo/core/utils/string_utils.dart';
import 'package:rumo/features/diary/models/place_address.dart';

class Place {
  final double latitude;
  final double longitude;
  final String name;
  final PlaceAddress? address;

  Place({
    required this.latitude,
    required this.longitude,
    required this.name,
    this.address,
  });

  String get formattedLocation {
    String placeName = name.isNotEmpty ? name : '';

    if(address == null) return placeName;

    if(address!.road.isNotEmpty) {
      placeName += ' - ${address!.road}';
    }

    if(address!.city.isNotEmpty) {
      placeName += ' - ${address!.city}';
    }

    if(address!.state.isNotEmpty) {
      placeName += ' - ${address!.state}';
    }

    if(address!.country.isNotEmpty) {
      placeName += ' - ${address!.country}';
    }

    return placeName;
  }

  factory Place.fromJson(Map<String, dynamic> json) {
    final lat = json['lat'] as String?;
    final lon = json['lon'] as String?;
    return Place(
      latitude: lat?.toDouble() ?? 0,
      longitude: lon?.toDouble() ?? 0,
      name: json['name'] ?? '',
      address: json['address'] != null
          ? PlaceAddress.fromJson(json['address'])
          : null,
    );
  }

  static List<Place> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => Place.fromJson(json)).toList();
  }
}