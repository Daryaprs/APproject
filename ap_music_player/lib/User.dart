import 'dart:io';
import 'dart:convert';

class User {
  String username;
  String password;

  User({required this.username, required this.password});

  Map<String, dynamic> toJson() => {
    'username': username,
    'password': password,
  };
}

void sendLoginData(User user) async {
  try {
    final socket = await Socket.connect('10.0.2.2', 3000);
    Map<String, dynamic> userJson = user.toJson();
    userJson["type"] = "login";
    String jsonData = jsonEncode(userJson);
    socket.write(jsonData);
    print('Data sent: $jsonData');

    // Listen for response
    socket.listen((List<int> data) {
      String response = utf8.decode(data);
      print('Server response: $response');
    });

    await Future.delayed(Duration(seconds: 2));
    socket.close();
  } catch (e) {
    print("Socket error: $e");
  }
}
void sendSignupData(User user) async {
  try {
    final socket = await Socket.connect('10.0.2.2', 3000);
    Map<String, dynamic> userJson = user.toJson();
    userJson["type"] = "signup";
    String jsonData = jsonEncode(userJson);
    socket.write(jsonData);
    print('Data sent: $jsonData');

    // Listen for response
    socket.listen((List<int> data) {
      String response = utf8.decode(data);
      print('Server response: $response');
    });

    await Future.delayed(Duration(seconds: 2));
    socket.close();
  } catch (e) {
    print("Socket error: $e");
  }
}
