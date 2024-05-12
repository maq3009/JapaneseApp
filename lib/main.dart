import 'package:flutter/material.dart';
import 'package:flutter_application_3/image_grid.dart'; // Ensure this path is correct
import 'package:flutter_application_3/kanji_camera.dart'; // Make sure the path matches the location of your file
import 'package:flutter_application_3/kanji_model.dart'; // Ensure this is correctly pointing to your Kanji model
import 'package:flutter_application_3/kanji_repository.dart'; // Import the KanjiRepository

void main() {
  runApp(MaterialApp(
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
}

class KanjiDictionaryApp extends StatefulWidget {
  const KanjiDictionaryApp({super.key});

  @override
  _KanjiDictionaryAppState createState() => _KanjiDictionaryAppState();
}

class _KanjiDictionaryAppState extends State<KanjiDictionaryApp> {
  int currentIndex = 0;
  bool isLoading = true;
  List<Kanji> filteredKanji = [];
  bool isSearching = false;
  TextEditingController searchController = TextEditingController();
  String appBarTitle = 'Kanji Learner';

  @override
  void initState() {
    super.initState();
    loadKanjiData();
  }

  Future<void> loadKanjiData() async {
    try {
      await KanjiRepository().fetchAndSetKanji();
      setState(() => isLoading = false);
    } catch (e) {
      print('Failed to load Kanji data: $e');
    }
  }

  void searchKanji(String query) {
    if (query.isEmpty) {
      setState(() {
        isSearching = false;
      });
    } else {
      setState(() {
        isSearching = true;
        filteredKanji = KanjiRepository.kanjiList.where((kanji) {
          return kanji.meanings.any((m) => m.toLowerCase().contains(query.toLowerCase())) ||
                 kanji.onYomi.any((o) => o.toLowerCase().contains(query.toLowerCase())) ||
                 kanji.kunYomi.any((k) => k.toLowerCase().contains(query.toLowerCase()));
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: !isSearching ? Text(appBarTitle) : TextField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: 'Search kanji...',
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  searchController.clear();
                  isSearching = false;
                });
              },
            ),
          ),
          onChanged: searchKanji,
        ),
        centerTitle: true,
        actions: [
          if (!isSearching)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                setState(() {
                  isSearching = true;
                });
              },
            ),
        ],
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
              onTap: () => _updateTitleAndNavigate('Known Kanji'),
            ),
            ListTile(
              title: const Text('Unknown Kanji'),
              onTap: () => _updateTitleAndNavigate('Unknown Kanji'),
            ),
            ListTile(
              title: const Text('Kanji Camera'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => const KanjiCameraWidget(),
                ));
              },
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : isSearching ? buildSearchResults(filteredKanji) : buildKanjiDetails(KanjiRepository.kanjiList[currentIndex]),
    );
  }

    Widget buildSearchResults(List<Kanji> results) {
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: Icon(Icons.book),
          title: Text(results[index].character),
          subtitle: Text("${results[index].meanings.join(", ")}"),
          onTap: () {
            setState(() {
              currentIndex = KanjiRepository.kanjiList.indexOf(results[index]);
              isSearching = false;
              searchController.clear();
            });
          },
        );
      },
    );
  }

  Widget buildKanjiDetails(Kanji kanji) {
    return SingleChildScrollView(
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
              setState(() {
                kanji.isKnown = value!;
              });
            },
            secondary: const Icon(Icons.check),
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ],
      ),
    );
  }

  void _updateTitleAndNavigate(String title) {
    List<Kanji> filteredKanjiList = title == "Known Kanji" 
        ? KanjiRepository.kanjiList.where((kanji) => kanji.isKnown).toList()
        : KanjiRepository.kanjiList.where((kanji) => !kanji.isKnown).toList();

    Navigator.pop(context); // Close the drawer
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => KanjiGridScreen(kanjiList: filteredKanjiList, title: title),
    )).then((_) {
      setState(() {
        appBarTitle = 'Kanji Learner'; // Reset the AppBar title when returning from the grid screen
      });
    });
  }

  void _startSearch() {
    setState(() {
      isSearching = true;
      appBarTitle = 'Enter search term';
    });
  }
}
