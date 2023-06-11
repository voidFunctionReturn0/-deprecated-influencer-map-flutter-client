import 'dart:io';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:influencer_map/models/content.dart';
import 'package:influencer_map/models/influencer.dart';
import 'package:influencer_map/models/place.dart';
import 'package:influencer_map/models/version.dart';
import 'package:latlong2/latlong.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'constants.dart' as constants;
import 'package:http/http.dart' as http;

String notionFkToString(String notionFk) {
  return notionFk.replaceAll(RegExp('[-]'), '');
}

LatLng getLatLngFromContent(Content content, List<Place> places) {
  Place place = places.where((place) => place.id == content.place).first;

  return LatLng(place.centerLat, place.centerLon);
}

Influencer getInfluencerFromContent(
    Content content, List<Influencer> influencers) {
  Influencer influencer = influencers
      .where((influencer) => influencer.id == content.influencer)
      .first;

  return influencer;
}

Place getPlaceFromContent(Content content, List<Place> places) {
  Place place = places.firstWhere((place) => place.id == content.place);

  return place;
}

Place getPlaceById(String id, List<Place> places) {
  Place place = places.firstWhere((place) => place.id == id);
  return place;
}

List<Content> getContentsFromPlace(Place place, List<Content> contents) {
  List<Content> placeContents =
      contents.where((content) => content.place == place.id).toList();

  return placeContents;
}

LatLng downLatNkm(LatLng latLng, double distance) {
  return LatLng(
      latLng.latitude - (distance * constants.lat1km), latLng.longitude);
}

String googleRatingToStars(double? googleRating) {
  String rtn = "";

  if (googleRating! < 0.5) {
    rtn = "☆☆☆☆☆";
  } else if (googleRating < 1.5) {
    rtn = "★☆☆☆☆";
  } else if (googleRating < 2.5) {
    rtn = "★★☆☆☆";
  } else if (googleRating < 3.5) {
    rtn = "★★★☆☆";
  } else if (googleRating < 4.5) {
    rtn = "★★★★☆";
  } else {
    rtn = "★★★★★";
  }

  return rtn;
}

class FloatingButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData iconData;
  final constants.ButtonShape shape;

  const FloatingButton(
      {Key? key,
      required this.onTap,
      required this.iconData,
      required this.shape})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
          width: 56,
          height: 56,
          decoration: (shape == constants.ButtonShape.rectangle)
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                  boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        spreadRadius: 3,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ])
              : (shape == constants.ButtonShape.circle)
                  ? BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            spreadRadius: 3,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ])
                  : throw "### Button Shape Error",
          child: Icon(
            iconData,
            color: Colors.black,
          )),
    );
  }
}

String getYoutubeEmbedUrl(String videoId) {
  return 'https://www.youtube.com/embed/$videoId';
}

void launchNaverMap(String keyword) async {
  Uri appUrl = Uri.parse('nmap://search?query=$keyword');
  Uri webUrl =
      Uri.parse('https://m.map.naver.com/search2/search.naver?query=$keyword');

  if (await canLaunchUrl(appUrl)) {
    if (!await launchUrl(appUrl)) {
      throw Exception('Could not launch ${appUrl.toString()}');
    }
  } else {
    if (!await launchUrl(webUrl)) {
      throw Exception('Could not launch ${webUrl.toString()}');
    }
  }
}

String getPlaceIdFromPath(String path) {
  return path.substring(7);
}

Future<String> getMinVersion(constants.OS os) async {
  String osString = (os == constants.OS.aos)
      ? 'aos'
      : (os == constants.OS.ios)
          ? 'ios'
          : throw '## os string error';

  final url = Uri.parse(
      'http://${constants.host}:${constants.port}/min-version/$osString');
  final response = await http.get(url);
  return response.body;
}

Future<bool> neededUpdate() async {
  String? minVersionString;
  if (Platform.isAndroid) {
    minVersionString = await getMinVersion(constants.OS.aos);
  } else if (Platform.isIOS) {
    minVersionString = await getMinVersion(constants.OS.ios);
  } else {
    throw '## Error: failed to get platform version';
  }

  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  Version minVersion = Version(minVersionString);
  Version currentVersion = Version(packageInfo.version);

  if (currentVersion.major > minVersion.major) {
    return false;
  } else if (currentVersion.major == minVersion.major) {
    if (currentVersion.minor > minVersion.minor) {
      return false;
    } else if (currentVersion.minor == minVersion.minor) {
      if (currentVersion.patch >= minVersion.patch) {
        return false;
      } else {
        return true;
      }
    } else {
      return true;
    }
  } else {
    return true;
  }
}
