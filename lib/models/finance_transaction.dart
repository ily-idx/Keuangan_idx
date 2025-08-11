class FinanceTransaction {
  final int? id;
  final String title;
  final double amount;
  final DateTime date;
  final bool isIncome;
  final String category; // Tambahkan field kategori

  FinanceTransaction({
    this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.isIncome,
    required this.category, // Tambahkan parameter
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'isIncome': isIncome ? 1 : 0,
      'category': category, // Tambahkan ke map
    };
  }

  factory FinanceTransaction.fromMap(Map<String, dynamic> map) {
    return FinanceTransaction(
      id: map['id'],
      title: map['title'],
      amount: map['amount'].toDouble(),
      date: DateTime.parse(map['date']),
      isIncome: map['isIncome'] == 1,
      category: map['category'] ?? 'Lainnya', // Default kategori
    );
  }

  static int generateId() {
    return DateTime.now().millisecondsSinceEpoch;
  }
}
