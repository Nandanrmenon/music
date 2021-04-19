import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:music_player/music_player.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:flutter/cupertino.dart';
import 'package:bmusic/helpers/my_flutter_app_icons.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BMusic',
      theme: ThemeData(
        primarySwatch: Colors.amber,
        fontFamily: 'Roboto',
        bottomSheetTheme: BottomSheetThemeData(
          backgroundColor: Colors.white,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        accentColor: Colors.amber,
        fontFamily: 'Roboto',
        bottomSheetTheme: BottomSheetThemeData(
          backgroundColor: Colors.black54,
        ),
      ),
      home: MyHomePage(title: 'BMusic'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

enum ListType { Album, Artist, Song }

class _MyHomePageState extends State<MyHomePage> {
  int _page = 0;
  bool playing = false;
  bool hasAlbum = false;
  bool hasArtist = false;
  bool hasSong = false;
  bool hasAlbumSongs = false;
  bool hasArtistSongs = false;
  bool showFAB = false;
  MusicPlayer musicPlayer;
  ListType currentList = ListType.Album;

  List<AlbumInfo> albums;
  List<AlbumInfo> albumList;
  List<ArtistInfo> artists;
  List<SongInfo> songs;
  List<SongInfo> albumSongs;
  List<SongInfo> artistSongs;
  List<SongInfo> curSongPlaylist;
  int currentSongIndex = 0;

  String nowPlayingSongname = "No current playing";
  String nowPlayingArtist = "Unknown";
  String nowPlayingAlbumArt = "";
  String nowPlayingDuration = "0:00";
  String nowPlayingElapsed = "0:00";
  String nowPlayingElapsedMS = "";

  Timer timer;

  final FlutterAudioQuery audioQuery = FlutterAudioQuery();

  PageController _pageController;

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    initPlatformState();
    _pageController = new PageController();
  }

  Future<void> initPlatformState() async {
    musicPlayer = MusicPlayer();
    musicPlayer.onIsPaused = _onPause;
    musicPlayer.onCompleted = _onCompleted;
    musicPlayer.onPlayNext = playNext;
    musicPlayer.onPlayPrevious = playPrev;
    albums = await audioQuery.getAlbums();
    artists = await audioQuery.getArtists();
    songs = await audioQuery.getSongs();

    timer = Timer.periodic(Duration(seconds: 1), elapsed);

    setState(() {
      hasAlbum = true;
      hasArtist = true;
      hasSong = true;
      showFAB = true;
    });
  }

  void _onPause() {
    setState(() {
      playing = false;
    });
  }

  void _onCompleted() {
    timer.cancel();
    if (currentSongIndex < curSongPlaylist.length - 1) {
      setState(() {
        currentSongIndex++;
      });
      play(curSongPlaylist[currentSongIndex]);
    } else {
      setState(() {
        playing = false;
      });
    }
  }

  Future<void> getSongs(String id) async {
    albumSongs = await audioQuery.getSongsFromAlbum(albumId: id);
    curSongPlaylist = albumSongs;
    setState(() {
      hasAlbumSongs = true;
    });
  }

  Future<void> getSongsByArtist(String artist) async {
    artistSongs = await audioQuery.getSongsFromArtist(artist: artist);
    curSongPlaylist = artistSongs;
    setState(() {
      hasArtistSongs = true;
    });
  }

  Future<void> play(SongInfo song) async {
    musicPlayer.stop();
    timer.cancel();
    setState(() {
      nowPlayingSongname = song.title;
      nowPlayingArtist = song.artist;
      nowPlayingAlbumArt = song.albumArtwork;
      nowPlayingElapsedMS = "0";
      nowPlayingDuration = parseToMinutesSeconds(int.parse(song.duration));
      playing = true;
    });
    timer = Timer.periodic(Duration(seconds: 1), elapsed);
//    print(currentSongIndex);
//    print('total->' + curSongPlaylist.length.toString());
    musicPlayer.play(MusicItem(
      trackName: song.title,
      albumName: song.album,
      artistName: song.artist,
      url: song.filePath,
      coverUrl: 'https://goo.gl/Wd1yPP',
      duration: Duration(seconds: parseToSeconds(int.parse(song.duration))),
    ));
  }

  void elapsed(Timer timer) {
    if (playing) {
      setState(() {
        int ms = int.parse(nowPlayingElapsedMS);
        ms = ms + 1000;
        nowPlayingElapsedMS = ms.toString();
        nowPlayingElapsed = parseToMinutesSeconds(ms);
        //print(parseToMinutesSeconds(ms));
      });
    }
  }

  Future<void> playNext() async {
    if (curSongPlaylist != null) {
      if (curSongPlaylist.length > 1) {
        if ((currentSongIndex < curSongPlaylist.length - 1) &&
            nowPlayingSongname.isNotEmpty) {
          currentSongIndex++;
          play(curSongPlaylist[currentSongIndex]);
        }
      }
    }
  }

  Future<void> playPrev() async {
    if (curSongPlaylist != null) {
      if (currentSongIndex > 0) {
        currentSongIndex--;
        play(curSongPlaylist[currentSongIndex]);
      }
    }
  }

  static String parseToMinutesSeconds(int ms) {
    String data;
    Duration duration = Duration(milliseconds: ms);

    int minutes = duration.inMinutes;
    int seconds = (duration.inSeconds) - (minutes * 60);

    data = minutes.toString() + ":";
    if (seconds <= 9) data += "0";

    data += seconds.toString();
    return data;
  }

  static int parseToSeconds(int ms) {
    Duration duration = Duration(milliseconds: ms);
    return duration.inSeconds;
  }

  void _navigationTapped(int index) {
    _pageController.animateToPage(index,
        duration: const Duration(milliseconds: 300), curve: Curves.ease);
  }

  void onPageChanged(int page) {
    setState(() {
      this._page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new DefaultTabController(
        length: 3,
        child: Scaffold(
          key: scaffoldKey,
          appBar: AppBar(
            centerTitle: true,
            title: Text(widget.title),
            automaticallyImplyLeading: false,
            bottom: new TabBar(tabs: <Widget>[
              new Tab(
                icon: Icon(MyFlutterApp.album),
              ),
              new Tab(
                icon: Icon(MyFlutterApp.personOutline),
              ),
              new Tab(
                icon: Icon(MyFlutterApp.musicNote),
              ),
            ]),
          ),
          body: new TabBarView(children: <Widget>[
            !hasAlbum
                ? _progressbar()
                : new ListView.builder(
                    shrinkWrap: true,
                    itemCount: hasAlbum ? albums.length : 0,
                    padding: EdgeInsets.only(bottom: 100.0),
                    itemBuilder: (context, position) {
                      return new ListTile(
                        leading: CircleAvatar(
                          backgroundImage: albums[position].albumArt == null
                              ? AssetImage('res/vynil.png')
                              : FileImage(File('${albums[position].albumArt}')),
                        ),
                        title: Text('${albums[position].title}'),
                        subtitle: Text(
                            '${albums[position].numberOfSongs}' + ' Songs'),
                        onTap: () {
                          setState(() {
                            hasAlbumSongs = false;
                            if (albumSongs != null) albumSongs.clear();
                          });

                          getSongs('${albums[position].id}');
                          showModalBottomSheet(
                            isDismissible: true,
                            context: context,
                            builder: (context) => StatefulBuilder(
                              builder:
                                  (BuildContext context, StateSetter setState) {
                                setState(() {
                                  showFAB = false;
                                });
                                return new ListView.builder(
                                    shrinkWrap: true,
                                    itemCount:
                                        hasAlbumSongs ? albumSongs.length : 0,
                                    itemBuilder: (context, index) {
                                      return index == 0
                                          ? new Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: <Widget>[
                                                Container(
                                                  padding: EdgeInsets.all(15.0),
                                                  child: Row(
                                                    children: <Widget>[
                                                      Expanded(
                                                        child: Text(
                                                          '${albums[position].title}',
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 18.0,
                                                          ),
                                                        ),
                                                      ),
                                                      IconButton(
                                                        icon: Icon(
                                                            MyFlutterApp.close),
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                new ListTile(
                                                  title: Text(
                                                      '${albumSongs[index].title}'),
                                                  trailing: Text(
                                                      parseToMinutesSeconds(
                                                          int.parse(
                                                              '${albumSongs[index].duration}'))),
                                                  onTap: () {
                                                    setState(() {
                                                      currentList =
                                                          ListType.Album;
                                                      currentSongIndex = index;
                                                    });
                                                    play(albumSongs[0]);
                                                  },
                                                )
                                              ],
                                            )
                                          : new ListTile(
                                              title: Text(
                                                  '${albumSongs[index].title}'),
                                              trailing: Text(
                                                  parseToMinutesSeconds(int.parse(
                                                      '${albumSongs[index].duration}'))),
                                              onTap: () {
                                                setState(() {
                                                  currentList = ListType.Album;
                                                  currentSongIndex = index;
                                                });
                                                play(albumSongs[index]);
                                              },
                                            );
                                    });
                              },
                            ),
                          ).whenComplete(() {
                            setState(() {
                              showFAB = true;
                            });
                          });
                        },
                      );
                    },
                  ),
            !hasArtist
                ? _progressbar()
                : new ListView.builder(
                    shrinkWrap: true,
                    itemCount: hasArtist ? artists.length : 0,
                    padding: EdgeInsets.only(bottom: 100.0),
                    itemBuilder: (context, position) {
                      return new ListTile(
                        title: Text('${artists[position].name}'),
                        subtitle: Text(
                            '${artists[position].numberOfTracks}' + ' Songs'),
                        leading: CircleAvatar(
                          backgroundImage: artists[position].artistArtPath ==
                                  null
                              ? AssetImage('res/singer.png')
                              : FileImage(
                                  File('${artists[position].artistArtPath}')),
                        ),
                        onTap: () {
                          setState(() {
                            hasArtistSongs = false;
                            if (artistSongs != null) artistSongs.clear();
                          });

                          getSongsByArtist('${artists[position].name}');
                          showModalBottomSheet(
                            context: context,
                            builder: (context) => StatefulBuilder(
                              builder:
                                  (BuildContext context, StateSetter setState) {
                                setState(() {
                                  showFAB = false;
                                });
                                return ListView.builder(
                                    shrinkWrap: true,
                                    itemCount:
                                        hasArtistSongs ? artistSongs.length : 0,
                                    itemBuilder: (context, index) {
                                      return index == 0
                                          ? new Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: <Widget>[
                                                Container(
                                                  padding: EdgeInsets.all(15.0),
                                                  child: Row(
                                                    children: <Widget>[
                                                      Expanded(
                                                        child: Text(
                                                          '${artists[position].name}',
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 18.0,
                                                          ),
                                                        ),
                                                      ),
                                                      IconButton(
                                                        icon: Icon(
                                                            MyFlutterApp.close),
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                new ListTile(
                                                  title: Text(
                                                      '${artistSongs[index].title}'),
                                                  trailing: Text(
                                                      parseToMinutesSeconds(
                                                          int.parse(
                                                              '${artistSongs[index].duration}'))),
                                                  onTap: () {
                                                    setState(() {
                                                      currentList =
                                                          ListType.Artist;
                                                      currentSongIndex = index;
                                                    });
                                                    play(artistSongs[0]);
                                                  },
                                                )
                                              ],
                                            )
                                          : new ListTile(
                                              title: Text(
                                                  '${artistSongs[index].title}'),
                                              trailing: Text(
                                                  parseToMinutesSeconds(int.parse(
                                                      '${artistSongs[index].duration}'))),
                                              onTap: () {
                                                setState(() {
                                                  currentList = ListType.Artist;
                                                  currentSongIndex = index;
                                                });
                                                play(artistSongs[index]);
                                              },
                                            );
                                    });
                              },
                            ),
                          ).whenComplete(() {
                            setState(() {
                              showFAB = true;
                            });
                          });
                        },
                      );
                    },
                  ),
            !hasSong
                ? _progressbar()
                : new ListView.builder(
                    shrinkWrap: true,
                    itemCount: hasSong ? songs.length : 0,
                    padding: EdgeInsets.only(bottom: 100.0),
                    itemBuilder: (context, position) {
                      return new ListTile(
                        leading: CircleAvatar(
                          backgroundImage: songs[position].albumArtwork == null
                              ? AssetImage('res/musical_note.png')
                              : FileImage(
                                  File('${songs[position].albumArtwork}')),
                        ),
                        title: Text('${songs[position].title}'),
                        subtitle: Text('${songs[position].artist}'),
                        onTap: () {
                          setState(() {
                            currentList = ListType.Song;
                            curSongPlaylist = songs;
                            currentSongIndex = position;
                          });
                          play(songs[position]);
                        },
                      );
                    },
                  ),
          ]),
          bottomSheet: BottomSheet(
            onClosing: () {},
            builder: (BuildContext context) {
              return Container(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(5.0),
                      child: Text(
                          '$nowPlayingSongname' + " : " + '$nowPlayingArtist'),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.all(5.0),
                          child: Text('$nowPlayingElapsed'),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              if (currentSongIndex > 0) {
                                currentSongIndex--;
                                play(curSongPlaylist[currentSongIndex]);
                              }
                            });
                          },
                          icon: Icon(MyFlutterApp.skipPrevious),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              if (currentSongIndex <
                                  curSongPlaylist.length - 1) {
                                currentSongIndex++;
                                play(curSongPlaylist[currentSongIndex]);
                              }
                            });
                          },
                          icon: Icon(MyFlutterApp.skipNext),
                        ),
                        Container(
                          padding: EdgeInsets.all(5.0),
                          child: Text('$nowPlayingDuration'),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          floatingActionButton: Visibility(
            child: new FloatingActionButton(
              onPressed: () {
                if (playing) {
                  musicPlayer.pause();
                  setState(() {
                    playing = false;
                  });
                } else {
                  musicPlayer.resume();
                  setState(() {
                    playing = true;
                  });
                }
//            showModalBottomSheet(
//                context: context,
//                isScrollControlled: true,
//                isDismissible: true,
//                builder: (context) => StatefulBuilder(
//                      builder: (BuildContext context, StateSetter setState) {
//                        return ListView(
//                          children: <Widget>[
//                            new Container(
//                              child: nowPlayingAlbumArt == null ||
//                                      nowPlayingAlbumArt.isEmpty
//                                  ? Image.asset('res/lady.jpeg')
//                                  : Image.file(File(nowPlayingAlbumArt)),
//                            ),
//                            new Container(
//                              padding: EdgeInsets.symmetric(horizontal: 15.0),
//                              margin: EdgeInsets.only(top: 15.0, bottom: 5.0),
//                              child: Text(
//                                nowPlayingSongname,
//                                style: TextStyle(
//                                    fontWeight: FontWeight.bold,
//                                    fontSize: 18.0),
//                              ),
//                            ),
//                            new Container(
//                              padding: EdgeInsets.symmetric(
//                                  horizontal: 15.0, vertical: 5.0),
//                              child: Text(
//                                nowPlayingArtist,
//                                style: TextStyle(fontWeight: FontWeight.bold),
//                              ),
//                            ),
//                            new Padding(
//                              padding: EdgeInsets.all(5.0),
//                              child: Row(
//                                mainAxisAlignment: MainAxisAlignment.center,
//                                children: <Widget>[
//                                  Container(
//                                    child: Text('$nowPlayingElapsed'),
//                                  ),
//                                  Slider(
//                                    value: .5,
//                                    onChanged: null,
//                                    label: 'Seek',
//                                  ),
//                                  Container(
//                                    child: Text(nowPlayingDuration),
//                                  ),
//                                ],
//                              ),
//                            ),
//                            new Padding(
//                              padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
//                              child: Row(
//                                mainAxisAlignment: MainAxisAlignment.center,
//                                children: <Widget>[
//                                  Container(
//                                    margin: EdgeInsets.only(right: 15.0),
//                                    child: IconButton(
//                                      onPressed: () {
//                                        setState(() {
//                                          if (currentSongIndex > 0) {
//                                            currentSongIndex--;
//                                            play(curSongPlaylist[currentSongIndex]);
//                                          }
//                                        });
//                                      },
//                                      icon: Icon(MyFlutterApp.skipPrevious),
//                                    ),
//                                  ),
//                                  Container(
//                                    child: RaisedButton(
//                                      color: Theme.of(context).accentColor,
//                                      shape: new RoundedRectangleBorder(
//                                          borderRadius:
//                                              new BorderRadius.circular(30.0),
//                                          side: BorderSide(
//                                              color: Theme.of(context)
//                                                  .accentColor)),
//                                      onPressed: () {
//                                        if (playing) {
//                                          musicPlayer.pause();
//                                          setState(() {
//                                            playing = false;
//                                          });
//                                        } else {
//                                          musicPlayer.resume();
//                                          setState(() {
//                                            playing = true;
//                                          });
//                                        }
//                                      },
//                                      child: playing
//                                          ? Icon(MyFlutterApp.pause)
//                                          : Icon(MyFlutterApp.playArrow),
//                                    ),
//                                  ),
//                                  Container(
//                                    margin: EdgeInsets.only(left: 15.0),
//                                    child: IconButton(
//                                      onPressed: () {
//                                        setState(() {
//                                          if (currentSongIndex < curSongPlaylist.length - 1) {
//                                            currentSongIndex++;
//                                            play(curSongPlaylist[currentSongIndex]);
//                                          }
//                                        });
//                                      },
//                                      icon: Icon(MyFlutterApp.skipNext),
//                                    ),
//                                  ),
//                                ],
//                              ),
//                            ),
//                          ],
//                        );
//                      },
//                    ));
              },
              child: IconButton(
                icon: (playing == true
                    ? Icon(MyFlutterApp.pause)
                    : Icon(MyFlutterApp.playArrow)),
              ),
            ),
            visible: true,
          ),
        ));
  }

  Widget _progressbar() {
    return Center(
        child: CircularProgressIndicator(
      strokeWidth: 2.0,
    ));
  }
}
