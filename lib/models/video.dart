class Video {
  final String id;
  final String title;
  final String url;
  final String uploaderId;
  final DateTime uploadDate;

  Video({
    required this.id,
    required this.title,
    required this.url,
    required this.uploaderId,
    required this.uploadDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'uploaderId': uploaderId,
      'uploadDate': uploadDate.toIso8601String(),
    };
  }

  factory Video.fromMap(Map<String, dynamic> map) {
    return Video(
      id: map['id'] as String,
      title: map['title'] as String,
      url: map['url'] as String,
      uploaderId: map['uploaderId'] as String,
      uploadDate: DateTime.parse(map['uploadDate'] as String),
    );
  }
}
