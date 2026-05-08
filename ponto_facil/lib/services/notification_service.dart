import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService instance = NotificationService._init();
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  NotificationService._init();

  Future<void> inicializar() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Sao_Paulo'));

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Criar canal Android
    const channel = AndroidNotificationChannel(
      'ponto_facil_channel',
      'Ponto Fácil',
      description: 'Lembretes de registro de ponto',
      importance: Importance.high,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  void _onNotificationTap(NotificationResponse response) {
    // Navegar para tela principal ao tocar na notificação
  }

  Future<void> agendarLembreteEntrada(String horaStr) async {
    await _plugin.cancel(1);
    final partes = horaStr.split(':');
    final hora = int.parse(partes[0]);
    final minuto = int.parse(partes[1]);

    await _plugin.zonedSchedule(
      1,
      'Hora de registrar a entrada! ☀️',
      'Toque para abrir o Ponto Fácil',
      _proximoHorario(hora, minuto),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'ponto_facil_channel',
          'Ponto Fácil',
          channelDescription: 'Lembretes de registro de ponto',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> agendarLembreteSaida(String horaStr) async {
    await _plugin.cancel(2);
    final partes = horaStr.split(':');
    final hora = int.parse(partes[0]);
    final minuto = int.parse(partes[1]);

    await _plugin.zonedSchedule(
      2,
      'Hora de registrar a saída! 🌙',
      'Não esqueça de bater o ponto',
      _proximoHorario(hora, minuto),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'ponto_facil_channel',
          'Ponto Fácil',
          channelDescription: 'Lembretes de registro de ponto',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelarLembretes() async {
    await _plugin.cancelAll();
  }

  Future<void> mostrarNotificacaoImediata(String titulo, String corpo) async {
    await _plugin.show(
      0,
      titulo,
      corpo,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'ponto_facil_channel',
          'Ponto Fácil',
          importance: Importance.defaultImportance,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }

  tz.TZDateTime _proximoHorario(int hora, int minuto) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, hora, minuto);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
