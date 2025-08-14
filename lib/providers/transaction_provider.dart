import 'package:flutter/material.dart';
import '../models/finance_transaction.dart';
import '../utils/storage_helper.dart';

class TransactionProvider with ChangeNotifier {
  List<FinanceTransaction> _transactions = [];
  List<FinanceTransaction> _filteredTransactions = [];
  bool _isLoading = false;
  bool? _filterByType; // null = semua, true = pemasukan, false = pengeluaran
  String _searchQuery = '';

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

  // Getter untuk income dan expense yang difilter
  double get filteredIncome {
    if (_filterByType == false) return 0.0; // Jika filter pengeluaran
    List<FinanceTransaction> incomeTransactions = _transactions
        .where((tx) => tx.isIncome)
        .where((tx) => _matchesSearch(tx))
        .toList();
    return incomeTransactions.fold(0.0, (sum, tx) => sum + tx.amount);
  }
  
  double get filteredExpense {
    if (_filterByType == true) return 0.0; // Jika filter pemasukan
    List<FinanceTransaction> expenseTransactions = _transactions
        .where((tx) => !tx.isIncome)
        .where((tx) => _matchesSearch(tx))
        .toList();
    return expenseTransactions.fold(0.0, (sum, tx) => sum + tx.amount);
  }
  
  double get filteredBalance => filteredIncome - filteredExpense;

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
        // Terapkan filter pencarian juga
        if (_matchesSearch(transaction)) {
          if (categoryTotals.containsKey(transaction.category)) {
            categoryTotals[transaction.category] =
                categoryTotals[transaction.category]! + transaction.amount;
          } else {
            categoryTotals[transaction.category] = transaction.amount;
          }
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
      _applyFilters(); // Terapkan filter setelah fetch
    } catch (e) {
      print('Error fetching transactions: $e');
      _transactions = [];
      _filteredTransactions = [];
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
      _applyFilters(); // Terapkan filter setelah tambah
      notifyListeners();
    } catch (e) {
      print('Error adding transaction: $e');
      rethrow;
    }
  }

  // 🔧 Fungsi baru untuk edit transaksi
  Future<void> updateTransaction(FinanceTransaction updatedTransaction) async {
    try {
      final index = _transactions.indexWhere((tx) => tx.id == updatedTransaction.id);
      if (index != -1) {
        _transactions[index] = updatedTransaction;
        await StorageHelper.saveTransactions(_transactions);
        _applyFilters(); // Terapkan filter setelah update
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
      _applyFilters(); // Terapkan filter setelah hapus
      notifyListeners();
    } catch (e) {
      print('Error deleting transaction: $e');
      rethrow;
    }
  }

  // 🔧 Fungsi filter berdasarkan jenis
  void setFilterByType(bool? type) {
    _filterByType = type;
    _applyFilters();
    notifyListeners();
  }

  // 🔧 Fungsi pencarian
  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
    notifyListeners();
  }

  // 🔧 Fungsi untuk menghapus semua filter
  void clearFilters() {
    _filterByType = null;
    _searchQuery = '';
    _applyFilters();
    notifyListeners();
  }

  // 🔧 Fungsi internal untuk menerapkan filter
  void _applyFilters() {
    List<FinanceTransaction> filtered = List.from(_transactions);
    
    // Filter berdasarkan jenis
    if (_filterByType != null) {
      filtered = filtered.where((tx) => tx.isIncome == _filterByType).toList();
    }
    
    // Filter berdasarkan pencarian
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((tx) => _matchesSearch(tx)).toList();
    }
    
    // Urutkan berdasarkan tanggal (terbaru dulu)
    filtered.sort((a, b) => b.date.compareTo(a.date));
    
    _filteredTransactions = filtered;
  }

  // 🔧 Fungsi untuk mengecek apakah transaksi cocok dengan pencarian
  bool _matchesSearch(FinanceTransaction transaction) {
    if (_searchQuery.isEmpty) return true;
    return transaction.title.toLowerCase().contains(_searchQuery) ||
           transaction.category.toLowerCase().contains(_searchQuery);
  }
}