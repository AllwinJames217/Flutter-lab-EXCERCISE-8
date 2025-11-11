import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const LibrarySearchApp());
}

class LibrarySearchApp extends StatelessWidget {
  const LibrarySearchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Library Book Search System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const LibrarySearchScreen(),
    );
  }
}

class LibrarySearchScreen extends StatefulWidget {
  const LibrarySearchScreen({super.key});

  @override
  State<LibrarySearchScreen> createState() => _LibrarySearchScreenState();
}

class _LibrarySearchScreenState extends State<LibrarySearchScreen> {
  final TextEditingController titleController = TextEditingController();
  final CollectionReference books =
      FirebaseFirestore.instance.collection('books');

  Map<String, dynamic>? searchedBook;
  String message = "";

  Future<void> searchBook() async {
    final title = titleController.text.trim();
    if (title.isEmpty) return;

    // Clear previous results
    setState(() {
      searchedBook = null;
      message = "";
    });

    try {
      final querySnapshot =
          await books.where('title', isEqualTo: title).get();

      if (querySnapshot.docs.isEmpty) {
        setState(() {
          message = "Book not found";
        });
        return;
      }

      final data = querySnapshot.docs.first.data() as Map<String, dynamic>;
      setState(() {
        searchedBook = data;
      });
    } catch (e) {
      setState(() {
        message = "Error fetching data: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Library Book Search System")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Enter Book Title",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: searchBook,
              child: const Text("Search"),
            ),
            const SizedBox(height: 20),

            // Display results
            if (searchedBook != null)
              Card(
                elevation: 3,
                child: ListTile(
                  title: Text(
                    "${searchedBook!['title']} – ${searchedBook!['author']}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: searchedBook!['copies'] == 0
                      ? const Text(
                          "Not Available – All Copies Issued",
                          style: TextStyle(
                              color: Colors.red, fontWeight: FontWeight.bold),
                        )
                      : Text("Copies Available: ${searchedBook!['copies']}"),
                ),
              )
            else if (message.isNotEmpty)
              Text(
                message,
                style: TextStyle(
                  color: message.contains("not found") ? Colors.red : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
