import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/registro_ponto.dart';
import '../utils/formatters.dart';
import '../widgets/status_card.dart';
import '../widgets/registro_recente_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  late Timer _timer;
  DateTime _agora = DateTime.now();
  late AnimationController _pulseController;
  late AnimationController _buttonController;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _agora = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pulseController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  Future<void> _registrarPonto() async {
    await _buttonController.forward();
    await _buttonController.reverse();

    final provider = context.read<AppProvider>();
    final sucesso = await provider.registrarPonto();

    if (mounted && provider.mensagemSnack != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                sucesso ? Icons.check_circle_outline : Icons.error_outline,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Text(provider.mensagemSnack!),
            ],
          ),
          backgroundColor: sucesso
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 3),
        ),
      );
      provider.limparMensagem();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final colorScheme = Theme.of(context).colorScheme;
    final registrosHoje = provider.registrosHoje;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── App Bar
            SliverAppBar(
              floating: true,
              backgroundColor: colorScheme.surface,
              title: Text(
                'Ponto Fácil',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.person_outline),
                  tooltip: 'Perfil',
                  onPressed: () => _mostrarNomeUsuario(context, provider),
                ),
              ],
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 8),

                    // ── Data
                    Text(
                      Formatters.formatarDataCompleta(_agora),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 16),

                    // ── Relógio
                    _buildRelogio(context),

                    const SizedBox(height: 32),

                    // ── Status
                    StatusCard(trabalhando: provider.trabalhando),

                    const SizedBox(height: 28),

                    // ── Botão principal
                    _buildBotaoPonto(context, provider),

                    const SizedBox(height: 12),

                    // ── Tipo do próximo registro
                    _buildProximoTipo(context, registrosHoje.length),

                    const SizedBox(height: 32),

                    // ── Registros de hoje
                    if (registrosHoje.isNotEmpty) ...[
                      _buildRegistrosHoje(context, registrosHoje),
                      const SizedBox(height: 24),
                    ],

                    // ── Último registro
                    if (provider.ultimoRegistro != null)
                      RegistroRecenteCard(registro: provider.ultimoRegistro!),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRelogio(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.primaryContainer,
                colorScheme.secondaryContainer,
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary
                    .withOpacity(0.1 + _pulseController.value * 0.1),
                blurRadius: 20 + _pulseController.value * 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Text(
            Formatters.formatarHoraSegundo(_agora),
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: 60,
                  fontWeight: FontWeight.w200,
                  letterSpacing: 2,
                  color: colorScheme.onPrimaryContainer,
                ),
          ),
        );
      },
    );
  }

  Widget _buildBotaoPonto(BuildContext context, AppProvider provider) {
    final colorScheme = Theme.of(context).colorScheme;

    return ScaleTransition(
      scale: Tween<double>(begin: 1.0, end: 0.95).animate(
        CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut),
      ),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: provider.carregando ? null : _registrarPonto,
          icon: provider.carregando
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.onPrimary,
                  ),
                )
              : const Icon(Icons.fingerprint, size: 28),
          label: Text(provider.carregando
              ? 'Registrando...'
              : 'Registrar Ponto'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }

  Widget _buildProximoTipo(BuildContext context, int quantidadeHoje) {
    final tipo = TipoPontoExtension.determinarTipo(quantidadeHoje);
    final colorScheme = Theme.of(context).colorScheme;

    Color cor;
    IconData icone;
    switch (tipo) {
      case TipoPonto.entrada:
      case TipoPonto.entradaExtra:
        cor = Colors.green;
        icone = Icons.login_rounded;
        break;
      case TipoPonto.saida:
      case TipoPonto.saidaExtra:
        cor = Colors.orange;
        icone = Icons.logout_rounded;
        break;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icone, size: 16, color: cor),
        const SizedBox(width: 6),
        Text(
          'Próximo registro: ${tipo.label}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: cor,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }

  Widget _buildRegistrosHoje(
      BuildContext context, List<RegistroPonto> registros) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Registros de hoje',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Column(
            children: registros.asMap().entries.map((entry) {
              final index = entry.key;
              final r = entry.value;
              final isLast = index == registros.length - 1;

              Color tipoCor;
              IconData tipoIcon;
              if (r.tipo.isEntrada) {
                tipoCor = Colors.green;
                tipoIcon = Icons.login_rounded;
              } else {
                tipoCor = Colors.orange;
                tipoIcon = Icons.logout_rounded;
              }

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: tipoCor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(tipoIcon, size: 18, color: tipoCor),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            r.tipo.label,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Text(
                          r.hora.substring(0, 5),
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: colorScheme.primary,
                                fontFeatures: const [
                                  FontFeature.tabularFigures()
                                ],
                              ),
                        ),
                      ],
                    ),
                  ),
                  if (!isLast)
                    Divider(
                        height: 1,
                        indent: 16,
                        endIndent: 16,
                        color: colorScheme.outlineVariant),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  void _mostrarNomeUsuario(BuildContext context, AppProvider provider) {
    final controller =
        TextEditingController(text: provider.config.nomeUsuario);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Seu nome'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nome',
            hintText: 'Como você se chama?',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                provider.salvarConfiguracao(
                    'nome_usuario', controller.text.trim());
              }
              Navigator.pop(ctx);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }
}
