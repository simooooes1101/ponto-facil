import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'home_screen.dart';
import 'historico_screen.dart';
import 'relatorios_screen.dart';
import 'configuracoes_screen.dart';
import 'pin_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  bool _desbloqueado = false;

  static const _telas = [
    HomeScreen(),
    HistoricoScreen(),
    RelatoriosScreen(),
    ConfiguracoesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    // PIN guard
    if (provider.config.pinAtivo && !_desbloqueado) {
      return PinScreen(
        provider: provider,
        onDesbloqueado: () => setState(() => _desbloqueado = true),
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _telas,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history_rounded),
            label: 'Histórico',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart_rounded),
            label: 'Relatórios',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Config.',
          ),
        ],
      ),
    );
  }
}
