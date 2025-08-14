import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
// Hapus import yang tidak digunakan: '../models/finance_transaction.dart'
import 'transaction_item.dart';

class TransactionSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context, listen: false);
    provider.setSearchQuery(query);

    if (provider.transactions.isEmpty) {
      return const Center(
        child: Text('Tidak ada hasil pencarian'),
      );
    }

    return ListView.builder(
      itemCount: provider.transactions.length,
      itemBuilder: (context, index) {
        final transaction = provider.transactions[index];
        return TransactionItem(
          key: ValueKey(transaction.id),
          transaction: transaction,
          onDelete: () {
            provider.deleteTransaction(transaction.id!);
            // Refresh search results
            provider.setSearchQuery(query);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context, listen: false);

    // Dapatkan semua judul dan kategori unik untuk suggestions
    Set<String> suggestions = <String>{};

    for (var transaction in provider.transactions) {
      suggestions.add(transaction.title);
      suggestions.add(transaction.category);
    }

    // Filter suggestions berdasarkan query
    final List<String> filteredSuggestions = suggestions
        .where((suggestion) =>
            suggestion.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: filteredSuggestions.length,
      itemBuilder: (context, index) {
        final suggestion = filteredSuggestions[index];
        return ListTile(
          title: Text(suggestion),
          onTap: () {
            query = suggestion;
            showResults(context);
          },
        );
      },
    );
  }
}
