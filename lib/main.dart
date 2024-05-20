import 'package:flutter/material.dart';
import 'package:flutter_application_3/about_page.dart';
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
  int currentIndex = 0;  //current index of the kanji
  bool isLoading = true;  //whether the kanji screen is loading or not
  List<Kanji> filteredKanji = [];
  bool isSearching = false;  //whether the user is searching or not
  TextEditingController searchController = TextEditingController();
  String appBarTitle = 'Kanji Learner';  //beginning appbar screen title

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
      // ignore: avoid_print
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
        // user can search by meaning, onyomi or kun yomi
        //turns the search term into lowercase and checks whether it contains that term
          return kanji.meanings.any((meaning) => meaning.toLowerCase().contains(query.toLowerCase())) ||
                 kanji.onYomi.any((onyomi) => onyomi.toLowerCase().contains(query.toLowerCase())) ||
                 kanji.kunYomi.any((kunyomi) => kunyomi.toLowerCase().contains(query.toLowerCase()));
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
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 23.0),
                    child: CircleAvatar(
                      radius: 35,  // Adjust the radius
                      backgroundImage: AssetImage('assets/Enso.jpg'),
                    ),
                  ),
                  SizedBox(width: 16), // Add some spacing between the image and the text
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: 16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kanji Learner',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'App Menu', // Replace with your actual subtitle
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(
              icon: Icons.book,
              text: 'Known Kanji',
              onTap: () => _updateTitleAndNavigate('Known Kanji'),
            ),
            _buildDrawerItem(
              icon: Icons.bookmark,
              text: 'Not-known Kanji',
              onTap: () => _updateTitleAndNavigate('Not-known Kanji'),
            ),
            _buildDrawerItem(
              icon: Icons.camera_alt,
              text: 'Kanji Camera',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => const KanjiCameraWidget(),
                ));
              },
            ),
            _buildDrawerItem(
              icon: Icons.info,
              text: 'About',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => const AboutPage(),
                ));
              },
            ),
          ],
        ),
      ),
      body: Container(
        color: Colors.lightBlue[100],
        child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : isSearching ? buildSearchResults(filteredKanji) : buildKanjiDetails(KanjiRepository.kanjiList[currentIndex]),
      ),
    );
  }

  Widget buildSearchResults(List<Kanji> results) {
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const Icon(Icons.book),
          title: Text(results[index].character),
          subtitle: Text(results[index].meanings.join(", ")),
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

Widget buildKanjiDetails(Kanji kanji) {  //Handles Swiping
  return GestureDetector(
    onHorizontalDragEnd: (DragEndDetails details) {
      // Determine the direction of the swipe
      if (details.primaryVelocity! < 0) { // Swiping left to go to the next kanji
        if (currentIndex < KanjiRepository.kanjiList.length - 1) {
          setState(() {
            currentIndex++;
          });
        }
      } else if (details.primaryVelocity! > 0) { // Swiping right to go to the previous kanji
        if (currentIndex > 0) {
          setState(() {
            currentIndex--;
          });
        }
      }
    },
    child: Center(
      child: Container(
        color: Colors.lightBlue[100],
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Card(        
          elevation: 20,
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(kanji.character, style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text("Meanings: ${kanji.meanings.join(", ")}"),
                const SizedBox(height: 10),
                Text("On-yomi: ${kanji.onYomi.join(", ")}"),
                const SizedBox(height: 10),
                Text("Kun-yomi: ${kanji.kunYomi.join(", ")}"),
                const SizedBox(height: 10),
                Text("Strokes: ${kanji.strokes}"),
                const SizedBox(height: 10),
                Text("Grade: ${kanji.grade}"),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: Divider(
                    color: Colors.orange,
                    thickness: 10.0,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: CheckboxListTile(
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
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

  Widget _buildDrawerItem({
    required IconData icon,
    required String text,
    required GestureTapCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.blueAccent,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 2,
              offset: const Offset(0, 2), // changes position of shadow
            ),
          ],
        ),
        child: ListTile(
          leading: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Icon(icon),
          ),
          title: Text(text),
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
