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
  // ignore: library_private_types_in_public_api
  _KanjiDictionaryAppState createState() => _KanjiDictionaryAppState();
}

class _KanjiDictionaryAppState extends State<KanjiDictionaryApp> {
  int currentIndex = 0;
  bool isLoading = true;
  String currentKanji = '';
  String appBarTitle = 'Kanji Learner'; // Default title
  TextEditingController searchController = TextEditingController();

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
      print('Failed to load Kanji data: $e');  // Consider more robust error handling or UI feedback
    }
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isLoading ? 'Loading...' : 'Kanji Learner'),
        centerTitle: true,
        actions: [
          if (!isLoading) IconButton(icon: const Icon(Icons.search), onPressed: _startSearch),
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
        : Center(
            child: GestureDetector(
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity! < 0 && currentIndex < KanjiRepository.kanjiList.length - 1) {
                  setState(() => currentIndex++);
                } else if (details.primaryVelocity! > 0 && currentIndex > 0) {
                  setState(() => currentIndex--);
                }
              },
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(KanjiRepository.kanjiList[currentIndex].character, style: const TextStyle(fontSize: 80, fontWeight: FontWeight.bold)),
                    Text("Meanings: ${KanjiRepository.kanjiList[currentIndex].meanings.join(", ")}"),
                    Text("On-yomi: ${KanjiRepository.kanjiList[currentIndex].onYomi.join(", ")}"),
                    Text("Kun-yomi: ${KanjiRepository.kanjiList[currentIndex].kunYomi.join(", ")}"),
                    Text("Strokes: ${KanjiRepository.kanjiList[currentIndex].strokes}"),
                    Text("Grade: ${KanjiRepository.kanjiList[currentIndex].grade}"),
                    CheckboxListTile(
                      title: const Text('Known?'),
                      value: KanjiRepository.kanjiList[currentIndex].isKnown,
                      onChanged: (bool? value) {
                        setState(() {
                          KanjiRepository.kanjiList[currentIndex].isKnown = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
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
        // Reset the AppBar title when returning from the grid screen
        appBarTitle = 'Kanji Learner';
      });
    });
  }

  void _startSearch() {
    setState(() {
      // This would typically trigger a search functionality
      // For example, showing a search bar or filtering your kanji list
    });
  }
}