import 'package:flutter/material.dart';

class StatusCard extends StatelessWidget {
  final bool trabalhando;

  const StatusCard({super.key, required this.trabalhando});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final cor = trabalhando ? Colors.green : colorScheme.onSurfaceVariant;
    final corFundo = trabalhando
        ? Colors.green.withOpacity(0.12)
        : colorScheme.surfaceContainerLow;
    final corBorda =
        trabalhando ? Colors.green.withOpacity(0.3) : colorScheme.outlineVariant;
    final label = trabalhando ? 'Trabalhando' : 'Fora do expediente';
    final icone = trabalhando
        ? Icons.work_rounded
        : Icons.work_off_outlined;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: corFundo,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: corBorda),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trabalhando)
            _PulseDot(cor: cor),
          if (!trabalhando)
            Icon(icone, size: 18, color: cor),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: cor,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _PulseDot extends StatefulWidget {
  final Color cor;
  const _PulseDot({required this.cor});

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) => Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: widget.cor.withOpacity(0.5 + _controller.value * 0.5),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: widget.cor.withOpacity(_controller.value * 0.5),
              blurRadius: 6 + _controller.value * 4,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }
}
