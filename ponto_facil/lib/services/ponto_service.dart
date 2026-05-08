import '../database/database_helper.dart';
import '../models/registro_ponto.dart';

class PontoService {
  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<RegistrarPontoResult> registrarPonto() async {
    final now = DateTime.now();

    // Verificar duplicata no mesmo minuto
    final duplicata = await _db.existeRegistroNoMinuto(now);
    if (duplicata) {
      return RegistrarPontoResult(
        sucesso: false,
        mensagem: 'Já existe um registro neste minuto.',
      );
    }

    // Buscar registros do dia
    final dataHoje = _formatarData(now);
    final registrosHoje = await _db.buscarRegistrosPorData(dataHoje);

    // Determinar tipo
    final tipo = TipoPontoExtension.determinarTipo(registrosHoje.length);

    // Criar e salvar registro
    final registro = RegistroPonto.agora(tipo);
    final id = await _db.inserirRegistro(registro);

    return RegistrarPontoResult(
      sucesso: true,
      mensagem: '${tipo.label} registrada com sucesso!',
      registro: registro.copyWith(id: id),
    );
  }

  Future<List<RegistroPonto>> buscarRegistrosDia(DateTime data) async {
    final dataStr = _formatarData(data);
    return await _db.buscarRegistrosPorData(dataStr);
  }

  Future<List<RegistroPonto>> buscarTodos() async {
    return await _db.buscarTodosRegistros();
  }

  Future<RegistroPonto?> ultimoRegistro() async {
    return await _db.buscarUltimoRegistro();
  }

  Future<void> editarRegistro(RegistroPonto registro) async {
    await _db.atualizarRegistro(registro);
  }

  Future<void> excluirRegistro(int id) async {
    await _db.excluirRegistro(id);
  }

  // ── CÁLCULOS ──────────────────────────────────────────────

  /// Calcula horas trabalhadas para uma lista de registros do mesmo dia.
  Duration calcularHorasTrabalhadasDia(List<RegistroPonto> registros) {
    if (registros.length < 2) return Duration.zero;

    final sorted = List<RegistroPonto>.from(registros)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    Duration total = Duration.zero;

    // Par 1: entrada[0] → saida[1]
    if (sorted.length >= 2) {
      final diff = sorted[1].dateTime.difference(sorted[0].dateTime);
      if (diff.isNegative == false) total += diff;
    }

    // Par 2: entrada_extra[2] → saida_extra[3]
    if (sorted.length >= 4) {
      final diff = sorted[3].dateTime.difference(sorted[2].dateTime);
      if (diff.isNegative == false) total += diff;
    }

    return total;
  }

  Future<ResumoSemana> calcularResumoSemana(DateTime referencia) async {
    final inicioSemana =
        referencia.subtract(Duration(days: referencia.weekday - 1));
    final fimSemana =
        inicioSemana.add(const Duration(days: 6));

    final registros = await _db.buscarRegistrosPorPeriodo(
      _formatarData(inicioSemana),
      _formatarData(fimSemana),
    );

    final porDia = _agruparPorDia(registros);
    Duration totalSemana = Duration.zero;

    for (final dia in porDia.values) {
      totalSemana += calcularHorasTrabalhadasDia(dia);
    }

    return ResumoSemana(
      totalHoras: totalSemana,
      diasTrabalhados: porDia.keys.length,
      registrosPorDia: porDia,
    );
  }

  Future<ResumoMes> calcularResumoMes(int ano, int mes) async {
    final mesStr = mes.toString().padLeft(2, '0');
    final inicioMes = '$ano-$mesStr-01';
    final ultimoDia = DateTime(ano, mes + 1, 0).day;
    final fimMes = '$ano-$mesStr-${ultimoDia.toString().padLeft(2, '0')}';

    final registros = await _db.buscarRegistrosPorPeriodo(inicioMes, fimMes);
    final porDia = _agruparPorDia(registros);

    Duration totalMes = Duration.zero;
    for (final dia in porDia.values) {
      totalMes += calcularHorasTrabalhadasDia(dia);
    }

    return ResumoMes(
      totalHoras: totalMes,
      diasTrabalhados: porDia.keys.length,
      registrosPorDia: porDia,
    );
  }

  Map<String, List<RegistroPonto>> _agruparPorDia(
      List<RegistroPonto> registros) {
    final Map<String, List<RegistroPonto>> agrupado = {};
    for (final r in registros) {
      agrupado.putIfAbsent(r.data, () => []).add(r);
    }
    return agrupado;
  }

  String _formatarData(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}

class RegistrarPontoResult {
  final bool sucesso;
  final String mensagem;
  final RegistroPonto? registro;

  RegistrarPontoResult({
    required this.sucesso,
    required this.mensagem,
    this.registro,
  });
}

class ResumoSemana {
  final Duration totalHoras;
  final int diasTrabalhados;
  final Map<String, List<RegistroPonto>> registrosPorDia;

  ResumoSemana({
    required this.totalHoras,
    required this.diasTrabalhados,
    required this.registrosPorDia,
  });
}

class ResumoMes {
  final Duration totalHoras;
  final int diasTrabalhados;
  final Map<String, List<RegistroPonto>> registrosPorDia;

  ResumoMes({
    required this.totalHoras,
    required this.diasTrabalhados,
    required this.registrosPorDia,
  });
}
