import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import 'Episode.dart';
import 'PlaylistEntry.dart';
import 'Podcast.dart';

class DBProvider {
  DBProvider._();
  static final DBProvider db = DBProvider._();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDB();
    return _database!;
  }

  setupDB(Database db) async {
    await db.execute(
        "CREATE TABLE IF NOT EXISTS podcasts(id INTEGER PRIMARY KEY, rss_url TEXT, title TEXT, image_url TEXT, description TEXT, link TEXT, lastUpdate TEXT);");
    await db.execute("CREATE UNIQUE INDEX IF NOT EXISTS podcasts_rss_uniq ON podcasts(rss_url);");
    await db.execute(
        "CREATE TABLE IF NOT EXISTS episodes(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, link TEXT, content TEXT, pub_date TEXT, enclosure_url TEXT, last_position NUMBER, podcast_id INTEGER, FOREIGN KEY(podcast_id) REFERENCES podcasts(id));");
    await db.execute("CREATE TABLE IF NOT EXISTS subscriptions(rss_url TEXT PRIMARY KEY)");
    await db.execute(
        "CREATE TABLE IF NOT EXISTS playlist(id INTEGER PRIMARY KEY AUTOINCREMENT, position INTEGER, episode_id INTEGER, placemark REAL, FOREIGN KEY(episode_id) REFERENCES episodes(id));");
  }

  initDB() async {
    final documentsDirectory = await getDatabasesPath();
    final dbPath = path.join(documentsDirectory, "podcasts.db");
    // await deleteDatabase(dbPath);
    return await openDatabase(dbPath, version: 1, onCreate: (Database db, int version) async {
      await setupDB(db);
    });
  }

  Future<Podcast?> getPodcast(int id) async {
    final db = await database;
    final p = await db.query("podcasts", where: "id = ?", whereArgs: [id]);
    if (p.isEmpty) return null;
    final e = await db.query("episodes", where: "podcast_id = ?", whereArgs: [id]);
    return Podcast.fromDB(p.first, e);
  }

  Future<Podcast?> getPodcastByRssUrl(String rssUrl) async {
    final db = await database;
    final p = await db.query("podcasts", where: "rss_url = ?", whereArgs: [rssUrl]);
    if (p.isEmpty) return null;
    final e = await db.query("episodes", where: "podcast_id = ?", whereArgs: [p.first["id"]]);
    return Podcast.fromDB(p.first, e);
  }

  Future<List<Podcast>> getPodcastsFromRssUrl(List<String> rssUrls) async {
    final podcasts = await Future.wait(rssUrls.map((rssUrl) => getPodcastByRssUrl(rssUrl)));
    return podcasts.whereType<Podcast>().toList();
  }

  Future<bool> isSubscribed(Podcast podcast) async {
    final db = await database;
    final record =
        await db.query("subscriptions", where: "rss_url = ?", whereArgs: [podcast.rssUrl]);
    return record.isNotEmpty;
  }

  Future<int> savePodcast(Podcast podcast) async {
    final db = await database;
    final podcastId =
        await db.insert("podcasts", podcast.toDB(), conflictAlgorithm: ConflictAlgorithm.replace);
    podcast.episodes.forEach((episode) async => {
          await db.insert("episodes", episode.toDB(podcastId),
              conflictAlgorithm: ConflictAlgorithm.replace)
        });
    return podcastId;
  }

  Future<List<String>> getSubscriptions() async {
    final db = await database;
    final result = await db.query("subscriptions", columns: ["rss_url"]);
    return result.map((row) => row["rss_url"] as String).toList();
  }

  Future addSubscription(Podcast podcast) async {
    final db = await database;
    await savePodcast(podcast);
    await db.insert("subscriptions", {"rss_url": podcast.rssUrl});
  }

  Future removeSubscription(Podcast podcast) async {
    final db = await database;
    await db.delete("subscriptions", where: "rss_url = ?", whereArgs: [podcast.rssUrl]);
  }

  // returns -1 when not in playlist
  Future<List<PlaylistEntry>> getPlaylist() async {
    final db = await database;
    final result = await db.rawQuery(
        "SELECT e.*, position, placemark FROM playlist p JOIN episodes e ON p.episode_id = e.id ORDER BY position");
    return result.map((row) => PlaylistEntry.fromDB(row)).toList();
  }

  // returns -1 when not in playlist
  Future<int> getPlaceInPlaylist(int episodeId) async {
    final db = await database;
    final result = await db.query("playlist",
        columns: ["position"], where: "episode_id = ?", whereArgs: [episodeId]);
    return result.length == 0 ? -1 : result.first["position"] as int;
  }

  Future addToPlaylist(int episodeId) async {
    final db = await database;
    await db.insert("playlist", {"position": 999999, "episode_id": episodeId, "placemark": 0});
    await _reorderPlaylist();
  }

  Future insertIntoPlaylist(int episodeId) async {
    final db = await database;
    await db.insert("playlist", {"position": -1, "episode_id": episodeId, "placemark": 0});
    await _reorderPlaylist();
  }

  Future removeFromPlaylist(int episodeId) async {
    final db = await database;
    await db.delete("playlist", where: "episode_id = ?", whereArgs: [episodeId]);
    await _reorderPlaylist();
  }

  Future _reorderPlaylist() async {
    final db = await database;
    await db.rawUpdate(
        "UPDATE playlist SET position = (SELECT COUNT(id) FROM playlist t1 WHERE t1.position < position)");
  }

  Future updateLastPlayed(Episode episode, double seconds) async {
    final db = await database;
    await db.update("episodes", {"last_position": seconds},
        where: "id = ?", whereArgs: [episode.id]);
  }

  Future completeEpisode(Episode episode) async {
    final db = await database;
    await db.update("episodes", {"last_position": 0}, where: "id = ?", whereArgs: [episode.id]);
    await db.delete("playlist", where: "episodeId = ?", whereArgs: [episode.id]);
    await _reorderPlaylist();
  }
}
