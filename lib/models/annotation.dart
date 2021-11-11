import 'dart:convert';

class Annotation {
  String text;
  String annotation;

  Annotation({
    required this.text,
    required this.annotation,
  });

  factory Annotation.fromJson(Map<String, dynamic> json) {
    return Annotation(
      text: json['text'],
      annotation: json['annotation'],
    );
  }

  factory Annotation.parseResponseBody(String body) {
    final jsonData = json.decode(body);

    return Annotation.fromJson(jsonData);
  }

  static List<String> parseSourceData(String data) {
    String temp = data.replaceAll(RegExp(r'<!--[^{",}]*-->'), '');
    temp = temp.replaceAll('<!--', '<-split->').replaceAll('-->', '<-split->');
    List<String> stringList = List.empty(growable: true);
    stringList = temp.split('<-split->');
    for (int i = stringList.length - 1; i >= 0; i--) {
      if (stringList[i] == "") {
        stringList.removeAt(i);
      }
    }
    return stringList;
  }

  static String? getAnnotation(List<String>? data) {
    if (data == null) {
      return null;
    }
    RegExp annotationExp = RegExp(
      r'__ANNOTATION__=(.*)',
      caseSensitive: false,
    );
    for (int i = 0; i < data.length; i++) {
      if (annotationExp.hasMatch(data[i])) {
        String body = annotationExp.firstMatch(data[i])!.group(1)!;
        Annotation annotation = Annotation.parseResponseBody(body);
        return annotation.annotation;
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
        'text': text,
        'annotation': annotation,
      };
}
