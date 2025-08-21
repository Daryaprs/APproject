class Music {
  String name;
  String filePath;

  Music({required this.name , required this.filePath});

  Map<String, dynamic> toJson() => {
    'name': name,
    'filePath': filePath,
  };
  factory Music.fromJson(Map<String, dynamic> json) {
    return Music(
      name: json['name'],
      filePath: json['filePath'],
    );
  }

}