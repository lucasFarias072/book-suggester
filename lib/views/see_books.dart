import 'package:flutter/material.dart';

// Db manager
import 'package:book_suggester/services/sqflite.dart';

// Models
import 'package:book_suggester/models/suggestion.dart';

// Utils
import 'package:book_suggester/utils/future_categories.dart';
// import 'package:book_suggester/utils/message.dart';

class SeeBooksView extends StatefulWidget {
  const SeeBooksView({super.key});

  @override
  State<SeeBooksView> createState() => _SeeBooksViewState();
}

class _SeeBooksViewState extends State<SeeBooksView> {
  final DatabaseHelper _db = DatabaseHelper();
  final _categoriesController = CategoriesContainer();
  // final _messageController = MessageWidget();

  Widget returnEmptyDb() {
    return const Center(child: Text('Nenhum dado encontrado'));
  }

  Widget returnInfiniteProgressCircle() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget returnSuggestionInfoTile(Suggestion suggestion) {
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.person, color: Colors.amber),
            Text(suggestion.nickname,
            style: const TextStyle(color: Color.fromARGB(255, 170, 220, 255))),
          ],
        ),
        Text("Autor: ${suggestion.authorName}",
            style: const TextStyle(color: Colors.white)),
        Text("Título: ${suggestion.bookTitle}",
            style: const TextStyle(color: Colors.white)),
        Text("Descrição: ${suggestion.opinion}",
            style: const TextStyle(color: Colors.white)),
        Text("ID: ${suggestion.id}",
            style: const TextStyle(color: Colors.white)),
        Text(
          "Gênero: ${_categoriesController.callCategories()[suggestion.categoryId]["name"]}",
          style: const TextStyle(color: Color.fromARGB(255, 200, 200, 0)),
        ),
        // TextButton(
        //     style: TextButton.styleFrom(
        //       backgroundColor: const Color.fromARGB(255, 60, 10, 30),
        //     ),
        //     onPressed: () async {
        //       await _db.deleteSuggestion(suggestion.id ?? 0);
        //       _messageController.informUser(
        //           'Sugestão removida! saia e entre novamente para ver!',
        //           context);
        //     },
        //     child: const Text("remover", style: TextStyle(color: Colors.white)))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Future<List<Suggestion>> suggestions = _db.getSuggestions();

    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 70, 20, 40),
          title: const Text("Livros sugeridos",
              style: TextStyle(color: Color.fromARGB(255, 200, 200, 100))),
        ),
        body: Container(
            decoration:
                const BoxDecoration(color: Color.fromARGB(255, 66, 11, 44)),
            child: FutureBuilder<List<Suggestion>>(
              future: suggestions,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return returnInfiniteProgressCircle();
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return returnEmptyDb();
                }

                final data = snapshot.data!;

                return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final item = data[index];
                    return ListTile(
                        title: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 90, 40, 60),
                                border: Border.all(
                                    color: const Color.fromARGB(
                                        255, 110, 60, 80)),
                                borderRadius: BorderRadius.circular(10)),
                            child: returnSuggestionInfoTile(item)));
                  },
                );
              },
            )));
  }
}
