import 'package:flutter/material.dart';
import '../models/finance_transaction.dart';
import '../utils/storage_helper.dart';
import '../utils/logger.dart';

class TransactionProvider with ChangeNotifier {
  List<FinanceTransaction> _transactions = [];
  List<FinanceTransaction> _filteredTransactions = [];
  bool _isLoading = false;
  bool? _filterByType;
  String _searchQuery = '';

  // Getters
  List<FinanceTransaction> get transactions => _filteredTransactions;
  bool get isLoading => _isLoading;
  bool? get filterByType => _filterByType;
  String get searchQuery => _searchQuery;

  double get totalIncome => _transactions
      .where((tx) => tx.isIncome)
      .fold(0.0, (sum, tx) => sum + tx.amount);

  double get totalExpense => _transactions
      .where((tx) => !tx.isIncome)
      .fold(0.0, (sum, tx) => sum + tx.amount);

  double get balance => totalIncome - totalExpense;

  double get filteredIncome {
    if (_filterByType == false) return 0.0;
    return _transactions
        .where((tx) => tx.isIncome)
        .where((tx) => _matchesSearch(tx))
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get filteredExpense {
    if (_filterByType == true) return 0.0;
    return _transactions
        .where((tx) => !tx.isIncome)
        .where((tx) => _matchesSearch(tx))
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get filteredBalance => filteredIncome - filteredExpense;

  Future<void> fetchTransactions() async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      _transactions = await StorageHelper.getTransactions();
      _applyFilters();
      AppLogger.info('Berhasil memuat transaksi: ${_transactions.length}');
    } catch (e, stackTrace) {
      AppLogger.error('Gagal memuat transaksi', e, stackTrace);
      _transactions = [];
      _filteredTransactions = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTransaction(FinanceTransaction transaction) async {
    try {
      final newTransaction = transaction.copyWith(
        id: transaction.id ?? FinanceTransaction.generateId(),
      );

      _transactions.insert(0, newTransaction);
      await StorageHelper.saveTransactions(_transactions);
      _applyFilters();
      notifyListeners();

      AppLogger.info('Berhasil menambahkan transaksi: ${newTransaction.title}');
    } catch (e, stackTrace) {
      AppLogger.error('Gagal menambahkan transaksi', e, stackTrace);
      rethrow;
    }
  }

  Future<void> updateTransaction(FinanceTransaction updatedTransaction) async {
    try {
      final index =
          _transactions.indexWhere((tx) => tx.id == updatedTransaction.id);
      if (index != -1) {
        _transactions[index] = updatedTransaction;
        await StorageHelper.saveTransactions(_transactions);
        _applyFilters();
        notifyListeners();
        AppLogger.info(
            'Berhasil mengupdate transaksi: ${updatedTransaction.title}');
      }
    } catch (e, stackTrace) {
      AppLogger.error('Gagal mengupdate transaksi', e, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteTransaction(int id) async {
    try {
      final transaction = _transactions.firstWhere((tx) => tx.id == id);
      _transactions.removeWhere((tx) => tx.id == id);
      await StorageHelper.saveTransactions(_transactions);
      _applyFilters();
      notifyListeners();
      AppLogger.info('Berhasil menghapus transaksi: ${transaction.title}');
    } catch (e, stackTrace) {
      AppLogger.error('Gagal menghapus transaksi', e, stackTrace);
      rethrow;
    }
  }

  void setFilterByType(bool? type) {
    _filterByType = type;
    _applyFilters();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
    notifyListeners();
  }

  void clearFilters() {
    _filterByType = null;
    _searchQuery = '';
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    List<FinanceTransaction> filtered = List.from(_transactions);

    if (_filterByType != null) {
      filtered = filtered.where((tx) => tx.isIncome == _filterByType).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((tx) => _matchesSearch(tx)).toList();
    }

    filtered.sort((a, b) => b.date.compareTo(a.date));
    _filteredTransactions = filtered;
  }

  bool _matchesSearch(FinanceTransaction transaction) {
    if (_searchQuery.isEmpty) return true;
    return transaction.title.toLowerCase().contains(_searchQuery) ||
        transaction.category.toLowerCase().contains(_searchQuery);
  }

  // Method utilitas
  List<String> getCategories(bool isIncome) {
    return _transactions
        .where((tx) => tx.isIncome == isIncome)
        .map((tx) => tx.category)
        .toSet()
        .toList()
      ..sort();
  }

  Map<String, double> getCategoryTotals(bool isIncome) {
    final Map<String, double> categoryTotals = {};

    for (final transaction in _transactions) {
      if (transaction.isIncome == isIncome && _matchesSearch(transaction)) {
        categoryTotals.update(
          transaction.category,
          (value) => value + transaction.amount,
          ifAbsent: () => transaction.amount,
        );
      }
    }

    return categoryTotals;
  }
}
