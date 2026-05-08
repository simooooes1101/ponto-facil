class Formatters {
  static String formatarDataBR(String dataISO) {
    if (dataISO.isEmpty) return '';
    final partes = dataISO.split('-');
    if (partes.length != 3) return dataISO;
    return '${partes[2]}/${partes[1]}/${partes[0]}';
  }

  static String formatarDataCompleta(DateTime dt) {
    final diasSemana = [
      '', 'Segunda-feira', 'Terça-feira', 'Quarta-feira',
      'Quinta-feira', 'Sexta-feira', 'Sábado', 'Domingo'
    ];
    final meses = [
      '', 'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
      'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro'
    ];
    return '${diasSemana[dt.weekday]}, ${dt.day} de ${meses[dt.month]} de ${dt.year}';
  }

  static String formatarHora(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  static String formatarHoraSegundo(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
  }

  static String formatarDuracao(Duration d) {
    if (d == Duration.zero) return '—';
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h == 0) return '${m}min';
    return '${h}h${m.toString().padLeft(2, '0')}min';
  }

  static String formatarDuracaoCompleta(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  static String nomeMesAbreviado(int mes) {
    const meses = [
      'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
    ];
    return meses[mes - 1];
  }

  static String nomeMes(int mes) {
    const meses = [
      'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
    ];
    return meses[mes - 1];
  }

  static String diaSemanaAbreviado(DateTime dt) {
    const dias = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    return dias[dt.weekday - 1];
  }

  static String formatarDataIso(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }
}
