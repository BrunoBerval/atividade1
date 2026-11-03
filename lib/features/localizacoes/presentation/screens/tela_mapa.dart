import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import '../../data/repositories/repositorio_localizacoes.dart';
import '../../models/localizacao.dart';
import '../../services/cache_mapa.dart';
import '../widgets/item_localizacao.dart';
import '../widgets/mapa_localizacoes.dart';

class TelaMapa extends StatefulWidget {
  const TelaMapa({super.key});

  @override
  State<TelaMapa> createState() => _TelaMapaState();
}

class _TelaMapaState extends State<TelaMapa> {
  final RepositorioLocalizacoes _repositorio = RepositorioLocalizacoes();
  final MapController _controlador = MapController();

  List<Localizacao> _itens = const [];
  MapCachingProvider? _cache;
  bool _carregando = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      // Configura o cache antes de montar a camada que requisita tiles.
      final cache = await CacheMapa.preparar();
      final itens = await _repositorio.consultarUltimas();
      if (!mounted) return;
      setState(() {
        _cache = cache;
        _itens = itens;
        _carregando = false;
      });
    } on RepositorioException catch (e) {
      if (!mounted) return;
      setState(() {
        _erro = e.mensagem;
        _carregando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _erro = 'Não foi possível carregar o mapa.';
        _carregando = false;
      });
    }
  }

  void _enquadrar() {
    if (_itens.isEmpty) return;
    _controlador.fitCamera(MapaLocalizacoes.enquadramento(_itens));
  }

  void _mostrarDetalhes(Localizacao localizacao) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: ItemLocalizacao(localizacao: localizacao),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final temMapa = !_carregando && _erro == null && _itens.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Mapa')),
      body: _corpo(),
      floatingActionButton: temMapa
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  heroTag: 'enquadrar',
                  tooltip: 'Enquadrar todos os pontos',
                  onPressed: _enquadrar,
                  child: const Icon(Icons.fit_screen),
                ),
                const SizedBox(height: 12),
                FloatingActionButton(
                  heroTag: 'atualizar',
                  tooltip: 'Atualizar registros',
                  onPressed: _carregar,
                  child: const Icon(Icons.refresh),
                ),
              ],
            )
          : null,
    );
  }

  Widget _corpo() {
    if (_carregando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_erro != null) {
      return _Mensagem(
        icone: Icons.error_outline,
        texto: _erro!,
        rotuloBotao: 'Tentar novamente',
        aoPressionar: _carregar,
      );
    }

    if (_itens.isEmpty) {
      return _Mensagem(
        icone: Icons.location_off,
        texto: 'Nenhuma localização registrada. Inicie a coleta e atualize.',
        rotuloBotao: 'Atualizar',
        aoPressionar: _carregar,
      );
    }

    return MapaLocalizacoes(
      localizacoes: _itens,
      controlador: _controlador,
      aoTocar: _mostrarDetalhes,
      cache: _cache,
    );
  }
}

class _Mensagem extends StatelessWidget {
  const _Mensagem({
    required this.icone,
    required this.texto,
    required this.rotuloBotao,
    required this.aoPressionar,
  });

  final IconData icone;
  final String texto;
  final String rotuloBotao;
  final VoidCallback aoPressionar;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, size: 48, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text(texto, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: aoPressionar,
              icon: const Icon(Icons.refresh),
              label: Text(rotuloBotao),
            ),
          ],
        ),
      ),
    );
  }
}
