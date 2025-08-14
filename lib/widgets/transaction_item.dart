import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../models/finance_transaction.dart';
import '../screens/edit_transaction_screen.dart';

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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 2,
      child: ListTile(
        leading: _buildLeadingIcon(),
        title: Text(
          transaction.title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
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
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: transaction.isIncome
            ? Colors.green.withOpacity(0.2)
            : Colors.red.withOpacity(0.2),
      ),
      child: Icon(
        _getCategoryIcon(transaction.category),
        color: transaction.isIncome ? Colors.green : Colors.red,
      ),
    );
  }

  Widget _buildSubtitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          transaction.category,
          style: const TextStyle(
            color: Colors.blue,
            fontSize: 12,
          ),
        ),
        Text(
          DateFormat('dd/MM/yyyy').format(transaction.date),
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildAmountText() {
    return Text(
      '${transaction.isIncome ? '+' : '-'} Rp ${NumberFormat('#,##0').format(transaction.amount)}',
      style: TextStyle(
        color: transaction.isIncome ? Colors.green : Colors.red,
        fontWeight: FontWeight.bold,
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
    // Bisa diganti dengan dialog konfirmasi atau toast
    Fluttertoast.showToast(
      msg: "Tekan dan tahan untuk hapus",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
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
