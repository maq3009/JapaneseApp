import 'dart:convert';
import 'package:http/http.dart' as http;
import 'kanji_model.dart';

class KanjiRepository {
  static List<Kanji> kanjiList = []; // Static list to hold fetched Kanji
  final String url = 'https://raw.githubusercontent.com/davidluzgouveia/kanji-data/master/kanji-jouyou.json';

  Future<void> fetchAndSetKanji() async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // Assuming response is a map where each key is a Kanji character
      Map<String, dynamic> jsonData = jsonDecode(response.body);
      kanjiList.clear(); // Clear existing data before refilling
      jsonData.forEach((key, value) {
        kanjiList.add(Kanji.fromJson(key, value));
      });
    } else {
      throw Exception('Failed to load kanji data');
    }
  }
}