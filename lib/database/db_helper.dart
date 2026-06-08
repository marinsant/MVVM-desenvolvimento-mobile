import 'package:flutter/foundation.dart'; // Importação necessária para o kIsWeb
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/transaction_model.dart';

class DbHelper {
  static final DbHelper instance = DbHelper._init();
  static Database? _db;

  // Banco de dados temporário em memória para o FLUTTER WEB não quebrar
  final List<Map<String, dynamic>> _webUsersMock = [];
  final List<Map<String, dynamic>> _webTransactionsMock = [];

  DbHelper._init();

  Future<Database?> get db async {
    if (kIsWeb) return null; // Se for Web, ignora o SQLite
    if (_db != null) return _db;
    _db = await _initDb();
    return _db;
  }

  Future<Database?> _initDb() async {
    if (kIsWeb) return null;
    try {
      String databasesPath = await getDatabasesPath();
      String path = join(databasesPath, "financial.db");

      return await openDatabase(
        path,
        version: 1,
        onCreate: (Database db, int version) async {
          await db.execute('''
            CREATE TABLE transactions (
              id TEXT PRIMARY KEY,
              title TEXT,
              amount REAL,
              date TEXT,
              category TEXT,
              isSynced INTEGER DEFAULT 0
            )
          ''');

          await db.execute('''
            CREATE TABLE users (
              id TEXT PRIMARY KEY,
              name TEXT,
              email TEXT UNIQUE,
              password TEXT
            )
          ''');
        },
      );
    } catch (e) {
      debugPrint("Erro ao inicializar banco: $e");
      return null;
    }
  }

  // --- MÉTODOS DE AUTENTICAÇÃO (HÍBRIDO CELULAR/WEB) ---

  Future<bool> checkEmailExists(String email) async {
    if (kIsWeb) {
      // Busca na memória do navegador
      return _webUsersMock.any((user) => user['email'] == email);
    }

    final database = await db;
    if (database == null) return false;

    final List<Map<String, dynamic>> maps = await database.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return maps.isNotEmpty;
  }

  Future<int> registerUser(Map<String, dynamic> user) async {
    if (kIsWeb) {
      // Salva na memória interna da sessão Web
      _webUsersMock.add(user);
      return 1; // Retorna sucesso
    }

    final database = await db;
    if (database == null) return 0;

    return await database.insert(
      'users',
      user,
      conflictAlgorithm: ConflictAlgorithm.abort, 
    );
  }

  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    if (kIsWeb) {
      // Valida direto na memória do navegador
      try {
        return _webUsersMock.firstWhere(
          (user) => user['email'] == email && user['password'] == password,
        );
      } catch (_) {
        return null;
      }
    }

    final database = await db;
    if (database == null) return null;

    final List<Map<String, dynamic>> maps = await database.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (maps.isNotEmpty) return maps.first;
    return null;
  }

  // --- MÉTODOS DE TRANSAÇÃO (HÍBRIDO CELULAR/WEB) ---

  Future<int> insertTransaction(TransactionModel tx) async {
    if (kIsWeb) {
      _webTransactionsMock.removeWhere((t) => t['id'] == tx.id);
      _webTransactionsMock.add(tx.toMap());
      return 1;
    }

    final database = await db;
    if (database == null) return 0;
    
    return await database.insert(
      'transactions',
      tx.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<TransactionModel>> getTransactions() async {
    if (kIsWeb) {
      return List<TransactionModel>.from(
        _webTransactionsMock.map((json) => TransactionModel.fromMap(json)),
      );
    }

    final database = await db;
    if (database == null) return [];

    final List<Map<String, dynamic>> result = await database.query('transactions');
    return List<TransactionModel>.from(
      result.map((json) => TransactionModel.fromMap(json)),
    );
  }

  Future<int> deleteTransaction(String id) async {
    if (kIsWeb) {
      _webTransactionsMock.removeWhere((t) => t['id'] == id);
      return 1;
    }

    final database = await db;
    if (database == null) return 0;

    return await database.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateSyncStatus(String id, int isSynced) async {
    if (kIsWeb) return 1;

    final database = await db;
    if (database == null) return 0;

    return await database.update(
      'transactions',
      {'isSynced': isSynced},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}


typedef DBHelper = DbHelper;