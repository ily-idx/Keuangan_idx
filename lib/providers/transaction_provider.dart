import 'package:flutter/material.dart';
import '../models/finance_transaction.dart';
import '../utils/storage_helper.dart';

class TransactionProvider with ChangeNotifier {
  List<FinanceTransaction> _transactions = [];
  bool _isLoading = false;

  List<FinanceTransaction> get transactions => _transactions;
  bool get isLoading => _isLoading;

  double get totalIncome => _transactions
      .where((tx) => tx.isIncome)
      .fold(0.0, (sum, tx) => sum + tx.amount);

  double get totalExpense => _transactions
      .where((tx) => !tx.isIncome)
      .fold(0.0, (sum, tx) => sum + tx.amount);

  double get balance => totalIncome - totalExpense;

  // Fungsi baru untuk mendapatkan kategori unik
  List<String> getCategories(bool isIncome) {
    final categories = _transactions
        .where((tx) => tx.isIncome == isIncome)
        .map((tx) => tx.category)
        .toSet()
        .toList();
    categories.sort();
    return categories;
  }

  // Fungsi untuk mendapatkan total berdasarkan kategori
  Map<String, double> getCategoryTotals(bool isIncome) {
    final Map<String, double> categoryTotals = {};

    for (var transaction in _transactions) {
      if (transaction.isIncome == isIncome) {
        if (categoryTotals.containsKey(transaction.category)) {
          categoryTotals[transaction.category] =
              categoryTotals[transaction.category]! + transaction.amount;
        } else {
          categoryTotals[transaction.category] = transaction.amount;
        }
      }
    }

    return categoryTotals;
  }

  Future<void> fetchTransactions() async {
    _isLoading = true;
    notifyListeners();

    try {
      _transactions = await StorageHelper.getTransactions();
    } catch (e) {
      print('Error fetching transactions: $e');
      _transactions = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTransaction(FinanceTransaction transaction) async {
    try {
      final newTransaction = FinanceTransaction(
        id: transaction.id ?? FinanceTransaction.generateId(),
        title: transaction.title,
        amount: transaction.amount,
        date: transaction.date,
        isIncome: transaction.isIncome,
        category: transaction.category,
      );

      _transactions.insert(0, newTransaction);
      await StorageHelper.saveTransactions(_transactions);
      notifyListeners();
    } catch (e) {
      print('Error adding transaction: $e');
      rethrow;
    }
  }

  // 🔧 Fungsi baru untuk edit transaksi
  Future<void> updateTransaction(FinanceTransaction updatedTransaction) async {
    try {
      final index =
          _transactions.indexWhere((tx) => tx.id == updatedTransaction.id);
      if (index != -1) {
        _transactions[index] = updatedTransaction;
        await StorageHelper.saveTransactions(_transactions);
        notifyListeners();
      }
    } catch (e) {
      print('Error updating transaction: $e');
      rethrow;
    }
  }

  Future<void> deleteTransaction(int id) async {
    try {
      _transactions.removeWhere((tx) => tx.id == id);
      await StorageHelper.saveTransactions(_transactions);
      notifyListeners();
    } catch (e) {
      print('Error deleting transaction: $e');
      rethrow;
    }
  }
}
