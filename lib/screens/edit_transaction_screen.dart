import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/finance_transaction.dart';
import '../providers/transaction_provider.dart';

class EditTransactionScreen extends StatefulWidget {
  final FinanceTransaction transaction;

  const EditTransactionScreen({Key? key, required this.transaction})
      : super(key: key);

  @override
  State<EditTransactionScreen> createState() =>
      _EditTransactionScreenState(); // Perbaiki tipe return
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  // Ini private, tidak masalah
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late double _amount;
  late bool _isIncome;
  late String _selectedCategory;
  late DateTime _selectedDate;

  // Daftar kategori
  final List<String> _incomeCategories = [
    'Gaji',
    'Bonus',
    'Investasi',
    'Hadiah',
    'Lainnya'
  ];

  final List<String> _expenseCategories = [
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
        actions: [
          IconButton(
            onPressed: _deleteTransaction,
            icon: const Icon(Icons.delete),
            color: Colors.red,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Judul Transaksi',
                  border: OutlineInputBorder(),
                ),
                initialValue: _title,
                validator: (value) => value!.isEmpty ? 'Masukkan judul' : null,
                onChanged: (value) => _title = value,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Jumlah',
                  border: OutlineInputBorder(),
                ),
                initialValue: _amount.toString(),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) return 'Masukkan jumlah';
                  if (double.tryParse(value) == null)
                    return 'Masukkan angka yang valid';
                  if (double.parse(value) <= 0)
                    return 'Jumlah harus lebih dari 0';
                  return null;
                },
                onChanged: (value) => _amount = double.parse(value),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Jenis: '),
                  Radio<bool>(
                    value: true,
                    groupValue: _isIncome,
                    onChanged: (value) {
                      setState(() {
                        _isIncome = value!;
                        // Reset kategori jika jenis berubah
                        if (!_currentCategories.contains(_selectedCategory)) {
                          _selectedCategory = _currentCategories.first;
                        }
                      });
                    },
                  ),
                  const Text('Pemasukan'),
                  Radio<bool>(
                    value: false,
                    groupValue: _isIncome,
                    onChanged: (value) {
                      setState(() {
                        _isIncome = value!;
                        // Reset kategori jika jenis berubah
                        if (!_currentCategories.contains(_selectedCategory)) {
                          _selectedCategory = _currentCategories.first;
                        }
                      });
                    },
                  ),
                  const Text('Pengeluaran'),
                ],
              ),
              const SizedBox(height: 16),
              // Dropdown kategori
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(),
                ),
                value: _selectedCategory,
                items: _currentCategories
                    .map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
                validator: (value) => value == null ? 'Pilih kategori' : null,
              ),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  title: const Text('Tanggal'),
                  subtitle:
                      Text(DateFormat('dd MMM yyyy').format(_selectedDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => _selectDate(context),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _updateTransaction,
                  child: const Text('Update Transaksi'),
                ),
              ),
            ],
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

      // Perbaiki penggunaan context setelah async gap
      if (!mounted) return; // Cek mounted untuk State
      Navigator.pop(context);
      if (!mounted) return; // Cek mounted lagi
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaksi diperbarui'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _deleteTransaction() {
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
            onPressed: () async {
              await Provider.of<TransactionProvider>(context, listen: false)
                  .deleteTransaction(widget.transaction.id!);

              // Perbaiki penggunaan context setelah async gap
              if (!mounted) return; // Cek mounted untuk State
              Navigator.pop(context); // Tutup dialog
              if (!mounted) return; // Cek mounted lagi
              Navigator.pop(context); // Tutup screen edit
              if (!mounted) return; // Cek mounted lagi
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
