import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/finance_transaction.dart';
import '../providers/transaction_provider.dart';
import '../utils/constants.dart';

class EditTransactionScreen extends StatefulWidget {
  final FinanceTransaction transaction;

  const EditTransactionScreen({Key? key, required this.transaction})
      : super(key: key);

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late double _amount;
  late bool _isIncome;
  late String _selectedCategory;
  late DateTime _selectedDate;

  // Daftar kategori - gunakan static const
  static const List<String> _incomeCategories = [
    'Gaji',
    'Bonus',
    'Investasi',
    'Hadiah',
    'Lainnya'
  ];

  static const List<String> _expenseCategories = [
    'Makanan',
    'Transport',
    'Belanja',
    'Hiburan',
    'Kesehatan',
    'Pendidikan',
    'Utilitas',
    'Lainnya'
  ];

  List<String> get _currentCategories =>
      _isIncome ? _incomeCategories : _expenseCategories;

  @override
  void initState() {
    super.initState();
    // Inisialisasi dengan data transaksi yang ada
    _title = widget.transaction.title;
    _amount = widget.transaction.amount;
    _isIncome = widget.transaction.isIncome;
    _selectedCategory = widget.transaction.category;
    _selectedDate = widget.transaction.date;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Transaksi'),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            onPressed: _deleteTransaction,
            icon: const Icon(Icons.delete),
            color: AppColors.error,
            tooltip: 'Hapus Transaksi',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitleField(),
              const SizedBox(height: 16),
              _buildAmountField(),
              const SizedBox(height: 16),
              _buildTypeSelector(),
              const SizedBox(height: 16),
              _buildCategoryField(),
              const SizedBox(height: 16),
              _buildDateField(),
              const SizedBox(height: 24),
              _buildUpdateButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Judul Transaksi',
        prefixIcon: Icon(Icons.description),
      ),
      initialValue: _title,
      validator: (value) => value!.isEmpty ? 'Masukkan judul transaksi' : null,
      onChanged: (value) => _title = value,
    );
  }

  Widget _buildAmountField() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Jumlah (Rp)',
        prefixIcon: Icon(Icons.attach_money),
      ),
      initialValue: _amount.toString(),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value!.isEmpty) return 'Masukkan jumlah';
        if (double.tryParse(value) == null) return 'Masukkan angka yang valid';
        if (double.parse(value) <= 0) return 'Jumlah harus lebih dari 0';
        return null;
      },
      onChanged: (value) => _amount = double.parse(value),
    );
  }

  Widget _buildTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Jenis Transaksi',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTypeOption(
                  title: 'Pemasukan',
                  icon: Icons.arrow_downward,
                  color: AppColors.income,
                  isSelected: _isIncome,
                  onTap: () => setState(() {
                    _isIncome = true;
                    // Reset kategori ketika jenis berubah
                    final newCategories =
                        _isIncome ? _incomeCategories : _expenseCategories;
                    if (!newCategories.contains(_selectedCategory)) {
                      _selectedCategory = newCategories.first;
                    }
                  }),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTypeOption(
                  title: 'Pengeluaran',
                  icon: Icons.arrow_upward,
                  color: AppColors.expense,
                  isSelected: !_isIncome,
                  onTap: () => setState(() {
                    _isIncome = false;
                    // Reset kategori ketika jenis berubah
                    final newCategories =
                        _isIncome ? _incomeCategories : _expenseCategories;
                    if (!newCategories.contains(_selectedCategory)) {
                      _selectedCategory = newCategories.first;
                    }
                  }),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeOption({
    required String title,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? color : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : AppColors.textSecondary,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? color : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryField() {
    // Pastikan _selectedCategory ada dalam _currentCategories
    final categories = _currentCategories;
    if (!categories.contains(_selectedCategory)) {
      _selectedCategory = categories.first;
    }

    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Kategori',
        prefixIcon: Icon(Icons.category),
      ),
      value: _selectedCategory,
      items: categories
          .map((category) => DropdownMenuItem(
                value: category,
                child: Text(category),
              ))
          .toList(),
      onChanged: (value) => setState(() => _selectedCategory = value!),
      validator: (value) => value == null ? 'Pilih kategori' : null,
    );
  }

  Widget _buildDateField() {
    return Card(
      child: ListTile(
        title: const Text('Tanggal Transaksi'),
        subtitle: Text(DateFormat('dd MMM yyyy').format(_selectedDate)),
        trailing: const Icon(Icons.calendar_today),
        onTap: () => _selectDate(context),
      ),
    );
  }

  Widget _buildUpdateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _updateTransaction,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Update Transaksi',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _updateTransaction() async {
    if (_formKey.currentState!.validate()) {
      final updatedTransaction = FinanceTransaction(
        id: widget.transaction.id,
        title: _title,
        amount: _amount,
        date: _selectedDate,
        isIncome: _isIncome,
        category: _selectedCategory,
      );

      await Provider.of<TransactionProvider>(context, listen: false)
          .updateTransaction(updatedTransaction);

      if (!mounted) return;
      Navigator.pop(context);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Transaksi berhasil diperbarui'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _deleteTransaction() {
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
            onPressed: () async {
              await Provider.of<TransactionProvider>(context, listen: false)
                  .deleteTransaction(widget.transaction.id!);

              if (!mounted) return;
              Navigator.pop(context); // Tutup dialog
              if (!mounted) return;
              Navigator.pop(context); // Tutup screen edit
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Transaksi berhasil dihapus'),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
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
