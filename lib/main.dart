import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'providers/transaction_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (context) => TransactionProvider(),
      child: const MyApp(), // Tambahkan const di sini
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key); // Tambahkan const constructor

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Keuangan Pribadi',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(), // Tambahkan const di sini
      debugShowCheckedModeBanner: false,
    );
  }
}
