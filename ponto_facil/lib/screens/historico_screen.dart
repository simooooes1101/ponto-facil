import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/registro_ponto.dart';
import '../utils/formatters.dart';
import '../services/export_service.dart';

class HistoricoScreen extends StatefulWidget {
  const HistoricoScreen({super.key});

  @override
  State<HistoricoScreen> createState() => _HistoricoScreenState();
}

class _HistoricoScreenState extends State<HistoricoScreen> {
  final ExportService _exportService = ExportService();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final agrupados = provider.registrosAgrupados;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.download_outlined),
            tooltip: 'Exportar',
            onSelected: (v) => _exportar(context, provider, v),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'pdf', child: Text('Exportar PDF')),
              PopupMenuItem(value: 'csv', child: Text('Exportar CSV')),
            ],
          ),
        ],
      ),
      body: agrupados.isEmpty
          ? _buildVazio(context)
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: agrupados.length,
              itemBuilder: (context, index) {
                final data = agrupados.keys.elementAt(index);
                final registros = agrupados[data]!
                  ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
                return _buildDiaCard(context, data, registros, provider);
              },
            ),
    );
  }

  Widget _buildVazio(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded,
              size: 72, color: colorScheme.outlineVariant),
          const SizedBox(height: 16),
          Text(
            'Nenhum registro ainda',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Registre seu primeiro ponto\nna tela inicial',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.outlineVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiaCard(BuildContext context, String data,
      List<RegistroPonto> registros, AppProvider provider) {
    final colorScheme = Theme.of(context).colorScheme;
    final hoje = Formatters.formatarDataIso(DateTime.now());
    final ontem = Formatters.formatarDataIso(
        DateTime.now().subtract(const Duration(days: 1)));

    String labelDia = Formatters.formatarDataBR(data);
    if (data == hoje) labelDia = 'Hoje — $labelDia';
    if (data == ontem) labelDia = 'Ontem — $labelDia';

    // Calcular horas trabalhadas
    Duration horasTrabalhadas = Duration.zero;
    if (registros.length >= 2) {
      horasTrabalhadas =
          registros[1].dateTime.difference(registros[0].dateTime);
    }
    if (registros.length >= 4) {
      horasTrabalhadas +=
          registros[3].dateTime.difference(registros[2].dateTime);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header do dia
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  labelDia,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.primary,
                      ),
                ),
                if (horasTrabalhadas != Duration.zero)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      Formatters.formatarDuracao(horasTrabalhadas),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Registros do dia
            ...registros.asMap().entries.map((entry) {
              final r = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildRegistroItem(context, r, provider),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildRegistroItem(
      BuildContext context, RegistroPonto r, AppProvider provider) {
    final colorScheme = Theme.of(context).colorScheme;
    final isEntrada = r.tipo.isEntrada;
    final cor = isEntrada ? Colors.green : Colors.orange;
    final icone = isEntrada ? Icons.login_rounded : Icons.logout_rounded;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: cor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icone, size: 16, color: cor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                r.tipo.label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              if (r.observacao != null && r.observacao!.isNotEmpty)
                Text(
                  r.observacao!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
            ],
          ),
        ),
        Text(
          r.hora.substring(0, 5),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
        ),
        const SizedBox(width: 4),
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, size: 18, color: colorScheme.outline),
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'editar', child: Text('Editar')),
            PopupMenuItem(value: 'excluir', child: Text('Excluir')),
          ],
          onSelected: (v) {
            if (v == 'editar') _editarRegistro(context, r, provider);
            if (v == 'excluir') _confirmarExclusao(context, r, provider);
          },
        ),
      ],
    );
  }

  void _editarRegistro(
      BuildContext context, RegistroPonto r, AppProvider provider) async {
    TimeOfDay? horaSelecionada = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(r.dateTime),
      helpText: 'Editar horário do registro',
    );

    if (horaSelecionada == null || !mounted) return;

    final dt = r.dateTime;
    final novoTimestamp = DateTime(
      dt.year, dt.month, dt.day,
      horaSelecionada.hour, horaSelecionada.minute,
    ).millisecondsSinceEpoch;

    final hora =
        '${horaSelecionada.hour.toString().padLeft(2, '0')}:${horaSelecionada.minute.toString().padLeft(2, '0')}:00';

    final atualizado = r.copyWith(hora: hora, timestamp: novoTimestamp);
    await provider.editarRegistro(atualizado);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registro atualizado!')),
      );
    }
  }

  void _confirmarExclusao(
      BuildContext context, RegistroPonto r, AppProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir registro'),
        content: Text(
            'Deseja excluir o registro de ${r.tipo.label} às ${r.hora.substring(0, 5)}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await provider.excluirRegistro(r.id!);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Registro excluído')),
                );
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportar(
      BuildContext context, AppProvider provider, String formato) async {
    try {
      String caminho;
      if (formato == 'pdf') {
        caminho = await _exportService.exportarPDF(
            provider.registros, provider.config.nomeUsuario);
      } else {
        caminho = await _exportService.exportarCSV(provider.registros);
      }
      await _exportService.compartilhar(caminho);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao exportar: $e')),
        );
      }
    }
  }
}
