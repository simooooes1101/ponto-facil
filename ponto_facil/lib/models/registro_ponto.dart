enum TipoPonto {
  entrada,
  saida,
  entradaExtra,
  saidaExtra,
}

extension TipoPontoExtension on TipoPonto {
  String get label {
    switch (this) {
      case TipoPonto.entrada:
        return 'Entrada';
      case TipoPonto.saida:
        return 'Saída';
      case TipoPonto.entradaExtra:
        return 'Entrada Extra';
      case TipoPonto.saidaExtra:
        return 'Saída Extra';
    }
  }

  String get codigo {
    switch (this) {
      case TipoPonto.entrada:
        return 'entrada';
      case TipoPonto.saida:
        return 'saida';
      case TipoPonto.entradaExtra:
        return 'entrada_extra';
      case TipoPonto.saidaExtra:
        return 'saida_extra';
    }
  }

  bool get isEntrada =>
      this == TipoPonto.entrada || this == TipoPonto.entradaExtra;

  static TipoPonto fromCodigo(String codigo) {
    switch (codigo) {
      case 'entrada':
        return TipoPonto.entrada;
      case 'saida':
        return TipoPonto.saida;
      case 'entrada_extra':
        return TipoPonto.entradaExtra;
      case 'saida_extra':
        return TipoPonto.saidaExtra;
      default:
        return TipoPonto.entrada;
    }
  }

  static TipoPonto determinarTipo(int quantidadeRegistrosHoje) {
    switch (quantidadeRegistrosHoje) {
      case 0:
        return TipoPonto.entrada;
      case 1:
        return TipoPonto.saida;
      case 2:
        return TipoPonto.entradaExtra;
      default:
        return TipoPonto.saidaExtra;
    }
  }
}

class RegistroPonto {
  final int? id;
  final String data;
  final String hora;
  final int timestamp;
  final TipoPonto tipo;
  final String? observacao;

  RegistroPonto({
    this.id,
    required this.data,
    required this.hora,
    required this.timestamp,
    required this.tipo,
    this.observacao,
  });

  factory RegistroPonto.agora(TipoPonto tipo) {
    final now = DateTime.now();
    return RegistroPonto(
      data: _formatarData(now),
      hora: _formatarHora(now),
      timestamp: now.millisecondsSinceEpoch,
      tipo: tipo,
    );
  }

  static String _formatarData(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  static String _formatarHora(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';

  DateTime get dateTime => DateTime.fromMillisecondsSinceEpoch(timestamp);

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'data': data,
        'hora': hora,
        'timestamp': timestamp,
        'tipo': tipo.codigo,
        'observacao': observacao,
      };

  factory RegistroPonto.fromMap(Map<String, dynamic> map) => RegistroPonto(
        id: map['id'] as int?,
        data: map['data'] as String,
        hora: map['hora'] as String,
        timestamp: map['timestamp'] as int,
        tipo: TipoPontoExtension.fromCodigo(map['tipo'] as String),
        observacao: map['observacao'] as String?,
      );

  RegistroPonto copyWith({
    int? id,
    String? data,
    String? hora,
    int? timestamp,
    TipoPonto? tipo,
    String? observacao,
  }) =>
      RegistroPonto(
        id: id ?? this.id,
        data: data ?? this.data,
        hora: hora ?? this.hora,
        timestamp: timestamp ?? this.timestamp,
        tipo: tipo ?? this.tipo,
        observacao: observacao ?? this.observacao,
      );
}
