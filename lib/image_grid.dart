import 'package:flutter/material.dart';
import 'package:flutter_application_3/kanji_model.dart'; // Ensure the path to Kanji model is correct
import 'package:flutter_application_3/clickedKanji_details.dart'; // Import the detail page

class KanjiGridScreen extends StatefulWidget {
  final List<Kanji> kanjiList;
  final String title;
  
  const KanjiGridScreen({super.key, required this.kanjiList, required this.title});

  @override
  _KanjiGridScreenState createState() => _KanjiGridScreenState();
}

class _KanjiGridScreenState extends State<KanjiGridScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Number of columns
          childAspectRatio: 1.0, // Aspect ratio of each card
          crossAxisSpacing: 4, // Horizontal space between cards
          mainAxisSpacing: 4, // Vertical space between cards
        ),
        itemCount: widget.kanjiList.length,
        itemBuilder: (context, index) {
          Kanji kanji = widget.kanjiList[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => KanjiDetailPage(kanji: kanji)),
              );
            },
            child: Card(
              child: GridTile(
                footer: GridTileBar(
                  backgroundColor: Colors.black45,
                  title: Text(kanji.meanings.join(', ')), // Optionally show meanings in the footer
                ),
                child: Center( // 'child' argument moved to be the last in the GridTile constructor
                  child: Text(
                    kanji.character,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
