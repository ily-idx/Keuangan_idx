import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../models/finance_transaction.dart';
import 'transaction_item.dart';

class TransactionList extends StatelessWidget {
  const TransactionList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            // Filter Bar
            _buildFilterBar(context, provider),
            // Transaction List
            Expanded(
              child: _buildTransactionContent(provider),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterBar(BuildContext context, TransactionProvider provider) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
          bottom:
              BorderSide(color: Colors.grey[300]!), // Hapus ! yang tidak perlu
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Tombol Semua
          FilterChip(
            label: const Text('Semua'),
            selected: provider.filterByType == null,
            onSelected: (selected) {
              provider.setFilterByType(null);
            },
            selectedColor: Colors.blue,
            backgroundColor: Colors.white,
          ),
          // Tombol Pemasukan
          FilterChip(
            label: const Text('Pemasukan'),
            selected: provider.filterByType == true,
            onSelected: (selected) {
              provider.setFilterByType(true);
            },
            selectedColor: Colors.green,
            backgroundColor: Colors.white,
          ),
          // Tombol Pengeluaran
          FilterChip(
            label: const Text('Pengeluaran'),
            selected: provider.filterByType == false,
            onSelected: (selected) {
              provider.setFilterByType(false);
            },
            selectedColor: Colors.red,
            backgroundColor: Colors.white,
          ),
          // Tombol Clear Filter
          if (provider.filterByType != null || provider.searchQuery.isNotEmpty)
            IconButton(
              onPressed: () {
                provider.clearFilters();
              },
              icon: const Icon(Icons.clear),
            ),
        ],
      ),
    );
  }

  Widget _buildTransactionContent(TransactionProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.transactions.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Belum ada transaksi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Tekan tombol + untuk menambahkan',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8),
      itemCount: provider.transactions.length,
      itemBuilder: (context, index) {
        final transaction = provider.transactions[index];
        return TransactionItem(
          key: ValueKey(transaction.id),
          transaction: transaction,
          onDelete: () => _showDeleteDialog(context, transaction, provider),
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, FinanceTransaction transaction,
      TransactionProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Transaksi'),
        content: const Text('Apakah Anda yakin ingin menghapus transaksi ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteTransaction(transaction.id!);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Transaksi dihapus'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
