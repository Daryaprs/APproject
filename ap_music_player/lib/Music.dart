class Music {
  String name;
  String filePath;
  int addedAt;
  bool isFavorite;


  Music({required this.name , required this.filePath , required this.addedAt, required this.isFavorite});

  Map<String, dynamic> toJson() => {
    'name': name,
    'filePath': filePath,
    'addedAt': addedAt,
    'isFavorite': isFavorite,
  };
  factory Music.fromJson(Map<String, dynamic> json) {
    return Music(
      name: json['name'],
      filePath: json['filePath'],
      addedAt: json['addedAt'],
      isFavorite: json['isFavorite'],
    );
  }
  DateTime get addedDate => DateTime.fromMillisecondsSinceEpoch(addedAt);


}