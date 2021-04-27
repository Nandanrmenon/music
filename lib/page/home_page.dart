import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:music/constants.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:music/model/now_playing.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

bool isPlaying = false;
NowPlaying _nowPlaying;

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
  PageController _pageController;
  int _pageNr = 0;

  String nowPlaying = '';
  double _progress = 10.0;
  SongInfo currentSong;

  @override
  void initState() {
    // TODO: implement initState
    _pageController = new PageController();
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    albums = await audioQuery.getAlbums();
    artists = await audioQuery.getArtists();
    audioQuery.getSongs().then((value) {
      setState(() {
        songs = value;
        hasSongs = value.length > 0;
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

  Future<void> getArtist(String artist) async {
    artists = await audioQuery.getArtists();
    print(artist);
  }

  Future<void> play(SongInfo song) async {
    int result = await audioPlayer.play(song.filePath, isLocal: true);
    setState(() {
      isPlaying = true;
      nowPlaying = song.title;
      currentSong = song;
      _nowPlaying = NowPlaying(song, isPlaying);
    });
  }

  Future<void> pause() async {
    int result = await audioPlayer.pause();
    setState(() {
      isPlaying = false;
      _nowPlaying = NowPlaying(currentSong, isPlaying);
    });
  }

  Future<void> resume() async {
    int result = await audioPlayer.resume();
    setState(() {
      isPlaying = true;
      _nowPlaying = NowPlaying(currentSong, isPlaying);
    });
  }

  static int parseToSeconds(int ms) {
    Duration duration = Duration(milliseconds: ms);
    return duration.inSeconds;
  }

  getArtWork(String type, SongInfo _song) {
    return FutureBuilder<Uint8List>(
        future: audioQuery.getArtwork(
            type: (type == "artist" ? ResourceType.ARTIST : ResourceType.ALBUM),
            id: type == "artist" ? _song.artistId : _song.albumId),
        builder: (_, snapshot) {
          if (snapshot.data == null)
            return Container(
              height: 250.0,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          if (snapshot.data.isNotEmpty) {
            return Image.memory(
              snapshot.data,
              fit: BoxFit.cover,
            );
          } else
            return CircleAvatar(child: Icon(CupertinoIcons.music_note));
        });
  }

  Widget SongView() {
    return Container(
      child: hasSongs
          ? ListView.builder(
              itemCount: songs.length,
              padding: EdgeInsets.only(bottom: 80),
              itemBuilder: (context, index) {
                SongInfo _song = songs[index];
                return ListTile(
                  onTap: () => play(_song),
                  leading: (_song.albumArtwork == null
                      ? Container(
                          height: 45,
                          width: 45,
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: getArtWork("song", _song)),
                        )
                      : Icon(CupertinoIcons.music_note)),
                  title: Text(
                    '${_song.title}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              },
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(CupertinoIcons.nosign),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('No Songs'),
                  ),
                ],
              ),
            ),
    );
  }

  Widget ArtistView() {
    final orientation = MediaQuery.of(context).orientation;
    return Container(
      margin: EdgeInsets.only(bottom: 80),
      child: hasSongs
          ? GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount:
                      (orientation == Orientation.portrait) ? 2 : 3),
              itemCount: artists.length,
              itemBuilder: (BuildContext context, int index) {
                ArtistInfo artist = artists[index];
                return Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: new Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black38, width: .1)),
                    child: InkWell(
                      onTap: () {},
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          (artist.artistArtPath == null)
                              ? Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: FutureBuilder<Uint8List>(
                                      future: audioQuery.getArtwork(
                                          type: ResourceType.ARTIST,
                                          id: artist.id),
                                      builder: (_, snapshot) {
                                        if (snapshot.data == null)
                                          return Container(
                                            child: Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                          );
                                        return SizedBox(
                                          child: Container(
                                            width: 120,
                                            height: 120,
                                            child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                                child: (snapshot.data.isNotEmpty
                                                    ? Image.memory(
                                                        snapshot.data,
                                                        fit: BoxFit.cover,
                                                      )
                                                    : Icon(CupertinoIcons
                                                        .music_mic))),
                                          ),
                                        );
                                      }),
                                )
                              : Icon(CupertinoIcons.music_mic),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              artist.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              })
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(CupertinoIcons.nosign),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('No Songs'),
                  ),
                ],
              ),
            ),
    );
  }

  Widget AlbumView() {
    return Center(
      child: Text('Soon'),
    );
  }

  Widget PlayerView(SongInfo song) {
    showModalBottomSheet(
        context: context,
        isDismissible: true,
        isScrollControlled: true,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height,
              child: Scaffold(
                // appBar: AppBar(
                //   elevation: 0,
                //   backgroundColor: Colors.white,
                //   foregroundColor: Colors.black,
                //   leading: IconButton(
                //     icon: Icon(
                //       CupertinoIcons.chevron_down,
                //       color: Colors.black,
                //     ),
                //     onPressed: () => Navigator.pop(context),
                //   ),
                // ),
                bottomNavigationBar: BottomAppBar(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(
                          CupertinoIcons.chevron_down,
                          color: Colors.black,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                body: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        (song.albumArtwork == null
                            ? Container(
                          margin: EdgeInsets.only(top: 50),
                                width: MediaQuery.of(context).size.width,
                                child: ClipRRect(
                                  child: getArtWork("song", song),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              )
                            : Icon(CupertinoIcons.music_note)),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          child: Text(
                            song.title,
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.w300),
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(onPressed: (){}, icon: Icon(Icons.shuffle)),
                            IconButton(onPressed: (){}, icon: Icon(Icons.skip_previous_outlined)),
                            Visibility(
                              visible: isPlaying,
                              child: Align(
                                child: FloatingActionButton(
                                  child: Icon(CupertinoIcons.pause),
                                  onPressed: () {
                                    pause();
                                    setModalState(() {
                                      isPlaying = false;
                                    });
                                  },
                                ),
                              ),
                            ),
                            Visibility(
                              visible: !isPlaying,
                              child: FloatingActionButton(
                                child: Icon(CupertinoIcons.play),
                                onPressed: () {
                                  resume();
                                  setModalState(() {
                                    isPlaying = true;
                                  });
                                },
                              ),
                            ),
                            IconButton(onPressed: (){}, icon: Icon(Icons.skip_next_outlined)),
                            IconButton(onPressed: (){}, icon: Icon(Icons.repeat)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(kAppName),
      ),
      body: PageView(
        physics: new NeverScrollableScrollPhysics(),
        children: [
          AlbumView(),
          ArtistView(),
          SongView(),
        ],
        controller: _pageController,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: InkWell(
        onTap: () {
          // mediaPlayer(currentSong);
          PlayerView(currentSong);
        },
        child: Container(
          margin: EdgeInsets.only(left: 10, right: 10),
          padding: EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: kPrimaryColor,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              //BoxShadow
              BoxShadow(
                color: Colors.black12,
                offset: const Offset(0.0, 0.0),
                blurRadius: 0.0,
                spreadRadius: 2.0,
              ), //BoxShadow
            ],
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
      ),
      bottomNavigationBar: BottomNavigationBar(
        showUnselectedLabels: false,
        currentIndex: _pageNr,
        onTap: navigatePage,
        items: [
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.music_albums), label: 'Album'),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.music_mic), label: 'Artish'),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.music_note_2), label: 'Music'),
        ],
      ),
    );
  }

  void navigatePage(int value) {
    setState(() {
      _pageNr = value;
      _pageController.animateToPage(_pageNr,
          duration: Duration(milliseconds: 500), curve: Curves.ease);
    });
  }
}
