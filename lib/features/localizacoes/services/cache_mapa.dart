import 'dart:io';

import 'package:flutter_map/flutter_map.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class CacheMapa {
  CacheMapa._();

  /// Identifica o app nas solicitações feitas ao OpenStreetMap.
  static const String pacote = 'com.example.atividade1';

  static const String urlTiles =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  static MapCachingProvider? _provedor;

  /// Prepara o cache privado antes que a primeira camada de tiles seja criada.
  /// Se não for possível configurá-lo, o flutter_map usa o cache padrão.
  static Future<MapCachingProvider?> preparar() async {
    if (_provedor != null) return _provedor;
    try {
      final base = await getApplicationSupportDirectory();
      final pasta = Directory(p.join(base.path, 'mapa_tiles'));
      await pasta.create(recursive: true);

      _provedor = BuiltInMapCachingProvider.getOrCreateInstance(
        cacheDirectory: pasta.path,
        maxCacheSize: 200 * 1024 * 1024,
      );
    } on FileSystemException {
      _provedor = null;
    }
    return _provedor;
  }
}
