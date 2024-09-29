import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/influencer.dart';
import '../models/content.dart';
import '../models/place.dart';
import '../models/t_map_place.dart';
import '../res/colors.dart';
import '../res/textStyles.dart';
import '../src/constants.dart' as constants;
import 'package:latlong2/latlong.dart';

import '../src/common.dart';

class SearchResult extends StatefulWidget {
  final Function(LatLng) setHomeMapCenter;
  final Function(TMapPlace) setSearchResultMarker;
  final Function(LatLng) containsSameLocationInPlaces;
  final List<Influencer> influencers;
  final List<Place> places;
  final List<Content> contents;

  SearchResult({
    super.key,
    required this.setHomeMapCenter,
    required this.setSearchResultMarker,
    required this.containsSameLocationInPlaces,
    required this.influencers,
    required this.places,
    required this.contents,
  });

  @override
  State<SearchResult> createState() => _SearchResultState();
}

class _SearchResultState extends State<SearchResult> {
  String searchKeyword = "";
  List<TMapPlace> tMapPlaces = [];
  var textEditingController = TextEditingController();

  Map<String, String> headers = {
    'Accept': 'application/json',
    'appKey': dotenv.env['TMAP_APP_KEY']!
  };

  @override
  void initState() {
    super.initState();
    textEditingController.text = searchKeyword;
  }

  Future<void> loadTMapPlaces() async {
    await searchTMapPlace(searchKeyword).then((data) {
      tMapPlaces = data;
    });
    setState(() {});
  }

  Future<List<TMapPlace>> searchTMapPlace(String searchKeyword) async {
    final response = await http.get(
        Uri(
            scheme: 'https',
            host: 'apis.openapi.sk.com',
            path: '/tmap/pois',
            queryParameters: {
              'version': '1',
              'searchKeyword': searchKeyword,
            }),
        headers: headers);

    if (response.statusCode == constants.HTTP_STATUS_OK) {
      return _parseTMapPlaces(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('#### Faild to load TMapPlaces, ${response.statusCode}');
    }
  }

  List<TMapPlace> _parseTMapPlaces(String responseBody) {
    final parsed = json.decode(responseBody)['searchPoiInfo']['pois']['poi'];
    return parsed.map<TMapPlace>((json) => TMapPlace.fromJson(json)).toList();
  }

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    double deviceHeight = MediaQuery.of(context).size.height;

    loadTMapPlaces();

    return Material(
      child: SafeArea(
        child: Container(
          width: deviceWidth,
          height: deviceHeight,
          color: Colors.white,
          child: Column(
            children: [
              Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(8),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.search,
                                  size: 24,
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 4),
                                  child: TextField(
                                    controller: textEditingController,
                                    textInputAction: TextInputAction.search,
                                    decoration: const InputDecoration(
                                      hintText: "위치 검색",
                                      hintStyle: TextStyle(
                                        color: Color(0xffB3B0B2),
                                      ),
                                      border: InputBorder.none,
                                    ),
                                    onSubmitted: (value) {
                                      searchKeyword = value;
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Expanded(
                      //   child: TextField(
                      //     controller: textEditingController,
                      //     textInputAction: TextInputAction.search,
                      //     decoration: const InputDecoration(
                      //       hintText: "위치 검색",
                      //       hintStyle: TextStyle(
                      //         color: Color(0xffB3B0B2),
                      //       ),
                      //       border: InputBorder.none,
                      //       icon: Padding(
                      //         padding: EdgeInsets.all(8),
                      //         child: Icon(
                      //           Icons.search,
                      //           size: 24,
                      //         ),
                      //       ),
                      //     ),
                      //     onSubmitted: (value) {
                      //       widget.searchKeyword = value;
                      //     },
                      //   ),
                      // ),
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(12),
                            child: Center(child: Icon(Icons.close)),
                          ),
                        ),
                      )
                    ],
                  )),
              Results(
                tMapPlaces: tMapPlaces,
                setHomeMapCenter: widget.setHomeMapCenter,
                setSearchResultMarker: widget.setSearchResultMarker,
                containsSameLocationInPlaces:
                    widget.containsSameLocationInPlaces,
                influencers: widget.influencers,
                places: widget.places,
                contents: widget.contents,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Results extends StatelessWidget {
  final Function(LatLng) setHomeMapCenter;
  final Function(TMapPlace) setSearchResultMarker;
  final Function(LatLng) containsSameLocationInPlaces;
  final List<Influencer> influencers;
  final List<Place> places;
  final List<Content> contents;
  final List<TMapPlace> tMapPlaces;

  Results({
    super.key,
    required this.tMapPlaces,
    required this.setHomeMapCenter,
    required this.setSearchResultMarker,
    required this.containsSameLocationInPlaces,
    required this.influencers,
    required this.places,
    required this.contents,
  });

  @override
  Widget build(BuildContext context) {
    if (tMapPlaces.isEmpty) {
      return Expanded(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: Wrap(
              spacing: 20,
              direction: Axis.vertical,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.grey,
                  weight: 100,
                ),
                Text(
                  '검색 결과가 없어요.\n다른 검색어를 입력해주세요.',
                  style: MyTextStyles.medium.copyWith(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Expanded(
        child: ListView(
          children: [
            for (var result in tMapPlaces)
              ListTile(
                leading: getInfluencerProfile(
                    LatLng(result.centerLat, result.centerLon)),
                title: Text(result.name),
                subtitle: Text(
                  '${result.upperAddrName} ${result.middleAddrName} ${result.lowerAddrName} ${result.detailAddrName}',
                ),
                // subtitleTextStyle: const TextStyle(
                //   color: Colors.grey,
                // ),
                onTap: () {
                  if (!containsSameLocationInPlaces(
                      LatLng(result.centerLat, result.centerLon))) {
                    setSearchResultMarker(result);
                  }
                  setHomeMapCenter(LatLng(result.centerLat, result.centerLon));
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      );
    }
  }

  Widget? getInfluencerProfile(LatLng location) {
    List<Content> locationContents = getContentsFromLocation(location);

    if (locationContents.isEmpty) {
      return null;
    } else {
      return Container(
        width: 52,
        height: 52,
        padding: const EdgeInsets.all(1),
        decoration: const BoxDecoration(
            color: MyColors.primary, shape: BoxShape.circle),
        child: ClipOval(
          child: getInfluencerFromContent(locationContents.first, influencers)
              .profileImage,
        ),
      );
    }
  }

  List<Content> getContentsFromLocation(LatLng location) {
    List<Content> locationContents = [];

    for (var content in contents) {
      Place contentPlace = getPlaceFromContent(content, places);
      if ((contentPlace.centerLat == location.latitude) &
          (contentPlace.centerLon == location.longitude)) {
        locationContents.add(content);
      }
    }

    return locationContents;
  }
}
