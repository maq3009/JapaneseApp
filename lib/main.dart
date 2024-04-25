import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(
home: const KanjiDictionaryApp(),
theme: ThemeData(
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.lightBlue,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
),
));

class KanjiDictionaryApp extends StatefulWidget {
  const KanjiDictionaryApp({super.key});

  @override
  _KanjiDictionaryAppState createState() => _KanjiDictionaryAppState();
}

class _KanjiDictionaryAppState extends State<KanjiDictionaryApp> {
  final List<List<String>> kanjiSets = [
    ['日', '月', '火', '水', '木', '金', '土', '山', '川', '田'],
    ['石', '花', '鳥', '雲', '星', '雨', '草', '虫', '風', '空'],
    // Add more sets as needed
  ];
  int currentSetIndex = 0;
  int currentKanjiIndex = 0;
  int swipeCount = 0;
  String currentKanji = '';
  bool _isSearching = false;
  final TextEditingController _searchQueryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    currentKanji = kanjiSets[currentSetIndex][currentKanjiIndex];
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  void _cancelSearch() {
    setState(() {
      _isSearching = false;
      _searchQueryController.clear();
    });
  }

  void _handleSwipe() {
    setState(() {
      swipeCount++;
      int swipesNeeded = (currentSetIndex == 0) ? 5 : 4;

      // Check if it's time to show a random kanji from previous set
      if (currentSetIndex > 0 && (swipeCount % swipesNeeded) == 3) {
        final previousSet = kanjiSets[currentSetIndex - 1];
        currentKanji = (previousSet..shuffle()).first;
      } else if (swipeCount >= swipesNeeded) {
        swipeCount = 0;
        currentKanjiIndex = (currentKanjiIndex + 1) % kanjiSets[currentSetIndex].length;

        if (currentKanjiIndex == 0 && currentSetIndex < kanjiSets.length - 1) {
          currentSetIndex++;
        }
        
        currentKanji = kanjiSets[currentSetIndex][currentKanjiIndex];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
          ? TextField(
            autofocus: true,
            controller: _searchQueryController,
            decoration: InputDecoration(
              hintText: 'Search...',
              border: InputBorder.none,
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: _cancelSearch,
              ),
            ),
            onSubmitted: (value) => _cancelSearch(),
          ) 
          : const Text(
          'Kanji Learner'),
        leading: _isSearching
          ? IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: _cancelSearch,
          )
          : Builder(
            builder: (BuildContext context) { 
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actions: !_isSearching
          ? [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: _startSearch,
            ),
          ]
          : [],
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Drawer Header'),
            ),
            ListTile(
              title: const Text('Known Kanji'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Unknown Kanji'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (DragEndDetails details) {
          if (details.primaryVelocity! < 0) { // Swipe to the right
            _handleSwipe();
            //Swipe right 5 times if you know this kanji
          }
        },
        child: Center(
          child: Text(
            currentKanji,
            style: const TextStyle(fontSize: 110, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
