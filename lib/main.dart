import 'package:book_suggester/models/suggestion.dart';
import 'package:book_suggester/models/user.dart';
import 'package:book_suggester/views/maps.dart';
import 'package:flutter/material.dart';

import 'package:book_suggester/controllers/controllers.dart';

import 'package:book_suggester/views/sign_in.dart';
import 'package:book_suggester/views/user_panel.dart';
import 'package:book_suggester/views/add_book.dart';
import 'package:book_suggester/views/see_books.dart';

import 'package:provider/provider.dart';

import 'package:book_suggester/controllers/user_session.dart';

import 'package:book_suggester/services/sqflite.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  // runApp(const MyApp());

  await dotenv.load(fileName: ".env");
  String apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
  print(apiKey);
  
  runApp(ChangeNotifierProvider(
    create: (_) => UserSessionController(),
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),

        // --------------------------- Routes setup ---------------------------
        initialRoute: "/",
        routes: {
          // Index view is also the sign-up view
          "/": (context) => const IndexView(),
          "sign-in": (context) => const SignInView(),
          "user-panel": (context) => const UserPanelView(),
          "add-book": (context) => const AddBookView(),
          "see-books": (context) => const SeeBooksView(),
          "find-places-nearby": (context) => const GetLocationView(),
        }
        // ---------------------------------------------------------------------

        );
  }
}
