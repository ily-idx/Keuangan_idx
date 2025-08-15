import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'providers/transaction_provider.dart';
import 'utils/constants.dart'; // Tambahkan import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (context) => TransactionProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Keuangan Pribadi',
      theme: AppThemes.lightTheme, // Gunakan tema baru
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
