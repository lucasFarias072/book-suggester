// Native
import 'package:flutter/material.dart';

// Models
import 'package:book_suggester/models/user.dart';

// Utils
import 'package:book_suggester/utils/message.dart';
import 'package:book_suggester/utils/paint.dart';

// Db manager
import 'package:book_suggester/services/sqflite.dart';

class IndexView extends StatefulWidget {
  const IndexView({super.key});

  @override
  State<IndexView> createState() => _IndexViewState();
}

class _IndexViewState extends State<IndexView> {
  // Db manager
  final _db = DatabaseHelper();

  // Instances
  final _message = MessageWidget();

  // Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nicknameController = TextEditingController();

  // Form
  final _formKey = GlobalKey<FormState>();

  // Utils
  final ink = Paint();

  void cleanUpFormData() {
    _formKey.currentState?.reset();
    _nicknameController.clear();
    _emailController.clear();
    _passwordController.clear();
  }

  Widget returnHeader() {
    return const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      SizedBox(height: 50),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.book_sharp,
              color: Color.fromARGB(255, 200, 0, 99), size: 50),
          SizedBox(width: 10),
          Text('Sugestor de Livros',
              style: TextStyle(color: Colors.white, fontSize: 25)),
          SizedBox(width: 10),
          Icon(Icons.book_sharp,
              color: Color.fromARGB(255, 200, 0, 99), size: 50),
        ],
      ),
      // SizedBox(height: 20),
      // Text('Boas vindas',
      //     style: TextStyle(
      //         color: Color.fromARGB(255, 170, 220, 255), fontSize: 17)),
      // Text('faça seu cadastro ou login, abaixo',
      //     style: TextStyle(
      //         color: Color.fromARGB(255, 170, 220, 255), fontSize: 12)),
    ]);
  }

  Widget returnForm() {
    return Column(children: [
      Text("Criar conta",
          style:
              TextStyle(color: ink.getInk('index_page_form'), fontSize: 27)),
      Form(
          key: _formKey,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            // Nickname Field
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: TextFormField(
                  style:
                      TextStyle(color: ink.getInk('index_page_form')),
                  decoration: InputDecoration(
                    label: const Text('Apelido'),
                    labelStyle:
                        TextStyle(color: ink.getInk('index_page_form')),
                    prefixIcon: Icon(Icons.person,
                        color: ink.getInk('index_page_form')),
                  ),
                  controller: _nicknameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'campo obrigatório';
                    } else {
                      return null;
                    }
                  }),
            ),
            const SizedBox(height: 10),

            // Email Field
            Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: TextFormField(
                    style: TextStyle(
                        color: ink.getInk('index_page_form')),
                    decoration: InputDecoration(
                      label: const Text('E-mail'),
                      labelStyle:
                          TextStyle(color: ink.getInk('index_page_form')),
                      prefixIcon: Icon(Icons.alternate_email,
                          color: ink.getInk('index_page_form')),
                    ),
                    controller: _emailController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'campo obrigatório';
                      } else {
                        return null;
                      }
                    })),
            const SizedBox(height: 10),

            // Password Field
            Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: TextFormField(
                    style: TextStyle(
                        color: ink.getInk('index_page_form')),
                    obscureText: true,
                    decoration: InputDecoration(
                      label: const Text('Senha'),
                      labelStyle:
                          TextStyle(color: ink.getInk('index_page_form')),
                      prefixIcon: Icon(Icons.fingerprint,
                          color: ink.getInk('index_page_form')),
                    ),
                    controller: _passwordController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'campo obrigatório';
                      } else {
                        return null;
                      }
                    })),
            const SizedBox(height: 10),

            // Post button
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero),
                    backgroundColor: const Color.fromARGB(255, 199, 66, 99)),
                onPressed: () async {
                  // todo: If there are empty fields
                  if (!_formKey.currentState!.validate()) {
                    _message.informUser(
                        'Há campos incorretos ou não preenchidos!', context);
                    return;
                  }

                  // Assemble new user
                  UserModel newUser = UserModel(
                    nickname: _nicknameController.text,
                    email: _emailController.text,
                    password: _passwordController.text,
                  );

                  // Action 1: No user's credential was found (add it)
                  Future<bool> isUserFound = _db.isUserValid(newUser.email);

                  bool isUserFoundReport = await isUserFound;

                  if (!isUserFoundReport) {
                    await _db.insertUser(newUser);

                    _message.informUser(
                        'Você foi cadastrado, ${newUser.nickname}, agora faça o login!',
                        context);

                    cleanUpFormData();
                  }

                  // Action 2: User was found, recommend login button
                  else {
                    _message.informUser(
                        'Usuário já existe, use o botão de login, ao invés',
                        context);
                  }
                },
                child: Text(
                  "registrar".toUpperCase(),
                  style: const TextStyle(
                      color: Color.fromARGB(255, 222, 222, 222)),
                ))
          ]))
    ]);
  }

  Widget returnFooter() {
    return Column(children: [
      const Text("Já possui uma conta?",
          style: TextStyle(color: Colors.white, fontSize: 15)),
      const SizedBox(width: 10),
      ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 33, 66, 99),
            shape:
                const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          ),
          onPressed: () => {Navigator.pushNamed(context, "sign-in")},
          child: Text("entrar".toUpperCase(),
              style: const TextStyle(color: Colors.white)))
    ]);
  }

  @override
  void initState() {
    super.initState();
    // todo: Populate user's session
    // Future<int> userSessionLength = _db.getCount('user_sessions');
    // int userSessionLengthReport = await userSessionLength;
    // Future<List<UserSession>> usersInSession =
    //     _db.getUserSessions();
    // print([userSessionLengthReport, usersInSession]);
    // if (userSessionLengthReport == 0) {
    //   _db.insertUserSession(_userSession);
    // }
  }

  @override
  Widget build(BuildContext context) {
    // Screen related data
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
        body: Container(
            color: const Color.fromARGB(255, 99, 33, 66),
            height: screenHeight,
            width: screenWidth,
            padding: const EdgeInsets.all(10),
            child: SingleChildScrollView(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                  returnHeader(),
                  const SizedBox(height: 30),
                  returnForm(),
                  const SizedBox(height: 50),
                  returnFooter()
                ]))));
  }
}
