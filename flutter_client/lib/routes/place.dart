import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:influencer_map/models/content.dart';
import 'package:influencer_map/models/influencer.dart';
import 'package:influencer_map/models/place.dart';
import 'package:influencer_map/res/colors.dart';
import 'package:influencer_map/res/text_styles.dart';
import 'package:influencer_map/src/common.dart';
import 'package:intl/intl.dart';
import 'package:influencer_map/src/constants.dart' as constants;
import 'package:kakao_flutter_sdk_share/kakao_flutter_sdk_share.dart' as kakao;
// import 'package:share_plus/share_plus.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
// import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class PlacePage extends StatefulWidget {
  const PlacePage({
    super.key,
    required this.influencers,
    required this.influencer,
    required this.place,
    required this.content,
    required this.placeContents,
  });

  final List<Influencer> influencers;
  final Influencer influencer;
  final Place place;
  final Content content;
  final List<Content> placeContents;

  @override
  State<PlacePage> createState() => _PlacePageState();
}

class _PlacePageState extends State<PlacePage> {
  late YoutubePlayerController _youtubePlayerController;

  @override
  void initState() {
    _youtubePlayerController = YoutubePlayerController.fromVideoId(
      videoId: widget.placeContents.first.videoId,
      autoPlay: false,
      params: const YoutubePlayerParams(showFullscreenButton: true),
    );

    // YoutubePlayerController _youtubePlayerController = YoutubePlayerController(
    //   initialVideoId: widget.placeContents.first.videoId,
    //   flags: const YoutubePlayerFlags(
    //     autoPlay: false,
    //   ),
    // );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    double deviceWidth = mediaQuery.size.width;
    double deviceHeight = mediaQuery.size.height;

    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          onPanStart: (_) {
            Navigator.pop(context);
          },
          child: Container(
            width: deviceWidth,
            height: deviceHeight,
            decoration: BoxDecoration(color: Colors.black.withOpacity(0)),
          ),
        ),
        Positioned(
          bottom: 0,
          child: Container(
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 36,
                  width: deviceWidth,
                  child: Center(
                    child: Container(
                      width: 32,
                      height: 4,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(100)),
                    ),
                  ),
                ),
                Wrap(
                  direction: Axis.vertical,
                  crossAxisAlignment: WrapCrossAlignment.start,
                  spacing: 12,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Wrap(
                        direction: Axis.vertical,
                        crossAxisAlignment: WrapCrossAlignment.start,
                        spacing: 8,
                        children: [
                          Text(
                            widget.place.name,
                            style: MyTextStyles.medium,
                          ),
                          Wrap(
                            spacing: 4,
                            children: [
                              Text(
                                widget.place.googleRating.toString(),
                                style: MyTextStyles.regular
                                    .copyWith(color: MyColors.primary),
                              ),
                              Text(
                                googleRatingToStars(widget.place.googleRating),
                                style: MyTextStyles.regular
                                    .copyWith(color: MyColors.primary),
                              ),
                              Text(
                                "(Google 리뷰 ${NumberFormat('###,###,###,###').format(widget.place.googleUserRatingsTotal)})",
                                style: MyTextStyles.regular
                                    .copyWith(color: Colors.grey),
                              )
                            ],
                          ),
                          Text(
                            widget.place.address,
                            style: MyTextStyles.regular
                                .copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Wrap(
                        spacing: 4,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              // 카카오톡 공유
                              bool isKakaoTalkSharingAvailable = await kakao
                                  .ShareClient.instance
                                  .isKakaoTalkSharingAvailable();

                              final kakao.LocationTemplate defaultLocation =
                                  kakao.LocationTemplate(
                                address: widget.place.address,
                                content: kakao.Content(
                                  title: widget.place.name,
                                  description: widget.content.name,
                                  imageUrl: Uri.parse(
                                      constants.youtubeThumbnailUriStart +
                                          widget.content.videoId +
                                          constants.youtubeThumbnailUriEnd),
                                  link: kakao.Link(
                                    webUrl: Uri.parse(
                                        'https://matube.notion.site/f55f713b956f4bb89151dadd3256ed74?pvs=4'),
                                    mobileWebUrl: Uri.parse(
                                        'https://matube.notion.site/f55f713b956f4bb89151dadd3256ed74?pvs=4'),
                                  ),
                                ),
                              );

                              if (isKakaoTalkSharingAvailable) {
                                try {
                                  Uri uri = await kakao.ShareClient.instance
                                      .shareDefault(
                                          template: defaultLocation,
                                          serverCallbackArgs: {
                                        'placeId': widget.place.id
                                      });
                                  await kakao.ShareClient.instance
                                      .launchKakaoTalk(uri);
                                  if (kDebugMode) {
                                    print('카카오톡 공유 완료');
                                  }
                                } catch (error) {
                                  if (kDebugMode) {
                                    print('카카오톡 공유 실패 $error');
                                  }
                                }
                              } else {
                                try {
                                  Uri shareUrl = await kakao
                                      .WebSharerClient.instance
                                      .makeDefaultUrl(
                                          template: defaultLocation);
                                  await kakao.launchBrowserTab(shareUrl,
                                      popupOpen: true);
                                } catch (error) {
                                  if (kDebugMode) {
                                    print('카카오톡 공유 실패 $error');
                                  }
                                }
                              }
                            },
                            child: const SizedBox(
                              width: 84,
                              height: 40,
                              child: Icon(
                                Icons.share,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              launchNaverMap(
                                  '${widget.place.name} ${widget.place.address}');
                            },
                            child: Container(
                              width: 84,
                              height: 40,
                              decoration: BoxDecoration(
                                border: Border.all(color: MyColors.primary),
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(16),
                                ),
                              ),
                              child: const Icon(
                                Icons.fork_right,
                                color: MyColors.primary,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Wrap(
                      direction: Axis.vertical,
                      spacing: 4,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: GestureDetector(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  return Container(
                                    color: Colors.white,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          height: 36,
                                          width: deviceWidth,
                                          child: Center(
                                            child: Container(
                                              width: 32,
                                              height: 4,
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                  color: Colors.grey,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100)),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height:
                                              (widget.placeContents.length) *
                                                  88,
                                          child: ListView.builder(
                                            itemCount:
                                                widget.placeContents.length,
                                            itemBuilder: (context, index) {
                                              return GestureDetector(
                                                onTap: () {
                                                  _youtubePlayerController
                                                      .loadVideoById(
                                                          videoId: widget
                                                              .placeContents[
                                                                  index]
                                                              .videoId);
                                                  Navigator.pop(context);
                                                },
                                                // onTap: () {
                                                //   _youtubePlayerController.load(
                                                //       placeContents[index]
                                                //           .videoId);
                                                //   Navigator.pop(context);
                                                // },
                                                child: SizedBox(
                                                  height: 88,
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      vertical: 12,
                                                      horizontal: 16,
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Image.network(
                                                          constants
                                                                  .youtubeThumbnailUriStart +
                                                              widget
                                                                  .placeContents[
                                                                      index]
                                                                  .videoId +
                                                              constants
                                                                  .youtubeThumbnailUriEnd,
                                                          width: 114,
                                                          height: 64,
                                                          fit: BoxFit.cover,
                                                        ),
                                                        Expanded(
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                              left: 12,
                                                            ),
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  widget
                                                                      .placeContents[
                                                                          index]
                                                                      .name,
                                                                  style:
                                                                      MyTextStyles
                                                                          .medium,
                                                                ),
                                                                Text(
                                                                  getInfluencerFromContent(
                                                                          widget.placeContents[
                                                                              index],
                                                                          widget
                                                                              .influencers)
                                                                      .name,
                                                                  style: MyTextStyles
                                                                      .regular
                                                                      .copyWith(
                                                                    color: Colors
                                                                        .grey,
                                                                  ),
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
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 4,
                              children: [
                                const Text(
                                  "이곳을 소개한 컨텐츠",
                                  style: TextStyle(fontSize: 12),
                                ),
                                Text(
                                  "${widget.placeContents.length}",
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                                const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: Icon(
                                    Icons.chevron_right,
                                    color: Colors.grey,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: SizedBox(
                            width: deviceWidth,
                            height: deviceWidth * 9 / 16,
                            child: YoutubePlayer(
                              controller: _youtubePlayerController,
                              aspectRatio: 16 / 9,
                            ),
                          ),
                        ),
                        // YoutubePlayer(
                        //   controller: _youtubePlayerController,
                        //   showVideoProgressIndicator: true,
                        // ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
