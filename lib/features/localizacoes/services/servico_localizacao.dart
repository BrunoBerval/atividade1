import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

enum ResultadoAcesso {
  concedido,
  servicoDesabilitado,
  negada,
  negadaPermanentemente,
}

class ServicoLocalizacao {
  /// Verifica o GPS e a permissão, solicitando-a quando necessário.
  Future<ResultadoAcesso> verificarAcesso() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return ResultadoAcesso.servicoDesabilitado;
    }

    var permissao = await Geolocator.checkPermission();
    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
    }

    switch (permissao) {
      case LocationPermission.denied:
      case LocationPermission.unableToDetermine:
        return ResultadoAcesso.negada;
      case LocationPermission.deniedForever:
        return ResultadoAcesso.negadaPermanentemente;
      case LocationPermission.whileInUse:
      case LocationPermission.always:
        return ResultadoAcesso.concedido;
    }
  }

  /// No Android 13+, a notificação do serviço em primeiro plano só aparece
  /// se a permissão de notificações estiver concedida.
  Future<bool> garantirNotificacoes() async {
    if (defaultTargetPlatform != TargetPlatform.android) return true;
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  /// Stream contínuo de posições (alta precisão, intervalo de 20 s no Android).
  Stream<Position> posicoes() {
    return Geolocator.getPositionStream(locationSettings: _configuracao());
  }

  Future<bool> abrirConfiguracoesApp() => Geolocator.openAppSettings();

  Future<bool> abrirConfiguracoesLocalizacao() =>
      Geolocator.openLocationSettings();

  LocationSettings _configuracao() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return AndroidSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 0,
          intervalDuration: const Duration(seconds: 20),
          foregroundNotificationConfig: const ForegroundNotificationConfig(
            notificationTitle: 'Coleta de localização ativa',
            notificationText: 'Registrando sua posição a cada 20 segundos.',
            notificationChannelName: 'Coleta de localização',
            notificationIcon: AndroidResource(
              name: 'ic_notificacao',
              defType: 'drawable',
            ),
            enableWakeLock: true,
            setOngoing: true,
          ),
        );
      case TargetPlatform.iOS:
        return AppleSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 0,
          activityType: ActivityType.other,
          pauseLocationUpdatesAutomatically: false,
          showBackgroundLocationIndicator: true,
          allowBackgroundLocationUpdates: true,
        );
      default:
        return const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 0,
        );
    }
  }
}
