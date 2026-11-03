import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/localizacao.dart';

class ItemLocalizacao extends StatelessWidget {
  const ItemLocalizacao({super.key, required this.localizacao});

  final Localizacao localizacao;

  static final DateFormat _formatoData = DateFormat('dd/MM/yyyy HH:mm:ss');

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.place, color: tema.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  _formatoData.format(localizacao.instanteLocal),
                  style: tema.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Latitude: ${localizacao.latitude.toStringAsFixed(6)}'),
            Text('Longitude: ${localizacao.longitude.toStringAsFixed(6)}'),
            Text('Precisão: ${localizacao.precisao.toStringAsFixed(1)} m'),
          ],
        ),
      ),
    );
  }
}
