import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/medicacao_model.dart';

class NotificacaoService {
  NotificacaoService._();

  static final NotificacaoService instance = NotificacaoService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Sao_Paulo'));

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(settings);
    await _solicitarPermissaoSeNecessario();
    _initialized = true;
  }

  Future<void> agendarLembreteMedicacao(MedicacaoModel medicacao) async {
    await init();
    await cancelarLembreteMedicacao(medicacao);

    if (!medicacao.lembreteAtivo || medicacao.horarioLembrete == null) {
      return;
    }

    final horario = medicacao.horarioLembrete!;
    final partes = horario.split(':');
    if (partes.length != 2) return;

    final hour = int.tryParse(partes[0]);
    final minute = int.tryParse(partes[1]);
    if (hour == null || minute == null) return;

    final id = _gerarIdNotificacao(medicacao);
    final agora = tz.TZDateTime.now(tz.local);
    var primeiraData = tz.TZDateTime(
      tz.local,
      agora.year,
      agora.month,
      agora.day,
      hour,
      minute,
    );

    if (!primeiraData.isAfter(agora)) {
      primeiraData = primeiraData.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id,
      'Hora da sua medicação',
      'Lembrete do remédio ${medicacao.nome}',
      primeiraData,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'medicacao_lembretes',
          'Lembretes de medicação',
          channelDescription: 'Lembretes diários dos remédios cadastrados.',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelarLembreteMedicacao(MedicacaoModel medicacao) async {
    await init();
    await _plugin.cancel(_gerarIdNotificacao(medicacao));
  }

  int _gerarIdNotificacao(MedicacaoModel medicacao) {
    final base = medicacao.id.isNotEmpty
        ? medicacao.id
        : '${medicacao.userId}-${medicacao.nome}-${medicacao.criadoEm.millisecondsSinceEpoch}';
    return base.hashCode.abs();
  }

  Future<void> _solicitarPermissaoSeNecessario() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();
    await android?.requestExactAlarmsPermission();
  }
}
