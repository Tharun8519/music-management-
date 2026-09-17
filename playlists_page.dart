import 'package:flutter/material.dart';

class PlaylistsPage extends StatefulWidget {
  const PlaylistsPage({super.key});

  @override
  State<PlaylistsPage> createState() => _PlaylistsPageState();
}

class Playlist {
  final String id;
  final String name;
  final List<String> songIds;

  Playlist({required this.id, required this.name, List<String>? songIds}) : songIds = songIds ?? [];
}

class _PlaylistsPageState extends State<PlaylistsPage> {
  final List<Playlist> _playlists = [];
  final _controller = TextEditingController();

  void _add() {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    setState(() {
      _playlists.add(Playlist(id: DateTime.now().millisecondsSinceEpoch.toString(), name: name));
      _controller.clear();
    });
  }

  void _delete(Playlist p) {
    setState(() {
      _playlists.removeWhere((x) => x.id == p.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Playlists')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(children: [
              Expanded(child: TextField(controller: _controller, decoration: const InputDecoration(hintText: 'New playlist'))),
              ElevatedButton(onPressed: _add, child: const Text('Add')),
            ]),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: _playlists.length,
                itemBuilder: (context, idx) {
                  final p = _playlists[idx];
                  return ListTile(
                    title: Text(p.name),
                    subtitle: Text('${p.songIds.length} songs'),
                    trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () => _delete(p)),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
