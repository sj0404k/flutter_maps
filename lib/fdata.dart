import 'dart:collection';
import 'dart:io';

import 'package:flutter_naver_map/flutter_naver_map.dart';

Map<int, NLatLng> coordinates = {
  1: NLatLng(37.227836,127.171029),
  8000: NLatLng(37.227731,127.169017),
  8003: NLatLng(37.2277332,127.168934),
  8101: NLatLng(37.227782,127.169223),
  8102: NLatLng(37.227403,127.169395),
  8103: NLatLng(37.227299,127.169175),
  8201: NLatLng(37.227244,127.168613),
  8301: NLatLng(37.226853,127.168807),
  8302: NLatLng(37.227018,127.169199),
  8303: NLatLng(37.227117, 127.169430),
  8401: NLatLng(37.228073, 127.168324),
  8402: NLatLng(37.228229, 127.169021),
  91000: NLatLng(37.227937, 127.169927),
  91004: NLatLng(37.228345, 127.169819),
  91101: NLatLng(37.227864,127.170327),
  91102: NLatLng(37.227610,127.170502),
  91201: NLatLng(37.227910,127.169571),
  91301: NLatLng(37.227680, 127.169804),
  91302: NLatLng(37.227378,127.170001),
  91303: NLatLng(37.227308, 127.169842),
  91401: NLatLng(37.228417,127.169793),
  91402: NLatLng(37.228399, 127.169974)
};

class Graph {
  final Map<int, Map<int, double>> _graph;

  Graph(this._graph);

  // 다익스트라 알고리즘
  Map<int, double> dijkstra(int start, Map<int, int?> previous) {
    // 거리 초기화
    Map<int, double> distance = {};
    for (var node in _graph.keys) {
      distance[node] = double.infinity;
    }
    distance[start] = 0;

    // 우선순위 큐 초기화
    var queue = Queue<MapEntry<double, int>>();
    queue.add(MapEntry(0, start));

    while (queue.isNotEmpty) {
      var currentEntry = queue.removeFirst();
      double currentDistance = currentEntry.key;
      int currentNode = currentEntry.value;

      // 이미 처리한 노드면 무시
      if (currentDistance > distance[currentNode]!) {
        continue;
      }

      // 이웃 노드 탐색
      _graph[currentNode]!.forEach((neighbor, weight) {
        double distanceViaCurrent = currentDistance + weight;

        // 더 짧은 경로를 발견하면 갱신
        if (distanceViaCurrent < distance[neighbor]!) {
          distance[neighbor] = distanceViaCurrent;
          previous[neighbor] = currentNode; // 이전 노드 기록
          queue.add(MapEntry(distanceViaCurrent, neighbor));
        }
      });
    }

    return distance;
  }

  // 최단 경로 재구성
  List<int> reconstructPath(Map<int, int?> previous, int start, int target) {
    List<int> path = [];
    int? current = target;

    while (current != null) {
      path.add(current);
      current = previous[current];
    }

    // 경로를 뒤집어 새로운 리스트로 만듦
    List<int> reversedPath = [];
    for (int i = path.length - 1; i >= 0; i--) {
      reversedPath.add(path[i]);
    }

    // 시작점이 포함되어 있는지 확인
    return reversedPath.isNotEmpty && reversedPath[0] == start ? reversedPath : [];
  }
}

List<NLatLng> findroad(String str) {
  print("find 진입");
  // 그래프 정의
  Map<int, Map<int, double>> graph = {
    1: {91102: 5.0},
    8000: {8101: 2.0, 8103: 4.0},
    8003: {8103: 2.0, 8201: 1.5},
    8101: {8402: 4.0, 91201: 3.0, 8102: 4.0, 8000: 2.0},
    8102: {8101: 4.0, 91303: 3.0, 8103: 1.0},
    8103: {8000: 4.0, 8102: 1.0, 8303: 2.0, 8003: 2.0},
    8201: {8401: 8.0, 8003: 1.5, 8301: 4.0},
    8301: {8201: 4.0, 8302: 2.8},
    8302: {8301: 4.0, 8303: 2.0},
    8303: {8103: 2.0, 91303: 3.3, 8302: 2.8},
    8401: {8402: 4.0, 8201: 8.0},
    8402: {91401: 4.0, 8101: 4.0, 8401: 6.0},
    91000: {91101: 2.3, 91301: 2.0},
    91004: {91401: 1.0},
    91101: {91402: 4.0, 91102: 4.0, 91000: 2.3},
    91102: {91101: 4.0, 1: 3.0, 91302: 2.5},
    91201: {91301: 2.3, 8101: 4.0},
    91301: {91000: 2.0, 91302: 4.0, 91201: 2.3},
    91302: {91301: 3.0, 91102: 2.5, 91303: 3.7},
    91303: {91302: 2.5, 8303: 5.0, 8102: 4.0},
    91401: {91402: 1.0, 91004: 1.0},
    91402: {91401: 1.0, 91101: 4.0}
  };

  Graph myGraph = Graph(graph);

  // 이전 노드 맵 초기화
  Map<int, int?> previous = {};
  for (var node in graph.keys) {
    previous[node] = null;
  }

  // stdout.write("시작점과 도착점을 입력해주세요.: ");
  List<String> input = str.split(' ');
  int start = int.parse(input[0]);
  int target = int.parse(input[1]);

  // 최단 거리와 이전 노드 얻기
  Map<int, double> distance = myGraph.dijkstra(start, previous);
  List<int> path = myGraph.reconstructPath(previous, start, target);
  List<NLatLng> result = [];  // Initialize result here

  for (var node in path) {
    if (coordinates.containsKey(node)) {
      result.add(coordinates[node]!);  // Add to the result list
    }
  }

  print("최단 경로: $path");
  print("모든 거리: $distance");
  print("최단 거리: ${distance[target]}\n");
  return result;  // Return the correctly named result
}

