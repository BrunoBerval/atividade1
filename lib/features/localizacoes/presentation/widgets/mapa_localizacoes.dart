import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/localizacao.dart';
import '../../services/cache_mapa.dart';

class MapaLocalizacoes extends StatelessWidget {
  const MapaLocalizacoes({
    super.key,
    required this.localizacoes,
    required this.controlador,
    required this.aoTocar,
    this.cache,
  });

  /// Os registros estão ordenados do mais recente para o mais antigo.
  final List<Localizacao> localizacoes;
  final MapController controlador;
  final ValueChanged<Localizacao> aoTocar;
  final MapCachingProvider? cache;

  static const double _tamanhoMarcador = 40;

  static CameraFit enquadramento(List<Localizacao> itens) {
    return CameraFit.coordinates(
      coordinates: [
        for (final item in itens) LatLng(item.latitude, item.longitude),
      ],
      padding: const EdgeInsets.all(56),
      maxZoom: 17,
    );
  }

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final marcadores = <Marker>[
      // Desenha os registros antigos antes dos recentes, para destacar o último.
      for (var i = localizacoes.length - 1; i >= 0; i--)
        Marker(
          point: LatLng(localizacoes[i].latitude, localizacoes[i].longitude),
          width: _tamanhoMarcador,
          height: _tamanhoMarcador,
          alignment: Alignment.topCenter,
          child: GestureDetector(
            onTap: () => aoTocar(localizacoes[i]),
            child: Icon(
              Icons.location_on,
              size: _tamanhoMarcador,
              color: i == 0 ? Colors.red : esquema.primary,
              shadows: const [Shadow(color: Colors.black87, blurRadius: 4)],
            ),
          ),
        ),
    ];

    return FlutterMap(
      mapController: controlador,
      options: MapOptions(
        initialCameraFit: enquadramento(localizacoes),
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: CacheMapa.urlTiles,
          userAgentPackageName: CacheMapa.pacote,
          maxNativeZoom: 19,
          tileProvider: NetworkTileProvider(cachingProvider: cache),
        ),
        MarkerLayer(markers: marcadores),
        RichAttributionWidget(
          alignment: AttributionAlignment.bottomLeft,
          attributions: [
            TextSourceAttribution(
              'OpenStreetMap contributors',
              onTap: () => launchUrl(
                Uri.parse('https://www.openstreetmap.org/copyright'),
                mode: LaunchMode.externalApplication,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
