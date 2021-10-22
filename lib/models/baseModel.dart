class BaseModel {
  static const idKey = 'id';
  static const nameKey = 'name';
  static const slugKey = 'slug';

  static bool checkJsonKeys(Map<String, dynamic> json, List<String> keys) {
    Map<String, dynamic> checkJson = json;
    for (int i = 0; i < keys.length; i++) {
      String key = keys[i];
      if (!hasKey(checkJson, key)) {
        return false;
      }

      if (i < keys.length - 1) {
        checkJson = checkJson[key];
      }
    }

    return true;
  }

  static bool hasKey(Map<String, dynamic> json, String key) {
    return json.containsKey(key) && json[key] != null;
  }
}
