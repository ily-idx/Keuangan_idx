import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../models/finance_transaction.dart';
import 'transaction_item.dart';
import '../utils/constants.dart';

class TransactionList extends StatelessWidget {
  const TransactionList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            _buildFilterBar(context, provider),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border(
          bottom: BorderSide(color: AppColors.divider),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildFilterChip(
            label: 'Semua',
            selected: provider.filterByType == null,
            selectedColor: AppColors.primary,
            onTap: () => provider.setFilterByType(null),
          ),
          _buildFilterChip(
            label: 'Pemasukan',
            selected: provider.filterByType == true,
            selectedColor: AppColors.income,
            onTap: () => provider.setFilterByType(true),
          ),
          _buildFilterChip(
            label: 'Pengeluaran',
            selected: provider.filterByType == false,
            selectedColor: AppColors.expense,
            onTap: () => provider.setFilterByType(false),
          ),
          if (provider.filterByType != null || provider.searchQuery.isNotEmpty)
            IconButton(
              onPressed: provider.clearFilters,
              icon: const Icon(Icons.clear, color: AppColors.error),
              tooltip: 'Hapus Filter',
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required Color selectedColor,
    required VoidCallback onTap,
  }) {
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.white : AppColors.textSecondary,
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: selected,
      selectedColor: selectedColor,
      backgroundColor: AppColors.background,
      onSelected: (selected) => onTap(),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      labelStyle: const TextStyle(fontSize: 13),
    );
  }

  Widget _buildTransactionContent(TransactionProvider provider) {
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
    }

    if (provider.transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 80,
              color: AppColors.textSecondary.withOpacity(0.3),
            ),
            const SizedBox(height: 20),
            const Text(
              'Belum ada transaksi',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tekan tombol + untuk menambahkan',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
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
        title: const Row(
          children: [
            Icon(Icons.delete, color: AppColors.error),
            SizedBox(width: 12),
            Text('Hapus Transaksi'),
          ],
        ),
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
                  backgroundColor: AppColors.error,
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
