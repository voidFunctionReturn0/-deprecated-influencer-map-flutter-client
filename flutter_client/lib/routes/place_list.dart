import 'package:flutter/material.dart';
import 'package:influencer_map/res/text_styles.dart';
import 'package:influencer_map/src/common.dart';
import '../models/content.dart';
import '../models/influencer.dart';
import '../models/place.dart';
import '../src/constants.dart' as constants;
import 'package:latlong2/latlong.dart';

class PlaceList extends StatelessWidget {
  final List<Influencer> influencers;
  final List<Place> places;
  final List<Content> contents;
  final Function(LatLng, {double zoomLevel}) setHomeMapCenter;
  final LatLng currentLocation;

  const PlaceList({
    super.key,
    required this.influencers,
    required this.places,
    required this.contents,
    required this.setHomeMapCenter,
    required this.currentLocation,
  });

  @override
  Widget build(BuildContext context) {
    const Distance distance = Distance();
    places.sort((a, b) {
      return distance(currentLocation, LatLng(a.centerLat, a.centerLon))
          .compareTo(
              distance(currentLocation, LatLng(b.centerLat, b.centerLon)));
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView.builder(
        itemCount: places.length,
        itemBuilder: (BuildContext context, int index) {
          var placeContents = getContentsFromPlace(places[index], contents);

          if (placeContents.isNotEmpty) {
            String videoId = placeContents.first.videoId;
            return SizedBox(
              height: 88,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  setHomeMapCenter(
                    LatLng(places[index].centerLat, places[index].centerLon),
                    zoomLevel: constants.mapZoomForPlace,
                  );
                  Navigator.pop(context);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  child: Row(
                    children: [
                      Image.network(
                        constants.youtubeThumbnailUriStart +
                            videoId +
                            constants.youtubeThumbnailUriEnd,
                        width: 114,
                        height: 64,
                        fit: BoxFit.cover,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 12,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                places[index].name,
                                style: MyTextStyles.medium,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                places[index].address,
                                style: MyTextStyles.regular.copyWith(
                                  color: Colors.grey,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return const SizedBox();
          }
        },
      ),
    );
  }
}
