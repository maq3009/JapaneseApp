import "package:flutter/material.dart";

class KanjiGridScreen extends StatelessWidget {
  final List<String> kanjiList;
  
  const KanjiGridScreen({super.key, required this.kanjiList});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Known Kanji Grid'),
      ),
      body: GridView.count(
        // Create a grid with 2 columns. If you change the scrollDirection to horizontal, this produces 2 rows.
        crossAxisCount: 2,
        //Generate 100 widgets that display their index in the List.  
        children: List.generate(kanjiList.length, (index) {
          // double fontSize = 35;
                  
          return Center(
            child: Text(
              kanjiList[index],
              style: Theme.of(context).textTheme.displayLarge,
            ),
          );
        }),
      ),
    );
  }
}