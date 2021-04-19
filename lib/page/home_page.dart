import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:music/constants.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<AlbumInfo> albums;
  List<AlbumInfo> albumList;
  List<ArtistInfo> artists;
  List<SongInfo> songs;
  List<SongInfo> albumSongs;
  List<SongInfo> artistSongs;
  List<SongInfo> curSongPlaylist;
  final FlutterAudioQuery audioQuery = FlutterAudioQuery();
  bool hasSongs = false;
  AudioPlayer audioPlayer = AudioPlayer();
  bool isPlaying = false;
  String nowPlaying = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    albums = await audioQuery.getAlbums();
    artists = await audioQuery.getArtists();
    audioQuery.getSongs().then((value) {
      setState(() {
        songs = value;
        hasSongs = true;
      });
    });

    // timer = Timer.periodic(Duration(seconds: 1), elapsed);
    //
    // setState(() {
    //   hasAlbum = true;
    //   hasArtist = true;
    //   hasSong = true;
    //   showFAB = true;
    // });
  }

  // Future<void> getSongs(String id) async {
  //   albumSongs = await audioQuery.getSongsFromAlbum(albumId: id);
  //   curSongPlaylist = albumSongs;
  //   setState(() {
  //     hasAlbumSongs = true;
  //   });
  // }
  Future<void> getSongsByArtist(String artist) async {
    artistSongs = await audioQuery.getSongsFromArtist(artistId: artist);
    curSongPlaylist = artistSongs;
    print(artistSongs);
    setState(() {
      // hasArtistSongs = true;
    });
  }

  Future<void> play(SongInfo song) async {
    int result = await audioPlayer.play(song.filePath, isLocal: true);
    setState(() {
      isPlaying = true;
      nowPlaying = song.title;
    });
  }

  Future<void> pause() async {
    int result = await audioPlayer.pause();
    setState(() {
      isPlaying = false;
    });
  }

  Future<void> resume() async {
    int result = await audioPlayer.resume();
    setState(() {
      isPlaying = true;
    });
  }

  static int parseToSeconds(int ms) {
    Duration duration = Duration(milliseconds: ms);
    return duration.inSeconds;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(kAppName),
      ),
      body: hasSongs
          ? ListView.builder(
              itemCount: songs.length,
              padding: EdgeInsets.only(bottom: 20),
              itemBuilder: (context, index) {
                return ListTile(
                  onTap: () => play(songs[index]),
                  title: Text(
                    '${songs[index].title}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                      icon: Icon(CupertinoIcons.ellipsis_vertical),
                      onPressed: () {}),
                );
              },
            )
          : Center(
              child: Text('no songs'),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        margin: EdgeInsets.only(left: 10, right: 10),
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.amber,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '$nowPlaying',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Visibility(
                visible: isPlaying,
                child: IconButton(
                  icon: Icon(CupertinoIcons.pause),
                  onPressed: () => pause(),
                )),
            Visibility(
              visible: !isPlaying,
              child: IconButton(
                icon: Icon(CupertinoIcons.play),
                onPressed: () => resume(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.music_albums), label: 'Album'),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.music_note_2), label: 'Music'),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.music_mic), label: 'Artish'),
        ],
      ),
    );
  }
}
