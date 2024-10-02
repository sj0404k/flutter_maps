import 'dart:async';
import 'dart:developer';
import 'properties.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'fdata.dart';

Map<int, NLatLng> coordinates = {
  1: NLatLng(37.227836,127.171029),
  8000: NLatLng(37.227731,127.169017),
  8003: NLatLng(2.0, 3.0),
  8101: NLatLng(1.5, 1.0),
  8102: NLatLng(1.5, 2.5),
  8103: NLatLng(1.0, 3.0),
  8201: NLatLng(2.5, 4.0),
  8301: NLatLng(2.0, 5.0),
  8302: NLatLng(2.0, 6.0),
  8303: NLatLng(1.5, 4.5),
  8401: NLatLng(3.0, 3.0),
  8402: NLatLng(3.0, 2.0),
  91000: NLatLng(4.0, 1.0),
  91004: NLatLng(4.5, 1.5),
  91101: NLatLng(37.227864,127.170327),
  91102: NLatLng(37.227610,127.170502),
  91201: NLatLng(4.0, 2.0),
  91301: NLatLng(4.0, 3.5),
  91302: NLatLng(4.5, 4.0),
  91303: NLatLng(4.0, 4.5),
  91401: NLatLng(4.0, 2.5),
  91402: NLatLng(4.5, 2.0)
};

void main() async {
  await _initialize();
  runApp(const NaverMapApp());
}

// 지도 초기화하기
Future<void> _initialize() async {
  WidgetsFlutterBinding.ensureInitialized();
  String? clientId = await Properties.getNaverApiKey();
  await NaverMapSdk.instance.initialize(
    clientId: "인증키 입력", // 클라이언트 ID 설정
    onAuthFailed: (e) => log("네이버맵 인증오류 : $e", name: "onAuthFailed"),
  );
}

class NaverMapApp extends StatefulWidget {
  const NaverMapApp({Key? key}) : super(key: key);

  @override
  _NaverMapAppState createState() => _NaverMapAppState();
}

class _NaverMapAppState extends State<NaverMapApp> {
  final Completer<NaverMapController> _mapControllerCompleter = Completer<NaverMapController>();
  late NaverMapController _naverMapController;
  final cameraUpdate1 = NCameraUpdate.zoomIn(); // 줌 레벨을 1만큼 증가시킵니다.
  final cameraUpdate2 = NCameraUpdate.zoomOut(); // 줌 레벨을 1만큼 감소시킵니다.
  final TextEditingController _searchController = TextEditingController();

  List<NLatLng> testTargets1 = [
    NLatLng(37.227836,127.171029),
    NLatLng(37.227610,127.170502),
    NLatLng(37.227864,127.170327),
  ];

  List<NLatLng> testTargets2 = [

  ];

  @override
  Widget build(BuildContext context) {
    final Completer<NaverMapController> mapControllerCompleter = Completer();
    late NMarker _marker;
    return MaterialApp(
      home: Scaffold(
        body: Stack(
          children: [
            NaverMap(
              options: const NaverMapViewOptions(
                indoorEnable: true,
                locationButtonEnable: true,
                consumeSymbolTapEvents: false,
                extent: NLatLngBounds(// 지도 한반도로 제한 효과 없음
                  southWest: NLatLng(31.43, 122.37),
                  northEast: NLatLng(44.35, 132.0),
                ),
                initialCameraPosition: NCameraPosition(
                  target: NLatLng(37.2266747, 127.1681805),
                  zoom: 15,
                  bearing: 0,
                  tilt: 0,
                ),

              ),
                onMapReady: (controller) async {
                  final marker = NMarker(
                    id: 'test',
                    position: const NLatLng(37.2266747, 127.1681805),
                  );
                  controller.addOverlayAll({marker});
                  NInfoWindow.onMap(id: marker.info.id, text: "text", position: const NLatLng(37.2266747, 127.1681805));

                  // NMultipartPathOverlay 추가
                  NMultipartPathOverlay pathOverlay = NMultipartPathOverlay(
                    id: "test",
                    paths: [
                      NMultipartPath(coords: testTargets2, color: Colors.red),
                      // NMultipartPath(coords: testTargets2),

                    ],
                    width: 5, // 경로 두께

                  );
                  // controller.removeOverlay(_marker.id); // 마커 제거
                  controller.addOverlay(pathOverlay); // 경로 오버레이 추가

                  mapControllerCompleter.complete(controller);
                  _mapControllerCompleter.complete(controller);
                  _naverMapController = controller;
                  log("onMapReady", name: "onMapReady");
                }
            ),
            Positioned(
              top: 50, // 검색창을 화면 상단에 위치시킴
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: "검색할 장소를 입력하세요",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: _onSearch, // 검색 버튼 클릭 시 실행될 함수
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 30,
              right: 20,
              child: Column(
                children: [
                  FloatingActionButton(
                    heroTag: 'zoomIn',
                    onPressed: _zoomIn,
                    child: const Icon(Icons.zoom_in),
                  ),
                  const SizedBox(height: 10),
                  FloatingActionButton(
                    heroTag: 'zoomOut',
                    onPressed: _zoomOut,
                    child: const Icon(Icons.zoom_out),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Future<void> _onSearch() async {
    String query = _searchController.text;
    if (query.isNotEmpty) {
      // 쿼리를 정수로 변환하여 coordinates 맵의 키와 비교
      int? key = int.tryParse(query);
      testTargets2 = findroad(query);
      print(testTargets2);



      // 새로운 NMultipartPathOverlay 생성
      NMultipartPathOverlay pathOverlay = NMultipartPathOverlay(
        id: "testPath", // 오버레이 ID를 설정
        paths: [
          NMultipartPath(coords: testTargets2, color: Colors.red), // 업데이트된 testTargets2 사용
        ],
        width: 5, // 경로 두께
      );

      // 새로운 경로 오버레이 추가
      await _naverMapController.addOverlay(pathOverlay);



      // if (key != null && coordinates.containsKey(key)) {
      //   // 키가 존재하면 해당 좌표를 가져옴
      //   NLatLng newPosition = coordinates[key]!;
      //
      //   // 가져온 좌표로 카메라 업데이트 생성
      //   NCameraUpdate cameraUpdate = NCameraUpdate.fromCameraPosition(
      //     NCameraPosition(target: newPosition, zoom: 15),
      //   );
      //
      //   // 카메라를 새로운 위치로 이동
      //   await _naverMapController.updateCamera(cameraUpdate);
      // } else {
      //   // 키가 coordinates 맵에 존재하지 않을 경우 처리
      //   print("주어진 쿼리에 대한 좌표를 찾을 수 없습니다.");
      // }
    }
  }

  Future<void> _zoomIn() async {
    if (_mapControllerCompleter.isCompleted) {
      _naverMapController = await _mapControllerCompleter.future;
      await _naverMapController.updateCamera(cameraUpdate1);
    }
  }

  Future<void> _zoomOut() async {
    if (_mapControllerCompleter.isCompleted) {
      _naverMapController = await _mapControllerCompleter.future;
      await _naverMapController.updateCamera(cameraUpdate2);
    }
  }

}
