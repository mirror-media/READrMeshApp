import 'dart:convert';

class Annotation {
  String text;
  String annotation;
  bool isExpanded;

  Annotation({
    required this.text,
    required this.annotation,
    required this.isExpanded,
  });

  factory Annotation.fromJson(Map<String, dynamic> json) {
    return Annotation(
      text: json['text'],
      annotation: json['annotation'],
      isExpanded: json['isExpanded'] ?? false,
    );
  }

  factory Annotation.parseResponseBody(String body) {
    final jsonData = json.decode(body);

    return Annotation.fromJson(jsonData);
  }

  Map<String, dynamic> toJson() => {
        'text': text,
        'annotation': annotation,
        'isExpanded': isExpanded,
      };
}
