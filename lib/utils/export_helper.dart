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
      // Header CSV
      List<List<dynamic>> csvData = [
        ['ID', 'Judul', 'Jumlah', 'Tanggal', 'Jenis', 'Kategori']
      ];

      // Data transaksi
      for (var transaction in transactions) {
        csvData.add([
          transaction.id,
          transaction.title,
          transaction.amount,
          DateFormat('yyyy-MM-dd HH:mm:ss').format(transaction.date),
          transaction.isIncome ? 'Pemasukan' : 'Pengeluaran',
          transaction.category,
        ]);
      }

      // Konversi ke CSV string
      String csv = const ListToCsvConverter().convert(csvData);

      // Dapatkan direktori download
      Directory? directory;

      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        // Untuk web/desktop
        directory = await getDownloadsDirectory();
        if (directory == null) {
          directory = await getTemporaryDirectory();
        }
      }

      // Cek jika directory masih null
      if (directory == null) {
        throw Exception('Tidak dapat mengakses direktori penyimpanan');
      }

      // Buat nama file dengan timestamp
      String fileName =
          'keuangan_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv';

      String filePath = '${directory.path}/$fileName';

      // Tulis file
      File file = File(filePath);
      await file.writeAsString(csv, encoding: utf8);

      return filePath;
    } catch (e) {
      rethrow;
    }
  }

  static Future<String> exportToText(
      List<FinanceTransaction> transactions) async {
    try {
      StringBuffer buffer = StringBuffer();

      // Header
      buffer.writeln('LAPORAN KEUANGAN');
      buffer.writeln(
          'Tanggal Export: ${DateFormat('dd MMM yyyy HH:mm').format(DateTime.now())}');
      buffer.writeln('=' * 50);
      buffer.writeln();

      // Ringkasan
      double totalIncome = transactions
          .where((tx) => tx.isIncome)
          .fold(0.0, (sum, tx) => sum + tx.amount);

      double totalExpense = transactions
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

      // Detail transaksi
      buffer.writeln('DETAIL TRANSAKSI:');
      buffer.writeln();

      for (var transaction in transactions) {
        buffer.writeln(
            '${transaction.isIncome ? '▶' : '◀'} ${transaction.title}');
        buffer.writeln('   Kategori: ${transaction.category}');
        buffer.writeln(
            '   Jumlah: Rp ${NumberFormat('#,##0').format(transaction.amount)}');
        buffer.writeln(
            '   Tanggal: ${DateFormat('dd MMM yyyy HH:mm').format(transaction.date)}');
        buffer.writeln();
      }

      // Dapatkan direktori
      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = await getDownloadsDirectory();
        if (directory == null) {
          directory = await getTemporaryDirectory();
        }
      }

      // Cek jika directory masih null
      if (directory == null) {
        throw Exception('Tidak dapat mengakses direktori penyimpanan');
      }

      // Buat nama file
      String fileName =
          'laporan_keuangan_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.txt';

      String filePath = '${directory.path}/$fileName';

      // Tulis file
      File file = File(filePath);
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
      // Konversi ke JSON
      List<Map<String, dynamic>> jsonList =
          transactions.map((tx) => tx.toMap()).toList();

      String jsonString = jsonEncode(jsonList);

      // Dapatkan direktori
      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = await getDownloadsDirectory();
        if (directory == null) {
          directory = await getTemporaryDirectory();
        }
      }

      // Cek jika directory masih null
      if (directory == null) {
        throw Exception('Tidak dapat mengakses direktori penyimpanan');
      }

      // Buat nama file backup
      String fileName =
          'backup_keuangan_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.json';

      String filePath = '${directory.path}/$fileName';

      // Tulis file
      File file = File(filePath);
      await file.writeAsString(jsonString, encoding: utf8);

      return filePath;
    } catch (e) {
      rethrow;
    }
  }
}
