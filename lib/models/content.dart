import 'package:flutter/cupertino.dart';
import 'package:influencer_map/src/common.dart';
import '../src/constants.dart' as constants;

class Content {
  final String id;
  final String name;
  final String videoId;
  final String place;
  final String influencer;

  Content({
    required this.id,
    required this.name,
    required this.videoId,
    required this.place,
    required this.influencer,
  });

  factory Content.fromJson(Map<String, dynamic> json) {
    return Content(
      id: json['id'] as String,
      name: json['name'] as String,
      videoId: urlToVideoId(json['sourceUrl'] as String),
      place: notionFkToString(json['place'] as String),
      influencer: notionFkToString(json['influencer'] as String),
    );
  }
}

String urlToVideoId(String url) {
  String videoId = "";
  String urlStyle1 = "https://youtu.be/";
  String urlStyle2 = "https://www.youtube.com/watch?v=";

  if (url.startsWith(urlStyle1)) {
    videoId = url.substring(17);
  } else if (url.startsWith(urlStyle2)) {
    videoId = url.substring(32, 43);
  }

  return videoId;
}
