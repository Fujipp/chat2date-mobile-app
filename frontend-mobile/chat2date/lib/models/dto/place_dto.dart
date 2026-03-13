class PlaceDTO {
  final String name;
  final String address;
  final String imageUrl;
  final String googlePlaceId;
  final double latitude;
  final double longitude;

  PlaceDTO({
    required this.name,
    required this.address,
    required this.imageUrl,
    required this.googlePlaceId,
    required this.latitude,
    required this.longitude,
  });

  factory PlaceDTO.fromJson(Map<String, dynamic> json) {
    return PlaceDTO(
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      googlePlaceId: json['googlePlaceId'] ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  // Helper สำหรับแปลงไปใช้กับวงล้อ SpinWheel
  Map<String, dynamic> toWheelPrize() {
    return {
      "name": name,
      "imageUrl": imageUrl,
      "address": address,
      "lat": latitude,
      "lng": longitude,
    };
  }
}