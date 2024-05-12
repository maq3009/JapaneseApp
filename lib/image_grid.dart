import 'package:flutter/material.dart';
import 'package:flutter_application_3/kanji_model.dart'; // Correctly import Kanji model

class KanjiGridScreen extends StatefulWidget {
  final List<Kanji> kanjiList;
  final String title;
  
  const KanjiGridScreen({super.key, required this.kanjiList, required this.title});

  @override
  // ignore: library_private_types_in_public_api
  _KanjiGridScreenState createState() => _KanjiGridScreenState();
}

class _KanjiGridScreenState extends State<KanjiGridScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title), // Now properly referencing the title
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2), // Create a grid with 2 columns.
        itemCount: widget.kanjiList.length, // Corrected itemCount property
        itemBuilder: (context, index) { // Added missing itemBuilder argument
          Kanji kanji = widget.kanjiList[index]; // Correctly reference Kanji instance from the list
          return Card(
            child: Center(
              child: Text(
                kanji.character, // Correctly display the Kanji character
                style: Theme.of(context).textTheme.displayLarge, // Correct style reference
              ),
            ),
          );
        },
      ),
    );
  }
}
