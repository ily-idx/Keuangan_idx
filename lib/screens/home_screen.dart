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
      centerTitle: true,
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
    );
  }

  Widget _buildSearchButton() {
    return IconButton(
      icon: const Icon(Icons.search),
      onPressed: _openSearch,
    );
  }

  Widget _buildMenuButton() {
    return PopupMenuButton<String>(
      onSelected: _handleMenuSelection,
      itemBuilder: (BuildContext context) => [
        const PopupMenuItem(
          value: 'export_csv',
          child: ListTile(
            leading: Icon(Icons.table_chart),
            title: Text('Export ke CSV'),
          ),
        ),
        const PopupMenuItem(
          value: 'export_text',
          child: ListTile(
            leading: Icon(Icons.text_snippet),
            title: Text('Export ke Text'),
          ),
        ),
        const PopupMenuItem(
          value: 'backup',
          child: ListTile(
            leading: Icon(Icons.backup),
            title: Text('Backup Data'),
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'refresh',
          child: ListTile(
            leading: Icon(Icons.refresh),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.blue, Colors.lightBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Saldo Saat Ini',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Rp ${NumberFormat('#,##0').format(provider.balance)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildIncomeExpenseRow(provider),
        ],
      ),
    );
  }

  Widget _buildIncomeExpenseRow(TransactionProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildIncomeExpenseItem(
          'Pemasukan',
          provider.totalIncome,
          Colors.green,
        ),
        Container(
          height: 40,
          width: 1,
          color: Colors.white.withOpacity(0.5),
        ),
        _buildIncomeExpenseItem(
          'Pengeluaran',
          provider.totalExpense,
          Colors.red,
        ),
      ],
    );
  }

  Widget _buildIncomeExpenseItem(String title, double amount, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
        Text(
          'Rp ${NumberFormat('#,##0').format(amount)}',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
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
        child: CircularProgressIndicator(),
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
        title: Text('$type Berhasil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('File telah disimpan di:'),
            const SizedBox(height: 8),
            Text(
              filePath,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
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
    );
  }
}
