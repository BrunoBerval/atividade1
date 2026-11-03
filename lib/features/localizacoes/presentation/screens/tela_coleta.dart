import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../tema_app.dart';
import '../../data/repositories/repositorio_localizacoes.dart';
import '../../models/localizacao.dart';
import '../../services/servico_localizacao.dart';
import '../widgets/item_localizacao.dart';
import 'tela_localizacoes.dart';
import 'tela_mapa.dart';

class TelaColeta extends StatefulWidget {
  const TelaColeta({super.key});

  @override
  State<TelaColeta> createState() => _TelaColetaState();
}

class _TelaColetaState extends State<TelaColeta> {
  final ServicoLocalizacao _servico = ServicoLocalizacao();
  final RepositorioLocalizacoes _repositorio = RepositorioLocalizacoes();

  StreamSubscription<Position>? _assinatura;

  /// Fila que serializa as gravações, evitando escritas sobrepostas.
  Future<void> _filaGravacao = Future.value();

  bool _iniciando = false;
  int _gravados = 0;
  Localizacao? _ultima;

  bool get _coletando => _assinatura != null;

  @override
  void dispose() {
    _assinatura?.cancel();
    super.dispose();
  }

  Future<void> _iniciar() async {
    if (_coletando || _iniciando) return;
    setState(() => _iniciando = true);

    try {
      final acesso = await _servico.verificarAcesso();
      if (!mounted) return;

      if (acesso != ResultadoAcesso.concedido) {
        await _orientar(acesso);
        return;
      }

      final notificacoes = await _servico.garantirNotificacoes();
      if (!mounted) return;
      if (!notificacoes) {
        _mensagem(
          'Sem permissão de notificações, o aviso da coleta não ficará '
          'visível. Você pode habilitá-la nas configurações.',
        );
      }

      setState(() {
        _gravados = 0;
        _ultima = null;
        _assinatura = _servico.posicoes().listen(
          _aoReceber,
          onError: _aoErro,
          cancelOnError: false,
        );
      });
    } catch (_) {
      if (!mounted) return;
      _mensagem('Não foi possível iniciar a coleta.');
    } finally {
      if (mounted) setState(() => _iniciando = false);
    }
  }

  Future<void> _parar() async {
    final assinatura = _assinatura;
    if (assinatura == null) return;
    setState(() => _assinatura = null);
    await assinatura.cancel();
  }

  void _aoReceber(Position posicao) {
    final localizacao = Localizacao(
      latitude: posicao.latitude,
      longitude: posicao.longitude,
      precisao: posicao.accuracy,
      instante: posicao.timestamp.toUtc(),
    );
    _filaGravacao = _filaGravacao.then((_) => _salvar(localizacao));
  }

  Future<void> _salvar(Localizacao localizacao) async {
    try {
      await _repositorio.inserir(localizacao);
      if (!mounted) return;
      setState(() {
        _gravados++;
        _ultima = localizacao;
      });
    } catch (e) {
      if (!mounted) return;
      _mensagem(
        e is RepositorioException
            ? e.mensagem
            : 'Falha ao salvar a localização.',
      );
    }
  }

  void _aoErro(Object erro) {
    if (!mounted) return;
    unawaited(_parar());
    _mensagem(
      erro is LocationServiceDisabledException
          ? 'O GPS foi desativado. A coleta foi interrompida.'
          : 'Erro na coleta de localização. A coleta foi interrompida.',
    );
  }

  Future<void> _orientar(ResultadoAcesso acesso) async {
    switch (acesso) {
      case ResultadoAcesso.servicoDesabilitado:
        await _dialogoOrientacao(
          titulo: 'GPS desativado',
          texto: 'Ative o serviço de localização do aparelho para coletar.',
          rotuloAcao: 'Abrir configurações',
          acao: _servico.abrirConfiguracoesLocalizacao,
        );
      case ResultadoAcesso.negada:
        await _dialogoOrientacao(
          titulo: 'Permissão necessária',
          texto:
              'A permissão de localização é necessária para coletar posições. '
              'Toque em Iniciar coleta para tentar novamente.',
        );
      case ResultadoAcesso.negadaPermanentemente:
        await _dialogoOrientacao(
          titulo: 'Permissão bloqueada',
          texto:
              'A permissão de localização foi negada permanentemente. '
              'Habilite-a nas configurações do aplicativo.',
          rotuloAcao: 'Abrir configurações',
          acao: _servico.abrirConfiguracoesApp,
        );
      case ResultadoAcesso.concedido:
        break;
    }
  }

  Future<void> _dialogoOrientacao({
    required String titulo,
    required String texto,
    String? rotuloAcao,
    Future<bool> Function()? acao,
  }) async {
    final aceitou = await showDialog<bool>(
      context: context,
      builder: (contexto) => AlertDialog(
        title: Text(titulo),
        content: Text(texto),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(contexto, false),
            child: Text(acao == null ? 'Entendi' : 'Cancelar'),
          ),
          if (acao != null && rotuloAcao != null)
            TextButton(
              onPressed: () => Navigator.pop(contexto, true),
              child: Text(rotuloAcao),
            ),
        ],
      ),
    );
    if (aceitou == true && acao != null) {
      await acao();
    }
  }

  void _abrirHistorico() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TelaLocalizacoes(coletaAtiva: _coletando),
      ),
    );
  }

  void _abrirMapa() {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => const TelaMapa()));
  }

  void _mensagem(String texto) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(texto)));
  }

  @override
  Widget build(BuildContext context) {
    final coletando = _coletando;
    final ultima = _ultima;

    return Scaffold(
      appBar: AppBar(title: const Text('Coleta de localização')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          coletando ? Icons.gps_fixed : Icons.gps_off,
                          color: coletando ? TemaApp.verde : Colors.white54,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          coletando ? 'Coleta ativa' : 'Coleta parada',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    if (coletando) ...[
                      const SizedBox(height: 8),
                      Text('Registros gravados nesta sessão: $_gravados'),
                    ],
                  ],
                ),
              ),
            ),
            if (ultima != null) ...[
              const SizedBox(height: 12),
              Text(
                'Última posição gravada',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              ItemLocalizacao(localizacao: ultima),
            ],
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: (coletando || _iniciando) ? null : _iniciar,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Iniciar coleta'),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: coletando ? _parar : null,
              icon: const Icon(Icons.stop),
              label: const Text('Parar coleta'),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _abrirHistorico,
              icon: const Icon(Icons.history),
              label: const Text('Consultar histórico'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _abrirMapa,
              icon: const Icon(Icons.map),
              label: const Text('Ver mapa'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _servico.abrirConfiguracoesApp,
              icon: const Icon(Icons.settings),
              label: const Text('Configurações de permissão'),
            ),
          ],
        ),
      ),
    );
  }
}
