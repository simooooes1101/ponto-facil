import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/registro_ponto.dart';
import '../models/configuracao.dart';
import '../services/ponto_service.dart';
import '../services/notification_service.dart';

class AppProvider extends ChangeNotifier {
  final PontoService _pontoService = PontoService();
  final DatabaseHelper _db = DatabaseHelper.instance;

  List<RegistroPonto> _registros = [];
  RegistroPonto? _ultimoRegistro;
  Configuracao _config = const Configuracao();
  bool _trabalhando = false;
  bool _carregando = false;
  String? _mensagemSnack;

  List<RegistroPonto> get registros => _registros;
  RegistroPonto? get ultimoRegistro => _ultimoRegistro;
  Configuracao get config => _config;
  bool get trabalhando => _trabalhando;
  bool get carregando => _carregando;
  String? get mensagemSnack => _mensagemSnack;

  ThemeMode get themeMode {
    switch (_config.tema) {
      case 'claro':
        return ThemeMode.light;
      case 'escuro':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> inicializar() async {
    await carregarConfiguracoes();
    await carregarRegistros();
    await _determinarStatus();
  }

  Future<void> carregarConfiguracoes() async {
    final map = await _db.lerTodasConfigs();
    _config = Configuracao.fromMap(map);
    notifyListeners();
  }

  Future<void> carregarRegistros() async {
    _registros = await _pontoService.buscarTodos();
    _ultimoRegistro = await _pontoService.ultimoRegistro();
    notifyListeners();
  }

  Future<void> _determinarStatus() async {
    final hoje = DateTime.now();
    final dataHoje =
        '${hoje.year}-${hoje.month.toString().padLeft(2, '0')}-${hoje.day.toString().padLeft(2, '0')}';
    final registrosHoje =
        _registros.where((r) => r.data == dataHoje).toList();

    // Trabalhando se: quantidade ímpar de registros (mais entradas que saídas)
    final entradas = registrosHoje
        .where((r) => r.tipo.isEntrada)
        .length;
    final saidas = registrosHoje
        .where((r) => !r.tipo.isEntrada)
        .length;

    _trabalhando = entradas > saidas;
    notifyListeners();
  }

  Future<bool> registrarPonto() async {
    _carregando = true;
    notifyListeners();

    try {
      final result = await _pontoService.registrarPonto();
      _mensagemSnack = result.mensagem;

      if (result.sucesso) {
        await carregarRegistros();
        await _determinarStatus();

        // Notificação de confirmação
        await NotificationService.instance.mostrarNotificacaoImediata(
          result.registro!.tipo.label,
          'Registrado às ${result.registro!.hora}',
        );
      }

      _carregando = false;
      notifyListeners();
      return result.sucesso;
    } catch (e) {
      _mensagemSnack = 'Erro ao registrar ponto: $e';
      _carregando = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> editarRegistro(RegistroPonto registro) async {
    await _pontoService.editarRegistro(registro);
    await carregarRegistros();
  }

  Future<void> excluirRegistro(int id) async {
    await _pontoService.excluirRegistro(id);
    await carregarRegistros();
    await _determinarStatus();
  }

  Future<void> salvarConfiguracao(String chave, String valor) async {
    await _db.salvarConfig(chave, valor);
    await carregarConfiguracoes();

    // Reagendar notificações se necessário
    if (chave == 'lembrete_entrada' || chave == 'hora_lembrete_entrada') {
      if (_config.lembreteEntrada) {
        await NotificationService.instance
            .agendarLembreteEntrada(_config.horaLembreteEntrada);
      }
    }
    if (chave == 'lembrete_saida' || chave == 'hora_lembrete_saida') {
      if (_config.lembreteSaida) {
        await NotificationService.instance
            .agendarLembreteSaida(_config.horaLembreteSaida);
      }
    }
  }

  void limparMensagem() {
    _mensagemSnack = null;
  }

  List<RegistroPonto> get registrosHoje {
    final hoje = DateTime.now();
    final dataHoje =
        '${hoje.year}-${hoje.month.toString().padLeft(2, '0')}-${hoje.day.toString().padLeft(2, '0')}';
    return _registros.where((r) => r.data == dataHoje).toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  Map<String, List<RegistroPonto>> get registrosAgrupados {
    final Map<String, List<RegistroPonto>> agrupado = {};
    for (final r in _registros) {
      agrupado.putIfAbsent(r.data, () => []).add(r);
    }
    return Map.fromEntries(
        agrupado.entries.toList()..sort((a, b) => b.key.compareTo(a.key)));
  }
}
