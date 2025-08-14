import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/finance_transaction.dart';
import '../utils/logger.dart';

class StorageHelper {
  static const String _transactionsKey = 'transactions';

  static Future<void> saveTransactions(
      List<FinanceTransaction> transactions) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> jsonList =
          transactions.map((tx) => tx.toMap()).toList();
      final String jsonString = jsonEncode(jsonList);
      await prefs.setString(_transactionsKey, jsonString);
      AppLogger.info('Berhasil menyimpan ${transactions.length} transaksi');
    } catch (e, stackTrace) {
      AppLogger.error('Gagal menyimpan transaksi', e, stackTrace);
      rethrow;
    }
  }

  static Future<List<FinanceTransaction>> getTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_transactionsKey);

      if (jsonString == null || jsonString.isEmpty) {
        AppLogger.info('Tidak ada data transaksi ditemukan');
        return [];
      }

      final List<dynamic> jsonList = jsonDecode(jsonString);
      final transactions = jsonList.map((item) {
        final map = Map<String, dynamic>.from(item);
        return FinanceTransaction.fromMap(map);
      }).toList();

      AppLogger.info('Berhasil memuat ${transactions.length} transaksi');
      return transactions;
    } catch (e, stackTrace) {
      AppLogger.error('Gagal memuat transaksi', e, stackTrace);
      return [];
    }
  }
}
