import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'playlists_page.dart';

class MusicPage extends StatefulWidget {
  const MusicPage({super.key});

  @override
  State<MusicPage> createState() => _MusicPageState();
}

class Song {
  final String id;
  final String title;
  final String artist;
  bool liked = false;
  bool favorite = false;
  bool saved = false;
  bool downloaded = false;

  Song({required this.id, required this.title, required this.artist});
}

class _MusicPageState extends State<MusicPage> {
  final List<Song> _songs = [
    Song(id: 't1', title: 'Vennilave', artist: 'A. R. Rahman'),
    Song(id: 't2', title: 'Munbe Vaa', artist: 'S. P. Balasubrahmanyam'),
    Song(id: 't3', title: 'Kannodu Kaanbathellam', artist: 'A. R. Rahman'),
    Song(id: 't4', title: 'Unakkenna Venum Sollu', artist: 'Harris Jayaraj'),
    Song(id: 't5', title: 'Nenjukkul Peidhidum', artist: 'Harris Jayaraj'),
    Song(id: 't6', title: 'Suttrum Vizhi', artist: 'Ilaiyaraaja'),
    Song(id: 't7', title: 'Thalli Pogathey', artist: 'Ghibran'),
    Song(id: 't8', title: 'Aathichudi', artist: 'Deva'),
    Song(id: 't9', title: 'Pudhu Metro Rail', artist: 'Anirudh Ravichander'),
    Song(id: 't10', title: 'Rowdy Baby', artist: 'Yuvan Shankar Raja'),
  ];

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString('songs');
    if (raw != null) {
      final list = jsonDecode(raw) as List;
      setState(() {
        _songs.clear();
        _songs.addAll(list.map((m) => Song(
              id: m['id'] as String,
              title: m['title'] as String,
              artist: m['artist'] as String,
)
                ..liked = m['liked'] as bool
                ..favorite = m['favorite'] as bool
                ..saved = m['saved'] as bool
                ..downloaded = m['downloaded'] as bool
            )));
      });
    }
  }

  Future<void> _save() async {
    final sp = await SharedPreferences.getInstance();
    final raw = jsonEncode(_songs.map((s) => {
          'id': s.id,
          'title': s.title,
          'artist': s.artist,
          'liked': s.liked,
          'favorite': s.favorite,
          'saved': s.saved,
          'downloaded': s.downloaded,
        }).toList());
    await sp.setString('songs', raw);
  }

  void _toggle(Song s, String key) {
    setState(() {
      switch (key) {
        case 'like':
          s.liked = !s.liked;
          break;
        case 'fav':
          s.favorite = !s.favorite;
          break;
        case 'save':
          s.saved = !s.saved;
          break;
        case 'dl':
          s.downloaded = !s.downloaded;
          break;
      }
      _save();
    });
  }

  void _share(Song s) {
    // For demo: show share dialog
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Share'),
        content: Text('Share "${s.title}" by ${s.artist}'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  void _playNext(Song s) {
    setState(() {
      _songs.removeWhere((x) => x.id == s.id);
      _songs.insert(0, s);
      _save();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Queued "${s.title}" to play next')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Music'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: _songs.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, idx) {
          final s = _songs[idx];
          return ListTile(
            title: Text(s.title),
            subtitle: Text(s.artist),
            trailing: Wrap(
              spacing: 6,
              children: [
                IconButton(
                  icon: Icon(s.liked ? Icons.thumb_up : Icons.thumb_up_outlined),
                  onPressed: () => _toggle(s, 'like'),
                  tooltip: 'Like',
                ),
                IconButton(
                  icon: Icon(s.favorite ? Icons.favorite : Icons.favorite_border),
                  onPressed: () => _toggle(s, 'fav'),
                  tooltip: 'Favorite',
                ),
                IconButton(
                  icon: Icon(s.saved ? Icons.bookmark : Icons.bookmark_border),
                  onPressed: () => _toggle(s, 'save'),
                  tooltip: 'Saved',
                ),
                IconButton(
                  icon: Icon(s.downloaded ? Icons.download_done : Icons.download),
                  onPressed: () => _toggle(s, 'dl'),
                  tooltip: 'Download',
                ),
                IconButton(
                  icon: const Icon(Icons.playlist_add),
                  onPressed: () => _playNext(s),
                  tooltip: 'Play Next',
                ),
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () => _share(s),
                  tooltip: 'Share',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
