import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import '../providers/transaction_provider.dart';
import '../widgets/transaction_list.dart';
import '../screens/add_transaction_screen.dart';
import '../utils/export_helper.dart';
import '../widgets/search_delegate.dart'; // Tambahkan import

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TransactionProvider>(context, listen: false)
          .fetchTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keuangan Pribadi'),
        centerTitle: true,
        actions: [
          // Tombol Search
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: TransactionSearchDelegate(),
              );
            },
          ),
          // Menu Popup
          PopupMenuButton<String>(
            onSelected: (String result) {
              switch (result) {
                case 'export_csv':
                  _exportToCSV(context);
                  break;
                case 'export_text':
                  _exportToText(context);
                  break;
                case 'backup':
                  _createBackup(context);
                  break;
                case 'refresh':
                  Provider.of<TransactionProvider>(context, listen: false)
                      .fetchTransactions();
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'export_csv',
                child: ListTile(
                  leading: Icon(Icons.table_chart),
                  title: Text('Export ke CSV'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'export_text',
                child: ListTile(
                  leading: Icon(Icons.text_snippet),
                  title: Text('Export ke Text'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'backup',
                child: ListTile(
                  leading: Icon(Icons.backup),
                  title: Text('Backup Data'),
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'refresh',
                child: ListTile(
                  leading: Icon(Icons.refresh),
                  title: Text('Refresh'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<TransactionProvider>(
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddTransactionScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBalanceCard(TransactionProvider provider) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(12),
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
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  const Text(
                    'Pemasukan',
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    'Rp ${NumberFormat('#,##0').format(provider.totalIncome)}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                height: 40,
                width: 1,
                color: Colors.white,
              ),
              Column(
                children: [
                  const Text(
                    'Pengeluaran',
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    'Rp ${NumberFormat('#,##0').format(provider.totalExpense)}',
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Fungsi export ke CSV
  void _exportToCSV(BuildContext context) async {
    final provider = Provider.of<TransactionProvider>(context, listen: false);

    if (provider.transactions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak ada data untuk diexport'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      // Tampilkan loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      String filePath = await ExportHelper.exportToCSV(provider.transactions);

      // Tutup loading dialog
      Navigator.pop(context);

      // Tampilkan hasil
      _showExportResult(context, filePath, 'CSV');
    } catch (e) {
      Navigator.pop(context); // Tutup loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal export: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Fungsi export ke Text
  void _exportToText(BuildContext context) async {
    final provider = Provider.of<TransactionProvider>(context, listen: false);

    if (provider.transactions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak ada data untuk diexport'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      // Tampilkan loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      String filePath = await ExportHelper.exportToText(provider.transactions);

      // Tutup loading dialog
      Navigator.pop(context);

      // Tampilkan hasil
      _showExportResult(context, filePath, 'Text');
    } catch (e) {
      Navigator.pop(context); // Tutup loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal export: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Fungsi backup data
  void _createBackup(BuildContext context) async {
    final provider = Provider.of<TransactionProvider>(context, listen: false);

    if (provider.transactions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak ada data untuk dibackup'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      // Tampilkan loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      String filePath = await ExportHelper.createBackup(provider.transactions);

      // Tutup loading dialog
      Navigator.pop(context);

      // Tampilkan hasil
      _showExportResult(context, filePath, 'Backup');
    } catch (e) {
      Navigator.pop(context); // Tutup loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal backup: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Tampilkan hasil export
  void _showExportResult(BuildContext context, String filePath, String type) {
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
              // Coba buka file
              OpenFile.open(filePath);
            },
            child: const Text('Buka File'),
          ),
        ],
      ),
    );
  }
}
