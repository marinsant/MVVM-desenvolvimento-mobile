import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/transaction_model.dart';
import '../models/user_model.dart';

class DbHelper {
  static final DbHelper instance = DbHelper._init();
  static Database? _database;
  
  // Lista em memória apenas para o Codespaces Web não quebrar
  final List<Map<String, dynamic>> _webTransactions = [];
  final List<Map<String, dynamic>> _webUsers = [];

  DbHelper._init();

  Future<Database?> get database async {
    if (kIsWeb) return null; // Se for web, ignora o SQLite nativo
    if (_database != null) return _database;
    _database = await _initDB('finance.db');
    return _database;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        value REAL NOT NULL,
        date TEXT NOT NULL,
        type TEXT NOT NULL
      )
    ''');
  }

  // --- OPERAÇÕES DE USUÁRIO (CRUD / AUTH) ---
  Future<int> registerUser(UserModel user) async {
    if (kIsWeb) {
      final map = user.toMap();
      map['id'] = _webUsers.length + 1;
      _webUsers.add(map);
      return map['id'];
    }
    final db = await instance.database;
    return await db!.insert('users', user.toMap());
  }

  Future<UserModel?> loginUser(String email, String password) async {
    if (kIsWeb) {
      try {
        final res = _webUsers.firstWhere((u) => u['email'] == email && u['password'] == password);
        return UserModel.fromMap(res);
      } catch (_) { return null; }
    }
    final db = await instance.database;
    final maps = await db!.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    if (maps.isNotEmpty) return UserModel.fromMap(maps.first);
    return null;
  }

  // --- OPERAÇÕES DE TRANSAÇÕES (CRUD) ---
  Future<int> insertTransaction(TransactionModel tx) async {
    if (kIsWeb) {
      final map = tx.toMap();
      map['id'] = _webTransactions.length + 1;
      _webTransactions.add(map);
      return map['id'];
    }
    final db = await instance.database;
    return await db!.insert('transactions', tx.toMap());
  }

  Future<List<TransactionModel>> getAllTransactions() async {
    if (kIsWeb) {
      return _webTransactions.map((json) => TransactionModel.fromMap(json)).toList();
    }
    final db = await instance.database;
    final result = await db!.query('transactions');
    return result.map((json) => TransactionModel.fromMap(json)).toList();
  }

  Future<int> deleteTransaction(int id) async {
    if (kIsWeb) {
      _webTransactions.removeWhere((tx) => tx['id'] == id);
      return 1;
    }
    final db = await instance.database;
    return await db!.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }
}