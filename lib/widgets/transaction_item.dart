import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../models/finance_transaction.dart';
import '../screens/edit_transaction_screen.dart';
import '../utils/constants.dart';

class TransactionItem extends StatelessWidget {
  final FinanceTransaction transaction;
  final VoidCallback onDelete;

  const TransactionItem({
    Key? key,
    required this.transaction,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: _buildLeadingIcon(),
        title: Text(
          transaction.title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: _buildSubtitle(),
        trailing: _buildAmountText(),
        onTap: () => _editTransaction(context),
        onLongPress: _showDeleteConfirmation,
      ),
    );
  }

  Widget _buildLeadingIcon() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: transaction.isIncome
            ? AppColors.incomeLight
            : AppColors.expenseLight,
      ),
      child: Icon(
        _getCategoryIcon(transaction.category),
        color: transaction.isIncome ? AppColors.income : AppColors.expense,
        size: 24,
      ),
    );
  }

  Widget _buildSubtitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.category,
              size: 14,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              transaction.category,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Icon(
              Icons.access_time,
              size: 14,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              DateFormat('dd MMM yyyy').format(transaction.date),
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAmountText() {
    return Text(
      '${transaction.isIncome ? '+' : '-'} Rp ${NumberFormat('#,##0').format(transaction.amount)}',
      style: TextStyle(
        color: transaction.isIncome ? AppColors.income : AppColors.expense,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    );
  }

  void _editTransaction(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTransactionScreen(transaction: transaction),
      ),
    );
  }

  void _showDeleteConfirmation() {
    Fluttertoast.showToast(
      msg: "Tekan dan tahan untuk hapus",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppColors.primary,
      textColor: Colors.white,
    );
  }

  IconData _getCategoryIcon(String category) {
    const categoryIcons = {
      'Gaji': Icons.work,
      'Bonus': Icons.card_giftcard,
      'Investasi': Icons.trending_up,
      'Hadiah': Icons.card_giftcard,
      'Makanan': Icons.restaurant,
      'Transport': Icons.directions_car,
      'Belanja': Icons.shopping_cart,
      'Hiburan': Icons.movie,
      'Kesehatan': Icons.local_hospital,
      'Pendidikan': Icons.school,
      'Utilitas': Icons.flash_on,
      'Lainnya': Icons.category,
    };

    return categoryIcons[category] ?? Icons.category;
  }
}
