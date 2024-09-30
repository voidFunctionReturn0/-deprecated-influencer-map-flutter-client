class TMapPlace {
  final String id;
  final String name;

  // 지번 주소
  final String upperAddrName;
  final String middleAddrName;
  final String lowerAddrName;
  final String detailAddrName;
  final String firstNo;
  final String secondNo;

  // 도로명 주소
  final String roadName;
  final String firstBuildNo;
  final String secondBuildNo;

  // 카테고리
  final String upperBizName;
  final String middleBizName;
  final String lowerBizName;
  final String detailBizName;

  // 위치
  final double centerLat;
  final double centerLon;

  TMapPlace({
    required this.id,
    required this.name,
    required this.upperAddrName,
    required this.middleAddrName,
    required this.lowerAddrName,
    required this.detailAddrName,
    required this.firstNo,
    required this.secondNo,
    required this.roadName,
    required this.firstBuildNo,
    required this.secondBuildNo,
    required this.upperBizName,
    required this.middleBizName,
    required this.lowerBizName,
    required this.detailBizName,
    required this.centerLat,
    required this.centerLon,
  });

  factory TMapPlace.fromJson(Map<String, dynamic> json) {
    return TMapPlace(
        id: json['id'] as String,
        name: json['name'] as String,
        upperAddrName: json['upperAddrName'] as String,
        middleAddrName: json['middleAddrName'] as String,
        lowerAddrName: json['lowerAddrName'] as String,
        detailAddrName: json['detailAddrName'] as String,
        firstNo: json['firstNo'] as String,
        secondNo: json['secondNo'] as String,
        roadName: json['roadName'] as String,
        firstBuildNo: json['firstBuildNo'] as String,
        secondBuildNo: json['secondBuildNo'] as String,
        upperBizName: json['upperBizName'] as String,
        middleBizName: json['middleBizName'] as String,
        lowerBizName: json['lowerBizName'] as String,
        detailBizName: json['detailBizName'] as String,
        centerLat: double.parse(
            json['newAddressList']['newAddress'][0]['centerLat'] as String),
        centerLon: double.parse(
            json['newAddressList']['newAddress'][0]['centerLon'] as String));
  }
}
