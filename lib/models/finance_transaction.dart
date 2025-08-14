import 'package:equatable/equatable.dart';

class FinanceTransaction extends Equatable {
  final int? id;
  final String title;
  final double amount;
  final DateTime date;
  final bool isIncome;
  final String category;

  const FinanceTransaction({
    // Tambahkan const di sini
    this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.isIncome,
    required this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'isIncome': isIncome ? 1 : 0,
      'category': category,
    };
  }

  factory FinanceTransaction.fromMap(Map<String, dynamic> map) {
    return FinanceTransaction(
      id: map['id'],
      title: map['title'],
      amount: map['amount'].toDouble(),
      date: DateTime.parse(map['date']),
      isIncome: map['isIncome'] == 1,
      category: map['category'] ?? 'Lainnya',
    );
  }

  static int generateId() {
    return DateTime.now().millisecondsSinceEpoch;
  }

  FinanceTransaction copyWith({
    int? id,
    String? title,
    double? amount,
    DateTime? date,
    bool? isIncome,
    String? category,
  }) {
    return FinanceTransaction(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      isIncome: isIncome ?? this.isIncome,
      category: category ?? this.category,
    );
  }

  @override
  List<Object?> get props => [id, title, amount, date, isIncome, category];
}
