part of 'shared.dart';

class DBSCANRiceLeaf {
  final double epsilon; // Maximum distance for a neighbor (meter)
  final int minPoints; // Minimum points to form a cluster

  DBSCANRiceLeaf({required this.epsilon, required this.minPoints});

  Map<String, List> run(List<RiceLeaf> riceLeaves) {
    final List<int> labels = List.filled(riceLeaves.length, -1); // -1 = unvisited
    int clusterId = 0;

    for (int i = 0; i < riceLeaves.length; i++) {
      if (labels[i] != -1) continue; // Already visited

      final neighbors = _regionQuery(riceLeaves, riceLeaves[i]);
      if (neighbors.length < minPoints) {
        labels[i] = -2; // Mark as noise
      } else {
        _expandCluster(riceLeaves, labels, i, neighbors, clusterId);
        clusterId++;
      }
    }

    return {
      "clusters": _groupClusters(riceLeaves, labels, clusterId),
      "noises": _getNoise(riceLeaves, labels),
    };
  }

  void _expandCluster(List<RiceLeaf> riceLeaves, List<int> labels, int pointIdx,
      List<int> neighbors, int clusterId) {
    labels[pointIdx] = clusterId;

    for (int i = 0; i < neighbors.length; i++) {
      final neighborIdx = neighbors[i];
      if (labels[neighborIdx] == -2) {
        labels[neighborIdx] = clusterId; // Noise becomes part of the cluster
      }
      if (labels[neighborIdx] != -1) continue;

      labels[neighborIdx] = clusterId;
      final newNeighbors = _regionQuery(riceLeaves, riceLeaves[neighborIdx]);
      if (newNeighbors.length >= minPoints) {
        neighbors.addAll(newNeighbors);
      }
    }
  }

  List<int> _regionQuery(List<RiceLeaf> riceLeaves, RiceLeaf leaf) {
    final List<int> neighbors = [];
    for (int i = 0; i < riceLeaves.length; i++) {
      if (Geolocator.distanceBetween(
            leaf.coordinate!.latitude,
            leaf.coordinate!.longitude,
            riceLeaves[i].coordinate!.latitude,
            riceLeaves[i].coordinate!.longitude,
          ) <=
          epsilon) {
        neighbors.add(i);
      }
    }
    return neighbors;
  }

  List<List<RiceLeaf>> _groupClusters(
      List<RiceLeaf> riceLeaves, List<int> labels, int clusterCount) {
    final List<List<RiceLeaf>> clusters = List.generate(clusterCount, (_) => []);
    for (int i = 0; i < riceLeaves.length; i++) {
      if (labels[i] >= 0) {
        clusters[labels[i]].add(riceLeaves[i]);
      }
    }
    return clusters;
  }

  List<RiceLeaf> _getNoise(List<RiceLeaf> riceLeaves, List<int> labels) {
    final List<RiceLeaf> noise = [];
    for (int i = 0; i < riceLeaves.length; i++) {
      if (labels[i] == -2) {
        noise.add(riceLeaves[i]);
      }
    }
    return noise;
  }
}
