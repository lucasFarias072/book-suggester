import 'package:flutter/material.dart';

// Db manager
import 'package:book_suggester/services/sqflite.dart';

// Models
import 'package:book_suggester/models/suggestion.dart';

// Utils
import 'package:book_suggester/utils/future_categories.dart';
import 'package:book_suggester/utils/router.dart';
import 'package:book_suggester/utils/message.dart';
import 'package:book_suggester/utils/dropdown_issue_solver.dart';

// Notifier
import 'package:provider/provider.dart';

// Controllers
import 'package:book_suggester/controllers/user_session.dart';

class AddBookView extends StatefulWidget {
  const AddBookView({super.key});

  @override
  State<AddBookView> createState() => _AddBookViewState();
}

class _AddBookViewState extends State<AddBookView> {
  final DatabaseHelper _db = DatabaseHelper();

  final _formKey = GlobalKey<FormState>();

  // Controllers
  // final _nicknameController = TextEditingController();
  final _authorNameController = TextEditingController();
  final _bookTitleController = TextEditingController();
  final _bookOpinionController = TextEditingController();

  final _message = MessageWidget();
  final _router = RouterWidget();

  Suggestion? newSuggestion;

  final defaultCategories = CategoriesContainer();

  // Dropdown representative
  CustomCategory? selectedCategory;

  Future<String> linkSuggestionToNickname(UserSessionController ctrll) async {
    Future<Map<String, dynamic>> personWhoSuggestedObject =
        _db.queryByEmail(ctrll.userInSession, 'users');
    Map<String, dynamic> personWhoSuggestedContent =
        await personWhoSuggestedObject;
    return personWhoSuggestedContent['nickname'];
  }

  Widget returnInput(
      String infoTxt, String warningTxt, TextEditingController ctrll) {
    return TextFormField(
        style: const TextStyle(color: Colors.white),
        controller: ctrll,
        decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: infoTxt,
            fillColor: Colors.white,
            labelStyle: const TextStyle(color: Colors.white)),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return warningTxt;
          }
          return null;
        });
  }

  Widget returnInputLight(String infoTxt, TextEditingController ctrll) {
    return TextFormField(
      style: const TextStyle(color: Colors.white),
      controller: ctrll,
      decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: infoTxt,
          fillColor: Colors.white,
          labelStyle: const TextStyle(color: Colors.white)),
    );
  }

  PreferredSizeWidget returnAppBar(Color background, Color txt) {
    return AppBar(
      backgroundColor: background,
      title: Text("Indique um livro", style: TextStyle(color: txt)),
    );
  }

  Widget returnSuggestionForm() {
    Map<String, String> inputExceptions = {
      'author': "Atenção! o autor é obrigatório",
      'book_title': "Atenção! o título é obrigatório",
      'description': "Atenção! a descrição é obrigatória",
    };

    final userSessionController = Provider.of<UserSessionController>(context);

    return Form(
        key: _formKey,
        child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(children: <Widget>[
              // todo: Input for author
              returnInput("nome do autor", inputExceptions['author']!,
                  _authorNameController),
              const SizedBox(height: 4),

              // todo: Input for the title of the book
              returnInput("título do livro", inputExceptions['book_title']!,
                  _bookTitleController),
              const SizedBox(height: 4),

              // todo: Input for the summary of the book
              returnInput("opinião", "Por favor, insira sua opinião!",
                  _bookOpinionController),
              const SizedBox(height: 4),

              // todo: Dropdown of categories
              DropdownButton<CustomCategory>(
                value: selectedCategory,
                hint: const Text('selecione uma categoria'),
                items: defaultCategories.callCategories().map((category) {
                  return DropdownMenuItem<CustomCategory>(
                    value: CustomCategory(
                      id: category['id'],
                      name: category['name'],
                    ),
                    child: Text(category['name']),
                  );
                }).toList(),
                onChanged: (CustomCategory? value) {
                  setState(() {
                    selectedCategory = value;
                  });
                },
              ),
              const SizedBox(height: 4),

              //
              ElevatedButton(
                  onPressed: () async {
                    // todo: Insert the nick of the user instead of email
                    Future<String> userNicknameObject = linkSuggestionToNickname(userSessionController);
                    String userNickname = await userNicknameObject;

                    // todo: user session is passed as the person suggesting
                    newSuggestion = Suggestion(
                      nickname: userNickname,
                      authorName: _authorNameController.text,
                      bookTitle: _bookTitleController.text,
                      opinion: _bookOpinionController.text,
                      categoryId: selectedCategory?.id ?? 1,
                    );

                    print([
                      newSuggestion?.nickname,
                      newSuggestion?.authorName,
                      newSuggestion?.bookTitle,
                      newSuggestion?.opinion,
                      newSuggestion?.categoryId
                    ]);

                    await _db.insertSuggestion(newSuggestion!);
                    // final id = await _db.insertSuggestion(newSuggestion!);
                    // final savedEntry = await _db.queryById(id, 'suggestions');
                    // print("-----o $savedEntry");
                    final newEntry = await _db.getSuggestions();
                    print("===== ${newEntry.length} =====");

                    cleanUpFormData();

                    setState(() {
                      selectedCategory = null;
                    });

                    _message.informUser(
                        'Sugestão registrada! Obrigado!', context);
                    // todo: Outcome url
                    _router.redirect('user-panel', context);
                  },
                  child: const Text('sugerir')),
            ])));
  }

  void cleanUpFormData() {
    _formKey.currentState?.reset();

    _authorNameController.clear();
    _bookTitleController.clear();
    _bookOpinionController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: returnAppBar(const Color.fromARGB(255, 66, 22, 55), Colors.amber),
      body: Center(
          child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration:
                  const BoxDecoration(color: Color.fromARGB(255, 88, 33, 66)),
              child: SingleChildScrollView(
                child: returnSuggestionForm(),
              ))),
    );
  }
}
