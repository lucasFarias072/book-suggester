import 'package:flutter/material.dart';

// Controllers
import 'package:book_suggester/controllers/user_session.dart';

// Utils
import 'package:book_suggester/utils/router.dart';
import 'package:book_suggester/utils/message.dart';

// Notifier
import 'package:provider/provider.dart';

class UserPanelView extends StatefulWidget {
  const UserPanelView({super.key});

  @override
  State<UserPanelView> createState() => _UserPanelViewState();
}

class _UserPanelViewState extends State<UserPanelView> {
  final _message = MessageWidget();
  final _router = RouterWidget();
  String? sessionUser;

  Widget returnIconType(int val, Color ink) {
    if (val == 1) {
      return Icon(
        Icons.recommend_outlined,
        color: ink,
      );
    } else if (val == 2) {
      return Icon(
        Icons.book,
        color: ink,
      );
    } else if (val == 3) {
      return Icon(
        Icons.update_sharp,
        color: ink,
      );
    } else if (val == 4) {
      return Icon(
        Icons.map_sharp,
        color: ink,
      );
    }
    return const Icon(Icons.abc);
  }

  Widget returnTileObject(
      int val, String linkTxt, String urlTxt, Color ink, BuildContext context) {
    return ListTile(
        leading: returnIconType(val, ink),
        title: Text(linkTxt, style: TextStyle(color: ink)),
        onTap: () {
          Navigator.pushNamed(context, urlTxt);
        });
  }

  PreferredSizeWidget returnAppBar(UserSessionController ctrll) {
    return AppBar(
      backgroundColor: const Color.fromARGB(255, 99, 22, 66),
      title: const Text("Sessão do usuário",
          style: TextStyle(color: Color.fromARGB(255, 200, 200, 100), fontSize: 18)),
      actions: [
        IconButton(
          style: IconButton.styleFrom(backgroundColor: Colors.white),
          icon: const Icon(
            Icons.logout,
            color: Color.fromARGB(255, 33, 66, 99),
          ),
          onPressed: () {
            _message.informUser(
                'Efetuando sua saída, ${ctrll.userInSession}! Até uma próxima!',
                context);
            ctrll.logoutUserInSession();
            if (ctrll.userInSession == 'Anônimo') {
              _router.redirect('/', context);
            }
          },
        ),
      ],
    );
  }

  Widget returnBody() {
    return Container(
        decoration: const BoxDecoration(color: Color.fromARGB(255, 66, 22, 44)),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Icon(Icons.bookmark_add_sharp,
                    color: Color.fromARGB(255, 88, 44, 66), size: 200),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("1. Acesse o menu no topo esquerdo da tela",
                  style: TextStyle(fontSize: 15, color: Colors.white)),
              Text("2. Faça a sua sugestão",
                  style: TextStyle(fontSize: 15, color: Colors.white)),
              Text("3. Acompanhe as sugestões feitas",
                  style: TextStyle(fontSize: 15, color: Colors.white))
                ],
              )
            ],
          ),
        ));
  }

  Widget returnUserInfo(UserSessionController ctrll) {
    return ListTile(
      leading: const Icon(Icons.person, color: Colors.amber),
      title: Text(ctrll.userInSession,
          style: const TextStyle(color: Color.fromARGB(255, 200, 200, 0))),
    );
  }

  Widget returnSideMenu(UserSessionController ctrll) {
    Color stdColorForTiles = const Color.fromARGB(255, 170, 220, 255);
    return Drawer(
        backgroundColor: const Color.fromARGB(255, 66, 33, 44),
        child: ListView(children: [
          returnUserInfo(ctrll),
          returnTileObject(
              1, "sugerir livro", "add-book", stdColorForTiles, context),
          returnTileObject(
              2, "sugestões feitas", "see-books", stdColorForTiles, context),
          returnTileObject(
              4, "locais próximos", "find-places-nearby", stdColorForTiles, context)
        ]));
  }

  @override
  Widget build(BuildContext context) {
    // todo: Notifier instance
    final userSessionController = Provider.of<UserSessionController>(context);

    return Scaffold(
      appBar: returnAppBar(userSessionController),
      body: returnBody(),
      drawer: returnSideMenu(userSessionController),
    );
  }
}
