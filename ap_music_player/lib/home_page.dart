import 'dart:convert';
import 'package:ap_music_player/Music.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';
import 'login_page.dart';
import 'music_player_page.dart';
import 'user_info_page.dart';
import 'playlist_page.dart';
import 'dart:typed_data';

class HomePage extends StatefulWidget {
  final AuthService authService;
  final String username;
  HomePage({required this.authService, required this.username});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Music> listOfMusics = [];
  List<String> musicNameList = [];

  List<String> filteredList = [];
  TextEditingController searchController = TextEditingController();
  bool showAddOptions = false;

  String _sortType = "date";

  @override
  void initState() {
    super.initState();
    _loadSongs();
    filteredList = musicNameList;
  }
  Future<void> _loadSongs() async {
    final prefs = await SharedPreferences.getInstance();

    // final localJson = prefs.getString("songs") ?? "[]";
    // final List localDecoded = jsonDecode(localJson);
    // List<Music> localSongs = localDecoded.map((e) => Music.fromJson(e)).toList();

    List<String> homePageMusicName = [];
    List<Music> homePageMusics = await widget.authService.fetchHomePageMusicNames(widget.username);;
    for(Music music in homePageMusics){
      homePageMusicName.add(music.name);
    }

    setState(() {
      listOfMusics = homePageMusics;
      for(Music music in listOfMusics){
        musicNameList.add(music.name);
      }
    });
  }

  void _applySort() {
    setState(() {
      if (_sortType == "date") {
        listOfMusics.sort((a, b) => b.addedAt.compareTo(a.addedAt));
      } else if (_sortType == "alphabet") {
        listOfMusics.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      }
      musicNameList = listOfMusics.map((m) => m.name).toList();
      filteredList = musicNameList;
    });
  }

  void _filterMusic(String query) {
    setState(() {
      filteredList = musicNameList
          .where((song) => song.contains(query.trim()))
          .toList();
    });
  }
  void _addMusicFromServer() async{
    List<String> serverSongs = await widget.authService.fetchServerSongNames() ;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView.builder(
          itemCount: serverSongs.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(serverSongs[index]),
              trailing: Icon(Icons.add),
              onTap: () async {
                Music music = Music(name: serverSongs[index], filePath: "Musics/${serverSongs[index]}", addedAt: DateTime.now().millisecondsSinceEpoch, isFavorite: false);
                String response = await widget.authService.addSong(widget.username, music);
                if(response=="Added") {
                  setState((){
                    musicNameList.add(serverSongs[index]);
                    listOfMusics.add(music);
                    filteredList = musicNameList;
                  });
                }
                Navigator.pop(context);
                },
            );
            },
        );
        },
    );
  }

  void _addMusicFromStorage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('افزودن از حافظه (در حال توسعه...)')),
    );
  }

  Future<void> _logout() async {
    await AuthService.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage(authService: widget.authService)),
    );
  }

  void _goToUserInfo() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UserInfoPage()),
    );
  }

  void _goToPlaylist() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PlaylistPage()),
    );
  }

  void _toggleTheme() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("تغییر مود دارک/لایت در نسخه بعدی افزوده می‌شود")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.orange,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.orange,
          iconTheme: IconThemeData(color: Colors.orange),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.orange,
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
        ),
        cardColor: Colors.grey[900],
        iconTheme: IconThemeData(color: Colors.orange),
        popupMenuTheme: PopupMenuThemeData(
          color: Colors.grey[850],
          textStyle: TextStyle(color: Colors.white),
        ),
      ),
      child: Scaffold(
          appBar: AppBar(
            title: Text("موزیک پلیر"),
            actions: [
              PopupMenuButton<int>(
                icon: Icon(Icons.menu),
                onSelected: (value) {
                  switch (value) {
                    case 0:
                      _goToUserInfo();
                      break;
                    case 1:
                      _goToPlaylist();
                      break;
                    case 2:
                      _toggleTheme();
                      break;
                    case 3:
                      setState(() {
                        _sortType = "date";
                        _applySort();
                      });
                      break;
                    case 4:
                      setState(() {
                        _sortType = "alphabet";
                        _applySort();
                      });
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(value: 0, child: Text("اطلاعات کاربری")),
                  PopupMenuItem(value: 1, child: Text("پلی‌لیست")),
                  PopupMenuItem(value: 2, child: Text("تغییر مود دارک/لایت")),
                  PopupMenuDivider(),
                  PopupMenuItem(value: 3, child: Text("مرتب‌سازی بر اساس تاریخ")),
                  PopupMenuItem(value: 4, child: Text("مرتب‌سازی بر اساس حروف الفبا")),
                ],
              ),
              IconButton(
                icon: Icon(Icons.logout),
                onPressed: _logout,
                tooltip: "خروج",
              ),
            ],
          ),

          body: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.85,
                      decoration: BoxDecoration(
                        color: Colors.grey[900], // زمینه تیره
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: searchController,
                        onChanged: _filterMusic,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'جستجوی آهنگ...',
                          hintStyle: TextStyle(color: Colors.white60),
                          prefixIcon: Icon(Icons.search, color: Colors.orange),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListTile(
                          leading: Icon(Icons.music_note),
                          title: Text(filteredList[index]),
                          trailing: PopupMenuButton<String>(
                            icon: Icon(Icons.more_vert),
                            onSelected: (value) async {
                              if (value == 'favorite') {
                                setState(() {
                                  widget.authService.addToFavorites(widget.username, listOfMusics[index]);
                                });
                              } else if (value == 'delete') {
                                String response = await widget.authService.deleteSong(widget.username, listOfMusics[index]);
                                if(response == "deletedSuccessfully") {
                                  setState(() {
                                    musicNameList.removeAt(index);
                                    listOfMusics.removeAt(index);
                                    filteredList = musicNameList;
                                  });
                                }
                              } else if (value == 'playlist') {
                                print("Add to playlist: ${listOfMusics[index].name}");
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'favorite',
                                child: Row(
                                  children: [
                                    Icon(Icons.favorite, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('افزودن به علاقه‌مندی‌ها'),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, color: Colors.grey),
                                    SizedBox(width: 8),
                                    Text('حذف آهنگ'),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'playlist',
                                child: Row(
                                  children: [
                                    Icon(Icons.playlist_add, color: Colors.blue),
                                    SizedBox(width: 8),
                                    Text('افزودن به پلی‌لیست'),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MusicPlayerPage(songList: filteredList, initialIndex: index, authService: widget.authService)
                              ),
                            );
                            // صفحه پخش آهنگ
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 20,
              left: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showAddOptions) ...[
                    FloatingActionButton.extended(
                      heroTag: "server",
                      onPressed: _addMusicFromServer,
                      icon: Icon(Icons.cloud_download),
                      label: Text("از سرور"),
                      backgroundColor: Colors.blueGrey,
                    ),
                    SizedBox(height: 10),
                    FloatingActionButton.extended(
                      heroTag: "storage",
                      onPressed: _addMusicFromStorage,
                      icon: Icon(Icons.folder),
                      label: Text("از حافظه"),
                      backgroundColor: Colors.teal,
                    ),
                    SizedBox(height: 10),
                  ],
                  FloatingActionButton(
                    heroTag: "main",
                    onPressed: () {
                      setState(() {
                        showAddOptions = !showAddOptions;
                      });
                    },
                    backgroundColor: Colors.orange,
                    child: Icon(Icons.library_music),
                    tooltip: "افزودن آهنگ",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
