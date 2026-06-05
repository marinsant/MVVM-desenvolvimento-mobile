import '../models/transaction_model.dart';
import '../database/db_helper.dart'; 

class FinancialRepository {
  // CORREÇÃO: Usando a instância Singleton correta do DbHelper
  final DbHelper _localDb = DbHelper.instance;

  Future<List<TransactionModel>> getTransactions() async {
    return await _localDb.getTransactions();
  }

  Future<void> saveTransaction(TransactionModel tx) async {
    await _localDb.insertTransaction(tx);
    try {
      if (tx.id != null) {
        await _localDb.updateSyncStatus(tx.id!, 1);
      }
    } catch (_) {}
  }

  Future<void> deleteTransaction(String id) async {
    await _localDb.deleteTransaction(id);
  }

  Future<void> syncLocalTransactions(TransactionModel localTx) async {
    try {
      if (localTx.id != null) {
        await _localDb.updateSyncStatus(localTx.id!, 1);
      }
    } catch (_) {}
  }
}