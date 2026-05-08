class Configuracao {
  final String nomeUsuario;
  final bool pinAtivo;
  final String pinCodigo;
  final String tema; // 'claro', 'escuro', 'sistema'
  final bool lembreteEntrada;
  final bool lembreteSaida;
  final String horaLembreteEntrada;
  final String horaLembreteSaida;
  final int cargaHorariaDia; // em horas

  const Configuracao({
    this.nomeUsuario = 'Usuário',
    this.pinAtivo = false,
    this.pinCodigo = '',
    this.tema = 'sistema',
    this.lembreteEntrada = false,
    this.lembreteSaida = false,
    this.horaLembreteEntrada = '08:00',
    this.horaLembreteSaida = '17:00',
    this.cargaHorariaDia = 8,
  });

  factory Configuracao.fromMap(Map<String, String> map) => Configuracao(
        nomeUsuario: map['nome_usuario'] ?? 'Usuário',
        pinAtivo: map['pin_ativo'] == 'true',
        pinCodigo: map['pin_codigo'] ?? '',
        tema: map['tema'] ?? 'sistema',
        lembreteEntrada: map['lembrete_entrada'] == 'true',
        lembreteSaida: map['lembrete_saida'] == 'true',
        horaLembreteEntrada: map['hora_lembrete_entrada'] ?? '08:00',
        horaLembreteSaida: map['hora_lembrete_saida'] ?? '17:00',
        cargaHorariaDia: int.tryParse(map['carga_horaria_dia'] ?? '8') ?? 8,
      );

  Configuracao copyWith({
    String? nomeUsuario,
    bool? pinAtivo,
    String? pinCodigo,
    String? tema,
    bool? lembreteEntrada,
    bool? lembreteSaida,
    String? horaLembreteEntrada,
    String? horaLembreteSaida,
    int? cargaHorariaDia,
  }) =>
      Configuracao(
        nomeUsuario: nomeUsuario ?? this.nomeUsuario,
        pinAtivo: pinAtivo ?? this.pinAtivo,
        pinCodigo: pinCodigo ?? this.pinCodigo,
        tema: tema ?? this.tema,
        lembreteEntrada: lembreteEntrada ?? this.lembreteEntrada,
        lembreteSaida: lembreteSaida ?? this.lembreteSaida,
        horaLembreteEntrada: horaLembreteEntrada ?? this.horaLembreteEntrada,
        horaLembreteSaida: horaLembreteSaida ?? this.horaLembreteSaida,
        cargaHorariaDia: cargaHorariaDia ?? this.cargaHorariaDia,
      );
}
