import 'dart:collection';
import 'dart:io';
import 'datacho.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

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

