import 'package:flutter/cupertino.dart';
import '../src/constants.dart' as constants;

class Influencer {
  final String id;
  final String name;
  final constants.Platform platform;
  final Image profileImage;

  Influencer(
      {required this.id,
      required this.name,
      required this.platform,
      required this.profileImage});

  factory Influencer.fromJson(Map<String, dynamic> json) {
    return Influencer(
        id: json['id'] as String,
        name: json['name'] as String,
        platform: constants.Platform.youtube,
        // platform: json['platform'] as constants.Platform,
        profileImage: Image.network(json['profileImage'] as String));
  }
}
