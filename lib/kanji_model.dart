class Kanji {
  String character;
  List<String> meanings;
  int strokes;
  int grade;
  List<String> onYomi;
  List<String> kunYomi;
  bool isKnown;

  Kanji({
    required this.character,
    required this.meanings,
    required this.strokes,
    required this.grade,
    required this.onYomi,
    required this.kunYomi,
    this.isKnown = false,
  });

  factory Kanji.fromJson(String character, Map<String, dynamic> json) {
    return Kanji(
      character: character,
      meanings: List<String>.from(json['meanings'] ?? []),
      strokes: json['strokes'],
      grade: json['grade'],
      onYomi: List<String>.from(json['readings_on'] ?? []),
      kunYomi: List<String>.from(json['readings_kun'] ?? []),
      isKnown: false,  // Default to false as this isn't part of the JSON data
    );
  }
}

