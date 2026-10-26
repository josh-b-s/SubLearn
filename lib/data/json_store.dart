import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// JSON values kept in SharedPreferences, one key per collection.
class JsonStore {
  const JsonStore(this._prefs);

  final SharedPreferences _prefs;

  List<T> readList<T>(String key, T Function(Map<String, dynamic>) fromJson) {
    final raw = _prefs.getString(key);
    if (raw == null) return [];
    return (jsonDecode(raw) as List).map((e) => fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> writeList<T>(String key, List<T> items, Map<String, dynamic> Function(T) toJson) =>
      _prefs.setString(key, jsonEncode(items.map(toJson).toList()));

  Map<String, dynamic> readMap(String key) {
    final raw = _prefs.getString(key);
    return raw == null ? {} : jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> writeMap(String key, Map<String, dynamic> value) =>
      _prefs.setString(key, jsonEncode(value));
}
