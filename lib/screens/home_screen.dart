import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../providers/transaction_provider.dart';
import '../widgets/transaction_list.dart';
import '../screens/add_transaction_screen.dart';
import '../utils/export_helper.dart';
import '../widgets/search_delegate.dart';
import '../utils/logger.dart';
import '../utils/constants.dart'; // Tambahkan import

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<TransactionProvider>(context, listen: false);
      provider.fetchTransactions();
      AppLogger.info('Aplikasi dimulai');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Keuangan Pribadi'),
      actions: [
        _buildSearchButton(),
        _buildMenuButton(),
      ],
    );
  }

  Widget _buildBody() {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            _buildBalanceCard(provider),
            Expanded(
              child: TransactionList(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: _navigateToAddTransaction,
      child: const Icon(Icons.add),
      elevation: 4,
      tooltip: 'Tambah Transaksi',
    );
  }

  Widget _buildSearchButton() {
    return IconButton(
      icon: const Icon(Icons.search),
      onPressed: _openSearch,
      tooltip: 'Cari Transaksi',
    );
  }

  Widget _buildMenuButton() {
    return PopupMenuButton<String>(
      onSelected: _handleMenuSelection,
      icon: const Icon(Icons.more_vert),
      itemBuilder: (BuildContext context) => [
        const PopupMenuItem(
          value: 'export_csv',
          child: ListTile(
            leading: Icon(Icons.table_chart, color: AppColors.primary),
            title: Text('Export ke CSV'),
          ),
        ),
        const PopupMenuItem(
          value: 'export_text',
          child: ListTile(
            leading: Icon(Icons.text_snippet, color: AppColors.primary),
            title: Text('Export ke Text'),
          ),
        ),
        const PopupMenuItem(
          value: 'backup',
          child: ListTile(
            leading: Icon(Icons.backup, color: AppColors.primary),
            title: Text('Backup Data'),
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'refresh',
          child: ListTile(
            leading: Icon(Icons.refresh, color: AppColors.primary),
            title: Text('Refresh'),
          ),
        ),
      ],
    );
  }

  void _navigateToAddTransaction() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddTransactionScreen(),
      ),
    );
  }

  void _openSearch() {
    showSearch(
      context: context,
      delegate: TransactionSearchDelegate(),
    );
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'export_csv':
        _exportToCSV();
        break;
      case 'export_text':
        _exportToText();
        break;
      case 'backup':
        _createBackup();
        break;
      case 'refresh':
        _refreshData();
        break;
    }
  }

  Widget _buildBalanceCard(TransactionProvider provider) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Row(
              children: [
                Icon(Icons.account_balance_wallet,
                    color: Colors.white, size: 28),
                SizedBox(width: 12),
                Text(
                  'Saldo Saat Ini',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Rp ${NumberFormat('#,##0').format(provider.balance)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildIncomeExpenseItem(
                  'Pemasukan',
                  provider.totalIncome,
                  AppColors.income,
                  Icons.arrow_downward,
                ),
                Container(
                  height: 40,
                  width: 1,
                  color: Colors.white.withOpacity(0.5),
                ),
                _buildIncomeExpenseItem(
                  'Pengeluaran',
                  provider.totalExpense,
                  AppColors.expense,
                  Icons.arrow_upward,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeExpenseItem(
      String title, double amount, Color color, IconData icon) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 4),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Rp ${NumberFormat('#,##0').format(amount)}',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  // Export methods
  void _exportToCSV() async {
    final provider = Provider.of<TransactionProvider>(context, listen: false);

    if (provider.transactions.isEmpty) {
      _showToast('Tidak ada data untuk diexport');
      return;
    }

    try {
      _showLoading();
      String filePath = await ExportHelper.exportToCSV(provider.transactions);
      _hideLoading();
      _showExportResult(filePath, 'CSV');
      AppLogger.info('Berhasil export CSV ke: $filePath');
    } catch (e, stackTrace) {
      _hideLoading();
      _showToast('Gagal export: $e');
      AppLogger.error('Gagal export CSV', e, stackTrace);
    }
  }

  void _exportToText() async {
    final provider = Provider.of<TransactionProvider>(context, listen: false);

    if (provider.transactions.isEmpty) {
      _showToast('Tidak ada data untuk diexport');
      return;
    }

    try {
      _showLoading();
      String filePath = await ExportHelper.exportToText(provider.transactions);
      _hideLoading();
      _showExportResult(filePath, 'Text');
      AppLogger.info('Berhasil export Text ke: $filePath');
    } catch (e, stackTrace) {
      _hideLoading();
      _showToast('Gagal export: $e');
      AppLogger.error('Gagal export Text', e, stackTrace);
    }
  }

  void _createBackup() async {
    final provider = Provider.of<TransactionProvider>(context, listen: false);

    if (provider.transactions.isEmpty) {
      _showToast('Tidak ada data untuk dibackup');
      return;
    }

    try {
      _showLoading();
      String filePath = await ExportHelper.createBackup(provider.transactions);
      _hideLoading();
      _showExportResult(filePath, 'Backup');
      AppLogger.info('Berhasil backup ke: $filePath');
    } catch (e, stackTrace) {
      _hideLoading();
      _showToast('Gagal backup: $e');
      AppLogger.error('Gagal backup', e, stackTrace);
    }
  }

  void _refreshData() {
    final provider = Provider.of<TransactionProvider>(context, listen: false);
    provider.fetchTransactions();
    _showToast('Data diperbarui');
    AppLogger.info('Data direfresh');
  }

  // Utility methods
  void _showLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      ),
    );
  }

  void _hideLoading() {
    Navigator.pop(context);
  }

  void _showExportResult(String filePath, String type) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success),
            const SizedBox(width: 12),
            Text('$type Berhasil'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('File telah disimpan di:'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                filePath,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              OpenFile.open(filePath);
            },
            child: const Text('Buka File'),
          ),
        ],
      ),
    );
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppColors.primary,
      textColor: Colors.white,
    );
  }
}
