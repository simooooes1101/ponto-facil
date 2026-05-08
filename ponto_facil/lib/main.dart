import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'services/notification_service.dart';
import 'utils/app_theme.dart';
import 'screens/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Orientação: somente retrato
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Notificações
  await NotificationService.instance.inicializar();

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider()..inicializar(),
      child: const PontoFacilApp(),
    ),
  );
}

class PontoFacilApp extends StatelessWidget {
  const PontoFacilApp({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return MaterialApp(
      title: 'Ponto Fácil',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: provider.themeMode,
      home: const MainShell(),
    );
  }
}
