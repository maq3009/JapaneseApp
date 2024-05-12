import 'package:flutter/material.dart';
import 'kanji_model.dart'; // Ensure this is your Kanji model file path

class KanjiListScreen extends StatefulWidget {
  final List<Kanji> kanjiList;

  const KanjiListScreen({super.key, required this.kanjiList});

  @override
  _KanjiListScreenState createState() => _KanjiListScreenState();
}

class _KanjiListScreenState extends State<KanjiListScreen> {
  void toggleKnown(Kanji kanji) {
    setState(() {
      kanji.isKnown = !kanji.isKnown;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kanji List"),
      ),
      body: ListView.builder(
        itemCount: widget.kanjiList.length,
        itemBuilder: (context, index) {
          Kanji kanji = widget.kanjiList[index];
          return ListTile(
            title: Text(kanji.character),
            trailing: IconButton(
              icon: Icon(kanji.isKnown ? Icons.check_box : Icons.check_box_outline_blank),
              onPressed: () => toggleKnown(kanji),
            ),
            onTap: () {
              // Navigation to a detailed screen could go here
              // For now, it just toggles the known state
              toggleKnown(kanji);
            },
          );
        },
      ),
    );
  }
}
