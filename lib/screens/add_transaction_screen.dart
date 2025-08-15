import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/finance_transaction.dart';
import '../providers/transaction_provider.dart';
import '../utils/constants.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({Key? key}) : super(key: key);

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late double _amount;
  bool _isIncome = true;
  String _selectedCategory = 'Lainnya';

  // Daftar kategori
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
    _selectedCategory = _currentCategories.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Transaksi'),
        backgroundColor: AppColors.primary,
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
              const SizedBox(height: 24),
              _buildSubmitButton(),
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
        hintText: 'Contoh: Beli makanan',
      ),
      validator: (value) => value!.isEmpty ? 'Masukkan judul transaksi' : null,
      onSaved: (value) => _title = value!,
    );
  }

  Widget _buildAmountField() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Jumlah (Rp)',
        prefixIcon: Icon(Icons.attach_money),
        hintText: 'Contoh: 50000',
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value!.isEmpty) return 'Masukkan jumlah';
        if (double.tryParse(value) == null) return 'Masukkan angka yang valid';
        if (double.parse(value) <= 0) return 'Jumlah harus lebih dari 0';
        return null;
      },
      onSaved: (value) => _amount = double.parse(value!),
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

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveTransaction,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Simpan Transaksi',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _saveTransaction() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final transaction = FinanceTransaction(
        title: _title,
        amount: _amount,
        date: DateTime.now(),
        isIncome: _isIncome,
        category: _selectedCategory,
      );

      await Provider.of<TransactionProvider>(context, listen: false)
          .addTransaction(transaction);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Transaksi berhasil disimpan'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
