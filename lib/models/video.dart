class Video {
  final String url;

  Video({required this.url});

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      url: json['url'],
    );
  }

  Map<String, dynamic> toJson() => {
        'url': url,
      };
}
