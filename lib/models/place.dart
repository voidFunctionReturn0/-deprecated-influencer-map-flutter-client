import 'package:flutter/cupertino.dart';

class Place {
  final String id;
  final String name;
  final double? googleRating;
  final int? googleUserRatingsTotal;
  // final List<String>? categories;  // 참고: https://stackoverflow.com/questions/74009138/creating-multi-select-tags-via-notion-api
  final String address;
  final double centerLat;
  final double centerLon;
  final String? phone;

  Place({
    required this.id,
    required this.name,
    this.googleRating,
    this.googleUserRatingsTotal,
    // this.categories,
    required this.address,
    required this.centerLat,
    required this.centerLon,
    this.phone,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id'] as String,
      name: json['name'] as String,
      googleRating: (json['googleRating'] as num).toDouble(),
      googleUserRatingsTotal: json['googleUserRatingsTotal'] as int,
      // categories: json['categories'] as List<String>,
      address: json['address'] as String,
      centerLat: json['centerLat'] as double,
      centerLon: json['centerLon'] as double,
      phone: json['phone'] as String?,
    );
  }
}
