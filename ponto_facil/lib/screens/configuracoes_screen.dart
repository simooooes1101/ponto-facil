import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pinput/pinput.dart';
import '../providers/app_provider.dart';

class ConfiguracoesScreen extends StatelessWidget {
  const ConfiguracoesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final config = provider.config;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Perfil
          _buildSecao(context, 'Perfil'),
          _buildTile(
            context,
            icon: Icons.person_outline,
            titulo: 'Nome de usuário',
            subtitulo: config.nomeUsuario,
            onTap: () => _editarNome(context, provider),
          ),
          _buildTile(
            context,
            icon: Icons.schedule_rounded,
            titulo: 'Carga horária diária',
            subtitulo: '${config.cargaHorariaDia} horas',
            onTap: () => _editarCargaHoraria(context, provider, config.cargaHorariaDia),
          ),

          const SizedBox(height: 16),

          // ── Aparência
          _buildSecao(context, 'Aparência'),
          _buildTileSwitch(
            context,
            icon: Icons.dark_mode_outlined,
            titulo: 'Tema',
            subtitulo: _labelTema(config.tema),
            onTap: () => _selecionarTema(context, provider, config.tema),
          ),

          const SizedBox(height: 16),

          // ── Segurança
          _buildSecao(context, 'Segurança'),
          _buildTileToggle(
            context,
            icon: Icons.lock_outline,
            titulo: 'PIN de acesso',
            subtitulo: config.pinAtivo ? 'Ativado' : 'Desativado',
            valor: config.pinAtivo,
            onChanged: (v) => _togglePin(context, provider, v),
          ),
          if (config.pinAtivo)
            _buildTile(
              context,
              icon: Icons.pin_outlined,
              titulo: 'Alterar PIN',
              subtitulo: 'Definir novo código de 4 dígitos',
              onTap: () => _alterarPin(context, provider),
            ),

          const SizedBox(height: 16),

          // ── Notificações
          _buildSecao(context, 'Notificações'),
          _buildTileToggle(
            context,
            icon: Icons.notifications_outlined,
            titulo: 'Lembrete de entrada',
            subtitulo: config.lembreteEntrada
                ? 'Às ${config.horaLembreteEntrada}'
                : 'Desativado',
            valor: config.lembreteEntrada,
            onChanged: (v) => provider.salvarConfiguracao(
                'lembrete_entrada', v.toString()),
          ),
          if (config.lembreteEntrada)
            _buildTile(
              context,
              icon: Icons.access_time,
              titulo: 'Horário de entrada',
              subtitulo: config.horaLembreteEntrada,
              onTap: () => _editarHorarioNotificacao(
                  context, provider, 'entrada', config.horaLembreteEntrada),
            ),
          _buildTileToggle(
            context,
            icon: Icons.notifications_off_outlined,
            titulo: 'Lembrete de saída',
            subtitulo: config.lembreteSaida
                ? 'Às ${config.horaLembreteSaida}'
                : 'Desativado',
            valor: config.lembreteSaida,
            onChanged: (v) => provider.salvarConfiguracao(
                'lembrete_saida', v.toString()),
          ),
          if (config.lembreteSaida)
            _buildTile(
              context,
              icon: Icons.access_time,
              titulo: 'Horário de saída',
              subtitulo: config.horaLembreteSaida,
              onTap: () => _editarHorarioNotificacao(
                  context, provider, 'saida', config.horaLembreteSaida),
            ),

          const SizedBox(height: 32),

          // ── Versão
          Center(
            child: Text(
              'Ponto Fácil v1.0.0\nDesenvolvido com Flutter',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.outlineVariant,
                  ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSecao(BuildContext context, String titulo) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        titulo,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }

  Widget _buildTile(BuildContext context,
      {required IconData icon,
      required String titulo,
      required String subtitulo,
      required VoidCallback onTap}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child:
              Icon(icon, size: 20, color: colorScheme.onPrimaryContainer),
        ),
        title: Text(titulo,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitulo),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildTileSwitch(BuildContext context,
      {required IconData icon,
      required String titulo,
      required String subtitulo,
      required VoidCallback onTap}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: colorScheme.onPrimaryContainer),
        ),
        title: Text(titulo,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitulo),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildTileToggle(BuildContext context,
      {required IconData icon,
      required String titulo,
      required String subtitulo,
      required bool valor,
      required ValueChanged<bool> onChanged}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: colorScheme.onPrimaryContainer),
        ),
        title: Text(titulo,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitulo),
        trailing: Switch(value: valor, onChanged: onChanged),
      ),
    );
  }

  String _labelTema(String tema) {
    switch (tema) {
      case 'claro':
        return 'Claro';
      case 'escuro':
        return 'Escuro';
      default:
        return 'Automático (sistema)';
    }
  }

  void _editarNome(BuildContext context, AppProvider provider) {
    final ctrl = TextEditingController(text: provider.config.nomeUsuario);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nome de usuário'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Nome'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                provider.salvarConfiguracao(
                    'nome_usuario', ctrl.text.trim());
              }
              Navigator.pop(ctx);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _editarCargaHoraria(
      BuildContext context, AppProvider provider, int atual) {
    int selecionado = atual;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Carga horária diária'),
        content: StatefulBuilder(
          builder: (ctx, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$selecionado horas',
                  style: Theme.of(context).textTheme.headlineMedium),
              Slider(
                value: selecionado.toDouble(),
                min: 1,
                max: 12,
                divisions: 11,
                label: '$selecionado h',
                onChanged: (v) => setState(() => selecionado = v.round()),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              provider.salvarConfiguracao(
                  'carga_horaria_dia', selecionado.toString());
              Navigator.pop(ctx);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _selecionarTema(
      BuildContext context, AppProvider provider, String atual) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Tema'),
        children: [
          for (final (codigo, label) in [
            ('sistema', 'Automático (sistema)'),
            ('claro', 'Claro'),
            ('escuro', 'Escuro'),
          ])
            RadioListTile<String>(
              title: Text(label),
              value: codigo,
              groupValue: atual,
              onChanged: (v) {
                if (v != null) provider.salvarConfiguracao('tema', v);
                Navigator.pop(ctx);
              },
            ),
        ],
      ),
    );
  }

  void _togglePin(
      BuildContext context, AppProvider provider, bool ativar) {
    if (ativar) {
      _alterarPin(context, provider, ativandoNovo: true);
    } else {
      provider.salvarConfiguracao('pin_ativo', 'false');
    }
  }

  void _alterarPin(BuildContext context, AppProvider provider,
      {bool ativandoNovo = false}) {
    String? novoPinTemp;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title:
            Text(ativandoNovo ? 'Definir PIN' : 'Alterar PIN'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(ativandoNovo
                ? 'Digite um PIN de 4 dígitos'
                : 'Digite o novo PIN'),
            const SizedBox(height: 16),
            Pinput(
              length: 4,
              obscureText: true,
              autofocus: true,
              onCompleted: (pin) {
                if (novoPinTemp == null) {
                  novoPinTemp = pin;
                } else if (novoPinTemp == pin) {
                  provider.salvarConfiguracao('pin_codigo', pin);
                  provider.salvarConfiguracao('pin_ativo', 'true');
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('PIN configurado!')),
                  );
                } else {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('PINs não coincidem')),
                  );
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
        ],
      ),
    );
  }

  void _editarHorarioNotificacao(BuildContext context, AppProvider provider,
      String tipo, String horaAtual) async {
    final partes = horaAtual.split(':');
    final inicial = TimeOfDay(
        hour: int.parse(partes[0]), minute: int.parse(partes[1]));

    final selecionado = await showTimePicker(
      context: context,
      initialTime: inicial,
    );

    if (selecionado != null) {
      final novaHora =
          '${selecionado.hour.toString().padLeft(2, '0')}:${selecionado.minute.toString().padLeft(2, '0')}';
      provider.salvarConfiguracao(
          'hora_lembrete_$tipo', novaHora);
    }
  }
}
