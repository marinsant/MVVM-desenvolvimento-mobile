import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/transaction_model.dart';

class LocalDatabaseService {
  static Database? _database;

  // Garante a instância única do banco de dados (Singleton)
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  // Inicializa o arquivo do banco SQLite local
  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'financial.db');
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
      },
    );
  }

  // Insere ou substitui uma transação no banco local usando o mapa correto
  Future<void> insertTransaction(TransactionModel transaction) async {
    final db = await database;
    await db.insert(
      'transactions',
      transaction.toSQLiteMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Busca e retorna todas as transações convertidas explicitamente para TransactionModel
  Future<List<TransactionModel>> getTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('transactions');
    
    // Correção do erro de List<dynamic>: Mapeamento explícito e tipado
    return List<TransactionModel>.from(
      maps.map((map) => TransactionModel.fromSQLiteMap(map)),
    );
  }

  // Remove um registro usando o ID em formato String
  Future<void> deleteTransaction(String id) async {
    final db = await database;
    await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Atualiza o status de sincronização com a nuvem (0 = Pendente, 1 = Sincronizado)
  Future<void> updateSyncStatus(String id, int isSynced) async {
    final db = await database;
    await db.update(
      'transactions',
      {'isSynced': isSynced},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}