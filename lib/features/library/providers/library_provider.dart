import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nextflix/core/models/media.dart';

final libraryProvider = StateNotifierProvider<LibraryNotifier, List<Media>>((ref) {
  return LibraryNotifier();
});

class LibraryNotifier extends StateNotifier<List<Media>> {
  LibraryNotifier() : super([]) {
    _loadLibrary();
  }

  static const _key = 'nextflix_library';

  Future<void> _loadLibrary() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_key) ?? [];
    state = jsonList.map((item) => Media.fromJson(jsonDecode(item))).toList();
  }

  Future<void> toggleLibrary(Media media) async {
    final prefs = await SharedPreferences.getInstance();
    final exists = state.any((m) => m.id == media.id);
    
    if (exists) {
      state = state.where((m) => m.id != media.id).toList();
    } else {
      state = [...state, media];
    }

    final jsonList = state.map((item) => jsonEncode(item.toJson())).toList();
    await prefs.setStringList(_key, jsonList);
  }

  bool isInLibrary(int id) {
    return state.any((m) => m.id == id);
  }
}
