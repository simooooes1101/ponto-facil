import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import '../providers/app_provider.dart';

class PinScreen extends StatefulWidget {
  final AppProvider provider;
  final VoidCallback onDesbloqueado;

  const PinScreen(
      {super.key, required this.provider, required this.onDesbloqueado});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  int _tentativas = 0;
  bool _erro = false;

  void _verificarPin(String pin) {
    if (pin == widget.provider.config.pinCodigo) {
      widget.onDesbloqueado();
    } else {
      setState(() {
        _tentativas++;
        _erro = true;
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) setState(() => _erro = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lock_outline_rounded,
                    size: 48,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Ponto Fácil',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colorScheme.primary,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Digite seu PIN para continuar',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 40),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: Pinput(
                    length: 4,
                    obscureText: true,
                    autofocus: true,
                    onCompleted: _verificarPin,
                    defaultPinTheme: PinTheme(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: _erro
                            ? colorScheme.errorContainer
                            : colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _erro
                              ? colorScheme.error
                              : colorScheme.outlineVariant,
                          width: 2,
                        ),
                      ),
                      textStyle: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
                if (_erro) ...[
                  const SizedBox(height: 16),
                  Text(
                    'PIN incorreto${_tentativas >= 3 ? ' — $_tentativas tentativas' : ''}',
                    style: TextStyle(
                      color: colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
