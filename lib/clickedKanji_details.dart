import 'package:flutter/material.dart';
import 'package:flutter_application_3/kanji_model.dart'; // Make sure this import path is correct

class KanjiDetailPage extends StatelessWidget {
  final Kanji kanji;

  const KanjiDetailPage({super.key, required this.kanji});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kanji Details'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(kanji.character, style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold)),
            Text("Meanings: ${kanji.meanings.join(", ")}"),
            Text("On-yomi: ${kanji.onYomi.join(", ")}"),
            Text("Kun-yomi: ${kanji.kunYomi.join(", ")}"),
            Text("Strokes: ${kanji.strokes}"),
            Text("Grade: ${kanji.grade}"),
            CheckboxListTile(
              title: const Text('Known?'),
              value: kanji.isKnown,
              onChanged: (bool? value) {
                // Assuming the Kanji model has a way to update its state
              },
              secondary: const Icon(Icons.check),
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ],
        ),
      ),
    );
  }
}
