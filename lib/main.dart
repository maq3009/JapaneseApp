import 'package:flutter/material.dart';
import 'package:flutter_application_3/image_grid.dart'; // Ensure this path is correct
import 'kanji_camera.dart'; // Make sure the path matches the location of your file


void main() => runApp(MaterialApp(
  home: const KanjiDictionaryApp(),
  theme: ThemeData(
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.lightBlue,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 26,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
));

class KanjiDictionaryApp extends StatefulWidget {
  const KanjiDictionaryApp({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _KanjiDictionaryAppState createState() => _KanjiDictionaryAppState();
}

class _KanjiDictionaryAppState extends State<KanjiDictionaryApp> {
  final List<List<String>> kanjiSets = [
    ['日', '月', '火', '水', '木', '金', '土', '山', '川', '田'],
    ['石', '花', '鳥', '雲', '星', '雨', '草', '虫', '風', '空'],
  ];
  String currentKanji = '';
  String appBarTitle = 'Kanji Learner'; // Default title
  bool _isSearching = false;
  final TextEditingController _searchQueryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize with the first Kanji
    currentKanji = kanjiSets[0][0];
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
      appBarTitle = 'Kanji Learner'; // Reset title when search is canceled
    });
  }

  void _updateTitleAndNavigate(String title, List<String> kanjiList) {
    setState(() {
      appBarTitle = title; // Update the AppBar title
    });
    Navigator.pop(context); // Close the drawer
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => KanjiGridScreen(kanjiList: kanjiList),
    )).then((_) {
      setState(() {
        appBarTitle = 'Kanji Learner'; // Reset the AppBar title when returning
      });
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
            : Text(appBarTitle),
        leading: _isSearching
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _cancelSearch,
              )
            : Builder(
                builder: (BuildContext context) {
                  return IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  );
                },
              ),
        actions: !_isSearching
            ? [IconButton(icon: const Icon(Icons.search), onPressed: _startSearch)]
            : [],
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('Drawer Header'),
            ),
            ListTile(
              title: const Text('Known Kanji'),
              onTap: () => _updateTitleAndNavigate('Known Kanji', kanjiSets.expand((set) => set).toList()),
            ),
            ListTile(
              title: const Text('Unknown Kanji'),
              onTap: () => _updateTitleAndNavigate('Unknown Kanji', kanjiSets.expand((set) => set).toList()),
            ),
            ListTile(
              title: const Text('Kanji Camera'),
              onTap: ()  {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => const KanjiCameraWidget(),
                ));
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Text(
          currentKanji,
          style: const TextStyle(fontSize: 110, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
