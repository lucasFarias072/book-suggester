import 'package:flutter/material.dart';

// Util
import 'package:book_suggester/utils/message.dart';
import 'package:book_suggester/utils/router.dart';

// Db manager
import 'package:book_suggester/services/sqflite.dart';

// Controllers
import 'package:book_suggester/controllers/user_session.dart';
import 'package:provider/provider.dart';

class SignInView extends StatefulWidget {
  const SignInView({super.key});

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  // Db manager
  final _db = DatabaseHelper();

  // Instances
  final _routerController = RouterWidget();

  // Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Utils
  final _message = MessageWidget();

  // Form
  final _formKey = GlobalKey<FormState>();

  void cleanUpFormData() {
    _formKey.currentState?.reset();
    _emailController.clear();
    _passwordController.clear();
  }

  Widget returnHeader() {
    return const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      //
      Text("Login", style: TextStyle(color: Colors.white, fontSize: 33)),
      //
      Text("preencha os campos do formulário",
          style: TextStyle(
              color: Color.fromARGB(255, 128, 200, 255), fontSize: 12))
    ]);
  }

  Widget returnBody(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // todo: Field for email
            TextFormField(
                style: const TextStyle(color: Color.fromARGB(255, 200, 200, 0)),
                decoration: const InputDecoration(
                  label: Text('E-mail'),
                  labelStyle:
                      TextStyle(color: Color.fromARGB(255, 200, 200, 0)),
                  prefixIcon: Icon(Icons.alternate_email,
                      color: Color.fromARGB(255, 200, 200, 0)),
                ),
                controller: _emailController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'campo obrigatório';
                  } else {
                    return null;
                  }
                }),
            const SizedBox(height: 10),

            // todo: Field for password
            TextFormField(
                obscureText: true,
                style: const TextStyle(color: Color.fromARGB(255, 200, 200, 0)),
                decoration: const InputDecoration(
                  label: Text('Senha'),
                  labelStyle:
                      TextStyle(color: Color.fromARGB(255, 200, 200, 0)),
                  prefixIcon: Icon(Icons.fingerprint,
                      color: Color.fromARGB(255, 200, 200, 0)),
                ),
                controller: _passwordController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'campo obrigatório';
                  } else {
                    return null;
                  }
                }),
            const SizedBox(height: 10),

            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero)),

                // todo
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    Future<bool> isUserCorrect = _db.isUserCorrectRestrict(
                        _emailController.text, _passwordController.text);

                    bool isUserCorrectReport = await isUserCorrect;

                    if (!isUserCorrectReport) {
                      _message.informUser(
                          'Seu email ou senha estão incorretos!', context);
                    }
                    // todo: User's credentials are correct: login
                    else {
                      context.read<UserSessionController>().changeLoginState(
                          loginToken:
                              !context.read<UserSessionController>().login);

                      context.read<UserSessionController>().toggleUserInSession(
                          userToken: _emailController.text);

                      _message.informUser(
                          'Boas vindas, ${_emailController.text}! Vamos começar.',
                          context);
                      _routerController.redirect('user-panel', context);
                    }
                  }
                  // Invalid form
                  else {
                    _message.informUser(
                        'Há campos incorretos ou não preenchidos!', context);
                  }
                },
                child: Text("entrar".toUpperCase()))
          ],
        ));
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
                    //
                    const SizedBox(height: 50),
                    //
                    returnHeader(),
                    //
                    const SizedBox(height: 25),
                    //
                    returnBody(context),
                  ]),
            )));
  }
}
