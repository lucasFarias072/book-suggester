// Database
import 'package:sqflite/sqflite.dart';

// Path handling
import 'package:path/path.dart';

// Models
import 'package:book_suggester/models/category.dart';
import 'package:book_suggester/models/suggestion.dart';
import 'package:book_suggester/models/user.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;
  factory DatabaseHelper() => _instance;

  // --------------------------------------------------------- Operational setup

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    await checkCategoriesExistance();
    return _database!;
  }

  // Migrations
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'suggestion_database.db');

    Database db = await openDatabase(
      path,
      version: 5,
      onCreate: _onCreate,
      onUpgrade: (db, oldVersion, newVersion) async {
        // await db.execute('DROP TABLE IF EXISTS categories');
        // await db.execute('DROP TABLE IF EXISTS suggestions');
        await _onCreate(db, newVersion);
      }
    );

    return db;
  }

  // Tables setup (comment old tables before making new changes)
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');

    // "categoryId" is the foreign key here, referenced as "category_id"
    await db.execute('''
      CREATE TABLE books(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        author_id INTEGER NOT NULL,
        category_id INTEGER NOT NULL,
        FOREIGN KEY (category_id) REFERENCES categories (id)
          ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE suggestions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nickname TEXT NOT NULL,
        author_name TEXT NOT NULL,
        book_title TEXT NOT NULL,
        opinion TEXT NOT NULL,
        category_id INTEGER NOT NULL,
        FOREIGN KEY (category_id) REFERENCES categories (id)
          ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nickname TEXT NOT NULL,
        email TEXT NOT NULL,
        password TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE user_sessions(
        credential TEXT NOT NULL
      )
    ''');
  }

  Future<int> insert(String table, Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert(table, row);
  }

  Future<void> deleteDatabaseFile() async {
    String path = join(await getDatabasesPath(), 'library_database.db');
    await deleteDatabase(path);
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  // -------------------------------------------------------------------- Create
  Future<int> insertCategory(Category cat) async {
    final Database db = await database;
    return await db.insert('categories', cat.toMap());
  }

  Future<int> insertSuggestion(Suggestion suggestion) async {
    final Database db = await database;
    return await db.insert('suggestions', suggestion.toMap());
  }

  Future<int> insertUser(UserModel newUser) async {
    final Database db = await database;
    return await db.insert('users', newUser.toMap());
  }

  // ---------------------------------------------------------------------- Read
  Future<List<Category>> getCategories() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('categories');
    return List.generate(maps.length, (i) => Category.fromMap(maps[i]));
  }

  Future<List<Suggestion>> getSuggestions() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('suggestions');
    return List.generate(maps.length, (i) => Suggestion.fromMap(maps[i]));
  }

  Future<List<UserModel>> getUsers() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('users');
    return List.generate(maps.length, (i) => UserModel.fromMap(maps[i]));
  }

  // -------------------------------------------------------------------- Update
  Future<int> updateSuggestion(Suggestion suggestion) async {
    final Database db = await database;
    return await db.update(
      'suggestions',
      suggestion.toMap(),
      where: 'id = ?',
      whereArgs: [suggestion.id],
    );
  }

  // -------------------------------------------------------------------- Remove
  Future<int> deleteSuggestion(int id) async {
    final Database db = await database;
    return await db.delete(
      'suggestions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteUser(int id) async {
    final Database db = await database;
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ------------------------------------------------------------------- Queries
  Future<void> checkCategoriesExistance() async {
    final List<Map<String, dynamic>> defaultCategories = [
      {'id': 0, 'name': 'Ação'},
      {'id': 1, 'name': 'Animação'},
      {'id': 2, 'name': 'Artes Marciais'},
      {'id': 3, 'name': 'Aventura'},
      {'id': 4, 'name': 'Biografia'},
      {'id': 5, 'name': 'Catástrofe'},
      {'id': 6, 'name': 'Comédia'},
      {'id': 7, 'name': 'Crime'},
      {'id': 8, 'name': 'Cult'},
      {'id': 9, 'name': 'Documentário'},
      {'id': 10, 'name': 'Drama'},
      {'id': 11, 'name': 'Esporte'},
      {'id': 12, 'name': 'Experimental'},
      {'id': 13, 'name': 'Família'},
      {'id': 14, 'name': 'Fantasia'},
      {'id': 15, 'name': 'Ficção Científica'},
      {'id': 16, 'name': 'Guerra'},
      {'id': 17, 'name': 'Histórico'},
      {'id': 18, 'name': 'Infantil'},
      {'id': 19, 'name': 'Mistério'},
      {'id': 20, 'name': 'Musical'},
      {'id': 21, 'name': 'Noir'},
      {'id': 22, 'name': 'Policial'},
      {'id': 23, 'name': 'Política'},
      {'id': 24, 'name': 'Religioso'},
      {'id': 25, 'name': 'Road Movie'},
      {'id': 26, 'name': 'Romance'},
      {'id': 27, 'name': 'Satírico'},
      {'id': 28, 'name': 'Sobrenatural'},
      {'id': 29, 'name': 'Super-heróis'},
      {'id': 30, 'name': 'Suspense'},
      {'id': 31, 'name': 'Terror'},
      {'id': 32, 'name': 'Thriller Psicológico'},
      {'id': 33, 'name': 'Western (Faroeste)'},
      {'id': 34, 'name': 'Outro'}
    ];
    final categoriesDb = await getCategories();
    if (categoriesDb.isEmpty) {
      for (int i = 0; i < defaultCategories.length; i++) {
        Category cat = Category(name: defaultCategories[i]["name"]);
        await insertCategory(cat);
      }
    }
  }

  Future<Map<String, dynamic>> queryById(int id, String tableName) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return maps.last;
    }

    return {};
  }

  Future<Map<String, dynamic>> queryByEmail(String email, String tableName) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isNotEmpty) {
      return maps.last;
    }

    return {};
  }

  Future<bool> checkUserExists(String userNicknameInput) async {
    DatabaseHelper db = DatabaseHelper();
    List<UserModel> users = await db.getUsers();
    return users.any((user) => user.nickname == userNicknameInput);
    // final db = await openDatabase('my_database.db');
    // final result = await db.query(
    //   'users',
    //   where: 'credential = ?',
    //   whereArgs: [uid],
    // );
    // return result.isNotEmpty;
  }

  Future<int> getCount(String tableName) async {
    final db = await database; // sua instância do banco
    final result = await db.rawQuery('SELECT COUNT(*) FROM $tableName');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ----------------------------------------------------- Users' Authentication
  Future<bool> isUserCorrect(
      String email, String nickname, String password) async {
    DatabaseHelper db = DatabaseHelper();
    List<UserModel> users = await db.getUsers();
    return users.any((user) =>
        user.email == email ||
        user.nickname == nickname && user.password == password);
  }

  // Login
  Future<bool> isUserCorrectRestrict(String email, String password) async {
    DatabaseHelper db = DatabaseHelper();
    List<UserModel> users = await db.getUsers();
    return users
        .any((user) => user.email == email && user.password == password);
  }

  // Block incorrect login
  Future<bool> isUserIncorrect(
      String email, String nickname, String password) async {
    DatabaseHelper db = DatabaseHelper();
    List<UserModel> users = await db.getUsers();
    return users.any((user) =>
        user.email == email ||
        user.nickname == nickname && user.password != password);
  }

  // Add new user (in case it return false)
  Future<bool> isUserValid(String email) async {
    DatabaseHelper db = DatabaseHelper();
    List<UserModel> users = await db.getUsers();
    return users.any((user) => user.email == email);
  }
}
