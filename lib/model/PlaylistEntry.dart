import 'Episode.dart';

class PlaylistEntry {
  int order;
  double placemark;
  Episode episode;

  PlaylistEntry.fromDB(Map<String, dynamic> row)
      : order = row["position"],
        placemark = row["placemark"],
        episode = Episode.fromDB(row);
}
