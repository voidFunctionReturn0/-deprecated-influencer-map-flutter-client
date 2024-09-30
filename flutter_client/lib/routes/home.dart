import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:geolocator/geolocator.dart';
import 'package:influencer_map/models/t_map_place.dart';
import 'package:influencer_map/models/influencer.dart';
import 'package:influencer_map/routes/place.dart';
// import 'package:influencer_map/routes/place_list.dart';
// import 'package:influencer_map/routes/search_result.dart';
import 'package:latlong2/latlong.dart';
import 'package:influencer_map/src/constants.dart' as constants;
import '../models/place.dart';
import '../models/content.dart';
import '../res/colors.dart';
import '../res/lat_lngs.dart';
import '../res/strings.dart';
import '../res/text_styles.dart';
import '../src/common.dart';
// import 'inquirt.dart';
// import 'oss_licenses.dart';

class Home extends StatefulWidget {
  final List<Influencer> influencers;
  final List<Place> places;
  final List<Content> contents;

  const Home({
    super.key,
    required this.influencers,
    required this.places,
    required this.contents,
  });

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _mapController = MapController();
  final PopupController _popupController = PopupController();
  final textEditingController = TextEditingController();
  LatLng? _mapCenter;
  final List<Marker> markers = [];
  final List<Marker> searchResultMarker = [];
  late double deviceWidth;
  late double deviceHeight;
  late double statusHeight;
  bool isShownCurrentPosition = false;
  bool get isShownCurrentLocation => isShownCurrentPosition;
  late AlignOnUpdate followOnLocationUpdate;
  late StreamController<double?> _followCurrentLocationStreamController;

  @override
  void initState() {
    _setMarkers();
    followOnLocationUpdate = AlignOnUpdate.never;
    _followCurrentLocationStreamController = StreamController<double?>();
    super.initState();
  }

  void _setMarkers() {
    for (var content in widget.contents) {
      LatLng latLng = getLatLngFromContent(content, widget.places);

      if (_isExistSameLatLng(latLng, markers)) {
        continue;
      }

      Influencer influencer =
          getInfluencerFromContent(content, widget.influencers);
      Place place = getPlaceFromContent(content, widget.places);
      List<Content> placeContents = getContentsFromPlace(place, widget.contents)
        ..sort((a, b) => a.name.compareTo(b.name));

      markers.add(
        Marker(
          point: latLng,
          height: 100,
          width: 400,
          child: GestureDetector(
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  padding: const EdgeInsets.all(1),
                  decoration: const BoxDecoration(
                      color: MyColors.primary, shape: BoxShape.circle),
                  child: ClipOval(
                    child: influencer.profileImage,
                  ),
                ),
                Positioned(
                  top: 42,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black26),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8))),
                    child: Text(
                      "${place.name} ★${place.googleRating}",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                        fontWeight: FontWeight.normal,
                        decoration: TextDecoration.none, // 노란 밑줄 삭제
                      ),
                    ),
                  ),
                ),
              ],
            ),
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
              showBottomSheet(
                context: context,
                builder: (context) {
                  return PlacePage(
                    influencers: widget.influencers,
                    influencer: influencer,
                    place: place,
                    content: content,
                    placeContents: placeContents,
                  );
                },
              );
            },
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    _followCurrentLocationStreamController.close();
    super.dispose();
  }

  bool _isExistSameLatLng(LatLng latLng, List<Marker> markers) {
    for (Marker marker in markers) {
      if (_isEqual(marker.point, latLng)) {
        return true;
      }
    }
    return false;
  }

  _isEqual(LatLng latLng1, LatLng latLng2) {
    if ((latLng1.latitude == latLng2.latitude) &&
        (latLng1.longitude == latLng2.longitude)) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    // var theme = Theme.of(context);
    deviceWidth = mediaQuery.size.width;
    deviceHeight = mediaQuery.size.height;
    statusHeight = mediaQuery.viewPadding.top;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Builder(builder: (context) {
        return FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _mapCenter ?? MyLatLngs.seoul,
            initialZoom: constants.mapZoomDefault,
            minZoom: 0,
            maxZoom: 19,
            interactionOptions: InteractionOptions(),
            onTap: (_, __) => _popupController.hideAllPopups(),
          ),
          // nonRotatedChildren: [
          //   // SearchBar
          //   Positioned(
          //     top: 16 + statusHeight,
          //     child: SizedBox(
          //       width: deviceWidth,
          //       child: Padding(
          //         padding: const EdgeInsets.symmetric(horizontal: 16),
          //         child: DecoratedBox(
          //           decoration: BoxDecoration(
          //             color: theme.scaffoldBackgroundColor,
          //             borderRadius: BorderRadius.circular(8),
          //             boxShadow: const [
          //               BoxShadow(
          //                 color: MyColors.shadow,
          //                 blurRadius: 8,
          //                 offset: Offset(0, 4),
          //               ),
          //             ],
          //           ),
          //           child: Padding(
          //             padding: const EdgeInsets.symmetric(horizontal: 4),
          //             child: TextField(
          //               controller: textEditingController,
          //               textInputAction: TextInputAction.search,
          //               decoration: const InputDecoration(
          //                 hintText: '위치 검색',
          //                 hintStyle: TextStyle(
          //                   color: MyColors.lightGrey,
          //                 ),
          //                 border: InputBorder.none,
          //                 icon: Padding(
          //                   padding: EdgeInsets.all(8),
          //                   child: Icon(
          //                     Icons.search,
          //                     size: 24,
          //                   ),
          //                 ),
          //               ),
          //               onSubmitted: (value) async {
          //                 // setFollowOnLocationUpdateToNever();
          //                 Navigator.push(
          //                   context,
          //                   MaterialPageRoute(
          //                     builder: (context) => SearchResult(
          //                       searchKeyword: value,
          //                       setHomeMapCenter: setHomeMapCenter,
          //                       setSearchResultMarker: setSearchResultMarker,
          //                       containsSameLocationInPlaces:
          //                           containsSameLocationInPlaces,
          //                       influencers: widget.influencers,
          //                       places: widget.places,
          //                       contents: widget.contents,
          //                     ),
          //                   ),
          //                 );
          //                 textEditingController.clear();
          //               },
          //             ),
          //           ),
          //         ),
          //       ),
          //     ),
          //   ),
          //   // Floating Buttons
          //   Positioned(
          //     bottom: 16,
          //     right: 16,
          //     child: Wrap(
          //       direction: Axis.vertical,
          //       spacing: 16,
          //       children: [
          //         FloatingButton(
          //           onTap: () {
          //             setSearchResultMarker(null);
          //             moveToCurrentLocation(_mapController);
          //           },
          //           iconData: Icons.my_location,
          //           shape: constants.ButtonShape.rectangle,
          //         ),
          //         FloatingButton(
          //           onTap: () {
          //             Navigator.push(
          //               context,
          //               MaterialPageRoute(
          //                 builder: (context) => PlaceList(
          //                   influencers: widget.influencers,
          //                   places: widget.places,
          //                   contents: widget.contents,
          //                   setHomeMapCenter: setHomeMapCenter,
          //                   currentLocation: _mapController.center,
          //                 ),
          //               ),
          //             );
          //           },
          //           iconData: Icons.format_list_bulleted,
          //           shape: constants.ButtonShape.rectangle,
          //         ),
          //         FloatingButton(
          //           onTap: () {
          //             Navigator.push(
          //               context,
          //               MaterialPageRoute(
          //                 builder: (context) => Inquiry(),
          //               ),
          //             );
          //           },
          //           iconData: Icons.support_agent,
          //           shape: constants.ButtonShape.circle,
          //         ),
          //       ],
          //     ),
          //   ),
          //   Positioned(
          //     bottom: 16,
          //     left: 16,
          //     child: GestureDetector(
          //       onTap: () {
          //         Navigator.push(
          //             context,
          //             MaterialPageRoute(
          //                 builder: (context) => const OssLicensesPage()));
          //       },
          //       child: const Icon(
          //         Icons.info,
          //         size: 20,
          //       ),
          //     ),
          //   )
          // ],
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png?',
              userAgentPackageName: 'influencer-map',
              maxZoom: 19,
            ),
            getCurrentLocationLayer(),
            MarkerClusterLayerWidget(
              options: MarkerClusterLayerOptions(
                spiderfyCircleRadius: 80,
                spiderfySpiralDistanceMultiplier: 2,
                circleSpiralSwitchover: 12,
                maxClusterRadius: 120,
                rotate: true,
                size: const Size(72, 72),
                alignment: Alignment.center,
                maxZoom: 15,
                padding: EdgeInsets.all(50),
                markers: markers,
                polygonOptions: const PolygonOptions(
                    borderColor: MyColors.primary,
                    color: Colors.black12,
                    borderStrokeWidth: 3),
                popupOptions: PopupOptions(
                    popupSnap: PopupSnap.markerTop,
                    popupController: _popupController,
                    popupBuilder: (_, marker) => Container(
                          width: 200,
                          height: 100,
                          color: Colors.white,
                          child: GestureDetector(
                            onTap: () => debugPrint("Popup tap!"),
                            child: Text(
                              "Container popup for marker at ${marker.point}",
                            ),
                          ),
                        )),
                builder: (context, markers) {
                  return Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        width: 2,
                        color: Colors.white,
                        style: BorderStyle.solid,
                      ),
                      color: MyColors.primary70percent,
                    ),
                    child: Center(
                      child: Text(
                        markers.length.toString(),
                        style: MyTextStyles.big.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            MarkerLayer(markers: searchResultMarker),
          ],
        );
      }),
    );
  }

  void setHomeMapCenter(LatLng latLng,
      {double zoomLevel = constants.mapZoomDefault}) {
    if (mounted) {
      setState(() {
        _mapController.move(latLng, zoomLevel);
      });
    }
  }

  void setSearchResultMarker(TMapPlace? searchResult) {
    searchResultMarker.clear();

    if (searchResult != null) {
      searchResultMarker.add(
        Marker(
          point: LatLng(searchResult.centerLat, searchResult.centerLon),
          width: 400,
          height: 70,
          child: Column(
            children: [
              const Icon(Icons.location_on,
                  size: 36,
                  // fill: ,
                  color: MyColors.primary),
              Text(
                searchResult.name,
                style: MyTextStyles.regular,
                overflow: TextOverflow.visible,
              ),
            ],
          ),
        ),
      );
    }

    if (mounted) {
      setState(() {});
    }
  }

  bool containsSameLocationInPlaces(LatLng location) {
    for (Place place in widget.places) {
      if (place.centerLat == location.latitude &&
          place.centerLon == location.longitude) {
        return true;
      }
    }
    return false;
  }

  void showPlace(Uri deepLink, BuildContext context) {
    String placeId = getPlaceIdFromPath(deepLink.path);
    Place place = getPlaceById(placeId, widget.places);
    List<Content> placeContents = getContentsFromPlace(place, widget.contents)
      ..sort((a, b) => a.name.compareTo(b.name));
    Content content = placeContents.first;
    Influencer influencer =
        getInfluencerFromContent(content, widget.influencers);

    setHomeMapCenter(
      downLatNkm(LatLng(place.centerLat, place.centerLon), 0.05),
      zoomLevel: constants.mapZoomForPlace,
    );

    showBottomSheet(
      context: context,
      builder: (context) {
        return PlacePage(
          influencers: widget.influencers,
          influencer: influencer,
          place: place,
          content: content,
          placeContents: placeContents,
        );
      },
    );
  }

  Future<void> moveToCurrentLocation(MapController mapController) async {
    LocationPermission permission;
    bool serviceEnabled;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('### Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // 권한 허용 필요하다고 안내하기
      return Future.error(
          '### Location permissions are permanently denied, we cannot request permissions.');
    }

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled && mounted) {
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text(MyStrings.locationFunctionNeeded),
          content: const Text(MyStrings.turnOnLocationFunctionInSettings),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(MyStrings.later),
            ),
            TextButton(
              onPressed: () {
                Geolocator.openLocationSettings();
                Navigator.pop(context);
              },
              child: const Text(MyStrings.goToSettings),
            ),
          ],
        ),
      );
      return Future.error('### Location services are disabled.');
    }

    setState(() {
      isShownCurrentPosition = true;
    });

    Position position = await Geolocator.getCurrentPosition();

    mapController.move(LatLng(position.latitude, position.longitude),
        constants.mapZoomDefault);
  }

  Widget getCurrentLocationLayer() {
    if (isShownCurrentLocation == true) {
      return CurrentLocationLayer(
        alignPositionStream: _followCurrentLocationStreamController.stream,
        alignPositionOnUpdate: followOnLocationUpdate,
      );
    } else {
      return const SizedBox();
    }
  }
}
