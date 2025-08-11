import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/finance_transaction.dart';

class StorageHelper {
  static const String _transactionsKey = 'transactions';

  static Future<void> saveTransactions(List<FinanceTransaction> transactions) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> jsonList = 
        transactions.map((tx) => tx.toMap()).toList();
    final String jsonString = jsonEncode(jsonList);
    await prefs.setString(_transactionsKey, jsonString);
  }

  static Future<List<FinanceTransaction>> getTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_transactionsKey);
    
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((item) {
        final map = Map<String, dynamic>.from(item);
        return FinanceTransaction.fromMap(map);
      }).toList();
    } catch (e) {
      print('Error parsing transactions: $e');
      return [];
    }
  }
}