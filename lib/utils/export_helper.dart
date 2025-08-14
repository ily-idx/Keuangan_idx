import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import '../models/finance_transaction.dart';

class ExportHelper {
  static Future<String> exportToCSV(
      List<FinanceTransaction> transactions) async {
    try {
      // Header CSV - gunakan final
      final List<List<dynamic>> csvData = [
        ['ID', 'Judul', 'Jumlah', 'Tanggal', 'Jenis', 'Kategori']
      ];

      // Data transaksi - gunakan final dalam loop
      for (final transaction in transactions) {
        csvData.add([
          transaction.id,
          transaction.title,
          transaction.amount,
          DateFormat('yyyy-MM-dd HH:mm:ss').format(transaction.date),
          transaction.isIncome ? 'Pemasukan' : 'Pengeluaran',
          transaction.category,
        ]);
      }

      // Konversi ke CSV string - gunakan final
      final String csv = const ListToCsvConverter().convert(csvData);

      // Dapatkan direktori download - gunakan final
      Directory? directory;

      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        // Untuk web/desktop - gunakan null-aware assignment
        directory =
            (await getDownloadsDirectory()) ?? await getTemporaryDirectory();
      }

      // Cek jika directory masih null
      if (directory == null) {
        throw Exception('Tidak dapat mengakses direktori penyimpanan');
      }

      // Buat nama file dengan timestamp - gunakan final
      final String fileName =
          'keuangan_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv';

      final String filePath = '${directory.path}/$fileName';

      // Tulis file - gunakan final
      final File file = File(filePath);
      await file.writeAsString(csv, encoding: utf8);

      return filePath;
    } catch (e) {
      rethrow;
    }
  }

  static Future<String> exportToText(
      List<FinanceTransaction> transactions) async {
    try {
      // Gunakan final
      final StringBuffer buffer = StringBuffer();

      // Header - gunakan final untuk variabel
      buffer.writeln('LAPORAN KEUANGAN');
      buffer.writeln(
          'Tanggal Export: ${DateFormat('dd MMM yyyy HH:mm').format(DateTime.now())}');
      buffer.writeln('=' * 50);
      buffer.writeln();

      // Ringkasan - gunakan final
      final double totalIncome = transactions
          .where((tx) => tx.isIncome)
          .fold(0.0, (sum, tx) => sum + tx.amount);

      final double totalExpense = transactions
          .where((tx) => !tx.isIncome)
          .fold(0.0, (sum, tx) => sum + tx.amount);

      buffer.writeln(
          'TOTAL PEMASUKAN: Rp ${NumberFormat('#,##0').format(totalIncome)}');
      buffer.writeln(
          'TOTAL PENGELUARAN: Rp ${NumberFormat('#,##0').format(totalExpense)}');
      buffer.writeln(
          'SALDO AKHIR: Rp ${NumberFormat('#,##0').format(totalIncome - totalExpense)}');
      buffer.writeln();
      buffer.writeln('-' * 50);
      buffer.writeln();

      // Detail transaksi - gunakan final dalam loop
      buffer.writeln('DETAIL TRANSAKSI:');
      buffer.writeln();

      for (final transaction in transactions) {
        buffer.writeln(
            '${transaction.isIncome ? '▶' : '◀'} ${transaction.title}');
        buffer.writeln('   Kategori: ${transaction.category}');
        buffer.writeln(
            '   Jumlah: Rp ${NumberFormat('#,##0').format(transaction.amount)}');
        buffer.writeln(
            '   Tanggal: ${DateFormat('dd MMM yyyy HH:mm').format(transaction.date)}');
        buffer.writeln();
      }

      // Dapatkan direktori - gunakan final
      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        // Gunakan null-aware assignment
        directory =
            (await getDownloadsDirectory()) ?? await getTemporaryDirectory();
      }

      // Cek jika directory masih null
      if (directory == null) {
        throw Exception('Tidak dapat mengakses direktori penyimpanan');
      }

      // Buat nama file - gunakan final
      final String fileName =
          'laporan_keuangan_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.txt';

      final String filePath = '${directory.path}/$fileName';

      // Tulis file - gunakan final
      final File file = File(filePath);
      await file.writeAsString(buffer.toString(), encoding: utf8);

      return filePath;
    } catch (e) {
      rethrow;
    }
  }

  // Fungsi backup data (simpan sebagai JSON)
  static Future<String> createBackup(
      List<FinanceTransaction> transactions) async {
    try {
      // Konversi ke JSON - gunakan final
      final List<Map<String, dynamic>> jsonList =
          transactions.map((tx) => tx.toMap()).toList();

      final String jsonString = jsonEncode(jsonList);

      // Dapatkan direktori - gunakan final
      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        // Gunakan null-aware assignment
        directory =
            (await getDownloadsDirectory()) ?? await getTemporaryDirectory();
      }

      // Cek jika directory masih null
      if (directory == null) {
        throw Exception('Tidak dapat mengakses direktori penyimpanan');
      }

      // Buat nama file backup - gunakan final
      final String fileName =
          'backup_keuangan_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.json';

      final String filePath = '${directory.path}/$fileName';

      // Tulis file - gunakan final
      final File file = File(filePath);
      await file.writeAsString(jsonString, encoding: utf8);

      return filePath;
    } catch (e) {
      rethrow;
    }
  }
}
