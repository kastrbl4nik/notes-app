import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:intl/intl.dart'; //DateFormat

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      darkTheme: ThemeData(
        colorSchemeSeed: Color.fromARGB(255, 227, 38, 54),
        brightness: Brightness.dark,
      ),
      theme: ThemeData(
        colorSchemeSeed: Color.fromARGB(255, 249, 249, 249),
        brightness: Brightness.light,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CollectionReference _notes =
      FirebaseFirestore.instance.collection('notes');

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  Future<void> _update([DocumentSnapshot? document]) async {
    if (document != null) {
      _titleController.text = document['title'];
      _descriptionController.text = document['description'];
    }
    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return Padding(
            padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                  ),
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  child: const Text('Update'),
                  onPressed: () async {
                    final String title = _titleController.text;
                    final String description = _descriptionController.text;

                    await _notes
                        .doc(document!.id)
                        .update({"title": title, "description": description});
                    _titleController.text = '';
                    _descriptionController.text = '';
                    Navigator.of(context).pop();
                  },
                )
              ],
            ),
          );
        });
  }

  Future<void> _delete([DocumentSnapshot? document]) async {
    await _notes.doc(document!.id).delete();

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('You\'ve successfully deleted your note!')));
  }

  Future<void> _create([DocumentSnapshot? document]) async {
    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return Padding(
            padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                  ),
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  child: const Text('Create'),
                  onPressed: () async {
                    final String title = _titleController.text;
                    final String description = _descriptionController.text;

                    await _notes.add({
                      "title": title,
                      "description": description,
                      "date": Timestamp.fromDate(DateTime.now())
                    });
                    _titleController.text = '';
                    _descriptionController.text = '';
                    Navigator.of(context).pop();
                  },
                )
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notes App"),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _create(),
      ),
      body: StreamBuilder(
        stream: _notes.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final document = snapshot.data!.docs[index];
              final timestamp = document['date'] as Timestamp;
              final date = DateFormat("yyyy-MM-dd").format(timestamp.toDate());
              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(document['title']),
                  leading: Text(date),
                  subtitle: Text(document['description']),
                  trailing: SizedBox(
                    width: 100,
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => _update(document),
                          icon: const Icon(Icons.edit),
                        ),
                        IconButton(
                          onPressed: () => _delete(document),
                          icon: const Icon(Icons.delete),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
