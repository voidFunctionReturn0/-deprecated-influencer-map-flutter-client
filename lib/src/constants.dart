import 'package:flutter_dotenv/flutter_dotenv.dart';

String host = dotenv.env['HOST']!;
int port = int.parse(dotenv.env['PORT']!);

const String packageName = 'com.dandypeople.influencer_map';
const String dynamicLinkPrefixUrl = 'https://dandypeople.page.link';

enum Platform {
  YOUTUBE,
  isAndroid;
}

enum OS {
  aos,
  ios,
}

const double mapZoomDefault = 13.5;
const double mapZoomForPlace = 18.5;
double lat1km = 1 / 109.958489129649955;
const int HTTP_STATUS_OK = 200;

double INIT_ZOOM_LEVEL = 13.0;

Uri fetchInfluencersUri =
    Uri(scheme: 'http', host: host, port: port, path: '/influencers');

Uri fetchPlacesUri =
    Uri(scheme: 'http', host: host, port: port, path: '/places');

Uri fetchContentsUri =
    Uri(scheme: 'http', host: host, port: port, path: '/contents');

double fontSize16 = 16;

// 유튜브 영상 썸네일 https://abcdqbbq.tistory.com/98
String youtubeThumbnailUriStart = "https://img.youtube.com/vi/";
String youtubeThumbnailUriEnd = "/mqdefault.jpg";

enum ButtonShape { rectangle, circle }

Uri inquiryDBUri = Uri(
  scheme: 'https',
  host: 'api.notion.com',
  path: '/v1/pages',
);

Map<String, String> inquiryPostHeaders = <String, String>{
  'Authorization': 'Bearer ${dotenv.env['NOTION_API_KEY']}',
  'Notion-Version': '2022-06-28',
  'Content-Type': 'application/json'
};
