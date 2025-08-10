import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'login_page.dart';
import 'user_info_page.dart';
import 'playlist_page.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> musicList = [
    "آهنگ اول",
    "آهنگ دوم",
    "آهنگ سوم",
    "موزیک خاص",
  ];

  List<String> filteredList = [];
  TextEditingController searchController = TextEditingController();
  bool showAddOptions = false;

  @override
  void initState() {
    super.initState();
    filteredList = musicList;
  }

  void _filterMusic(String query) {
    setState(() {
      filteredList = musicList
          .where((song) => song.contains(query.trim()))
          .toList();
    });
  }

  void _addMusicFromServer() {
    List<String> serverSongs = ["موزیک سروری 1", "موزیک سروری 2"];

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView.builder(
          itemCount: serverSongs.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(serverSongs[index]),
              trailing: Icon(Icons.add),
              onTap: () {
                setState(() {
                  musicList.add(serverSongs[index]);
                  filteredList = musicList;
                });
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

  void _logout() {
    final authService = AuthService(host: '10.0.2.2', port: 3000);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage(authService: authService)),
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
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(value: 0, child: Text("اطلاعات کاربری")),
                PopupMenuItem(value: 1, child: Text("پلی‌لیست")),
                PopupMenuItem(value: 2, child: Text("تغییر مود دارک/لایت")),
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
                          trailing: Icon(Icons.play_arrow),
                          onTap: () {
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
