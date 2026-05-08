import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/app_provider.dart';
import '../models/registro_ponto.dart';
import '../services/ponto_service.dart';
import '../utils/formatters.dart';

class RelatoriosScreen extends StatefulWidget {
  const RelatoriosScreen({super.key});

  @override
  State<RelatoriosScreen> createState() => _RelatoriosScreenState();
}

class _RelatoriosScreenState extends State<RelatoriosScreen>
    with SingleTickerProviderStateMixin {
  final PontoService _pontoService = PontoService();
  late TabController _tabController;
  ResumoSemana? _resumoSemana;
  ResumoMes? _resumoMes;
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _carregarDados();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _carregarDados() async {
    setState(() => _carregando = true);
    final now = DateTime.now();
    _resumoSemana = await _pontoService.calcularResumoSemana(now);
    _resumoMes = await _pontoService.calcularResumoMes(now.year, now.month);
    if (mounted) setState(() => _carregando = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatórios'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Esta semana'),
            Tab(text: 'Este mês'),
          ],
        ),
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildSemanaTab(),
                _buildMesTab(),
              ],
            ),
    );
  }

  Widget _buildSemanaTab() {
    if (_resumoSemana == null) return const SizedBox();
    final colorScheme = Theme.of(context).colorScheme;
    final resumo = _resumoSemana!;
    final cargaHoraria = context.read<AppProvider>().config.cargaHorariaDia;

    return RefreshIndicator(
      onRefresh: _carregarDados,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Cards de resumo
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  context,
                  icon: Icons.schedule_rounded,
                  label: 'Total semana',
                  valor: Formatters.formatarDuracao(resumo.totalHoras),
                  cor: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  context,
                  icon: Icons.calendar_today_rounded,
                  label: 'Dias trabalhados',
                  valor: '${resumo.diasTrabalhados}',
                  cor: colorScheme.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Saldo de horas
          _buildSaldoCard(
              context, resumo.totalHoras, resumo.diasTrabalhados, cargaHoraria),

          const SizedBox(height: 20),

          // Gráfico por dia da semana
          if (resumo.registrosPorDia.isNotEmpty)
            _buildGraficoSemana(context, resumo),

          const SizedBox(height: 20),

          // Detalhe por dia
          Text(
            'Detalhe por dia',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          ...resumo.registrosPorDia.entries.map(
              (e) => _buildDiaResumo(context, e.key, e.value, cargaHoraria)),
        ],
      ),
    );
  }

  Widget _buildMesTab() {
    if (_resumoMes == null) return const SizedBox();
    final colorScheme = Theme.of(context).colorScheme;
    final resumo = _resumoMes!;
    final now = DateTime.now();
    final cargaHoraria = context.read<AppProvider>().config.cargaHorariaDia;

    return RefreshIndicator(
      onRefresh: _carregarDados,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '${Formatters.nomeMes(now.month)} ${now.year}',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.primary,
                ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  context,
                  icon: Icons.schedule_rounded,
                  label: 'Total mês',
                  valor: Formatters.formatarDuracao(resumo.totalHoras),
                  cor: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  context,
                  icon: Icons.calendar_month_rounded,
                  label: 'Dias trabalhados',
                  valor: '${resumo.diasTrabalhados}',
                  cor: colorScheme.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          _buildSaldoCard(context, resumo.totalHoras,
              resumo.diasTrabalhados, cargaHoraria),

          const SizedBox(height: 20),

          // Gráfico mensal
          if (resumo.registrosPorDia.isNotEmpty)
            _buildGraficoMes(context, resumo, now.year, now.month),
        ],
      ),
    );
  }

  Widget _buildMetricCard(BuildContext context,
      {required IconData icon,
      required String label,
      required String valor,
      required Color cor}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: cor, size: 24),
          const SizedBox(height: 8),
          Text(
            valor,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: cor,
                ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaldoCard(BuildContext context, Duration totalHoras,
      int diasTrabalhados, int cargaHorariaDia) {
    final colorScheme = Theme.of(context).colorScheme;
    final esperado = Duration(hours: diasTrabalhados * cargaHorariaDia);
    final saldo = totalHoras - esperado;
    final positivo = saldo >= Duration.zero;
    final cor = positivo ? Colors.green : colorScheme.error;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            positivo
                ? Icons.trending_up_rounded
                : Icons.trending_down_rounded,
            color: cor,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Saldo de horas',
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
                Text(
                  '${positivo ? '+' : ''}${Formatters.formatarDuracao(saldo.abs())}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: cor,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGraficoSemana(BuildContext context, ResumoSemana resumo) {
    final colorScheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final inicioSemana =
        now.subtract(Duration(days: now.weekday - 1));

    final barGroups = <BarChartGroupData>[];

    for (int i = 0; i < 7; i++) {
      final dia = inicioSemana.add(Duration(days: i));
      final dataStr = Formatters.formatarDataIso(dia);
      final registros = resumo.registrosPorDia[dataStr] ?? [];
      Duration horas = Duration.zero;
      if (registros.length >= 2) {
        final sorted = List<RegistroPonto>.from(registros)
          ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
        horas = sorted[1].dateTime.difference(sorted[0].dateTime);
        if (sorted.length >= 4) {
          horas += sorted[3].dateTime.difference(sorted[2].dateTime);
        }
      }
      final horasDouble = horas.inMinutes / 60;

      barGroups.add(BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: horasDouble,
            color: i == now.weekday - 1
                ? colorScheme.primary
                : colorScheme.primaryContainer,
            width: 28,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          ),
        ],
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Horas por dia',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              maxY: 12,
              barGroups: barGroups,
              gridData: FlGridData(
                horizontalInterval: 4,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (v) => FlLine(
                  color: colorScheme.outlineVariant,
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (v, _) {
                      const dias = ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'];
                      return Text(
                        dias[v.toInt()],
                        style: Theme.of(context).textTheme.labelSmall,
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    interval: 4,
                    getTitlesWidget: (v, _) => Text(
                      '${v.toInt()}h',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                ),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildGraficoMes(BuildContext context, ResumoMes resumo, int ano, int mes) {
    final colorScheme = Theme.of(context).colorScheme;
    final diasNoMes = DateTime(ano, mes + 1, 0).day;

    final spots = <FlSpot>[];
    double acumulado = 0;

    for (int dia = 1; dia <= diasNoMes; dia++) {
      final mesStr = mes.toString().padLeft(2, '0');
      final diaStr = dia.toString().padLeft(2, '0');
      final dataStr = '$ano-$mesStr-$diaStr';
      final registros = resumo.registrosPorDia[dataStr] ?? [];

      Duration horas = Duration.zero;
      if (registros.length >= 2) {
        final sorted = List<RegistroPonto>.from(registros)
          ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
        horas = sorted[1].dateTime.difference(sorted[0].dateTime);
        if (sorted.length >= 4) {
          horas += sorted[3].dateTime.difference(sorted[2].dateTime);
        }
      }
      acumulado += horas.inMinutes / 60;
      spots.add(FlSpot(dia.toDouble(), acumulado));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Horas acumuladas no mês',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: colorScheme.primary,
                  barWidth: 2.5,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: colorScheme.primary.withOpacity(0.1),
                  ),
                ),
              ],
              gridData: FlGridData(
                drawVerticalLine: false,
                getDrawingHorizontalLine: (v) => FlLine(
                  color: colorScheme.outlineVariant,
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 7,
                    getTitlesWidget: (v, _) => Text(
                      '${v.toInt()}',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 36,
                    getTitlesWidget: (v, _) => Text(
                      '${v.toInt()}h',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                ),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDiaResumo(BuildContext context, String data,
      List<RegistroPonto> registros, int cargaHorariaDia) {
    final colorScheme = Theme.of(context).colorScheme;
    final sorted = List<RegistroPonto>.from(registros)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    Duration horas = Duration.zero;
    if (sorted.length >= 2) {
      horas = sorted[1].dateTime.difference(sorted[0].dateTime);
    }
    if (sorted.length >= 4) {
      horas += sorted[3].dateTime.difference(sorted[2].dateTime);
    }

    final esperado = Duration(hours: cargaHorariaDia);
    final saldo = horas - esperado;
    final positivo = saldo >= Duration.zero;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              Formatters.formatarDataBR(data),
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            Formatters.formatarDuracao(horas),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.primary,
                ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color:
                  (positivo ? Colors.green : colorScheme.error).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${positivo ? '+' : ''}${Formatters.formatarDuracao(saldo.abs())}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: positivo ? Colors.green : colorScheme.error,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
