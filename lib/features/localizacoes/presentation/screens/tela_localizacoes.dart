import 'package:flutter/material.dart';

import '../../data/repositories/repositorio_localizacoes.dart';
import '../../models/localizacao.dart';
import '../widgets/item_localizacao.dart';

class TelaLocalizacoes extends StatefulWidget {
  const TelaLocalizacoes({super.key, required this.coletaAtiva});

  /// Usada apenas para informar, na confirmação, que a coleta continua.
  final bool coletaAtiva;

  @override
  State<TelaLocalizacoes> createState() => _TelaLocalizacoesState();
}

class _TelaLocalizacoesState extends State<TelaLocalizacoes> {
  final RepositorioLocalizacoes _repositorio = RepositorioLocalizacoes();

  List<Localizacao> _itens = const [];
  bool _carregando = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregar(mostrarEspera: false);
  }

  Future<void> _carregar({bool mostrarEspera = true}) async {
    if (mostrarEspera) {
      setState(() {
        _carregando = true;
        _erro = null;
      });
    }

    try {
      final itens = await _repositorio.consultarUltimas();
      if (!mounted) return;
      setState(() {
        _itens = itens;
        _erro = null;
        _carregando = false;
      });
    } on RepositorioException catch (e) {
      if (!mounted) return;
      setState(() {
        _erro = e.mensagem;
        _carregando = false;
      });
    }
  }

  Future<void> _limpar() async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (contexto) => AlertDialog(
        title: const Text('Limpar histórico?'),
        content: Text(
          'Todos os registros salvos serão apagados permanentemente, '
          'inclusive os anteriores às 100 localizações exibidas. '
          'Esta operação não pode ser desfeita.'
          '${widget.coletaAtiva ? '\n\nA coleta está ativa: novos registros continuarão sendo salvos.' : ''}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(contexto, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(contexto).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(contexto, true),
            child: const Text('Limpar histórico'),
          ),
        ],
      ),
    );

    if (confirmou != true || !mounted) return;

    try {
      await _repositorio.excluirTodas();
      if (!mounted) return;
      await _carregar(mostrarEspera: false);
      if (!mounted) return;
      _mensagem('Histórico limpo com sucesso.');
    } on RepositorioException catch (e) {
      if (!mounted) return;
      _mensagem(e.mensagem);
    }
  }

  void _mensagem(String texto) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(texto)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico'),
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            icon: const Icon(Icons.refresh),
            onPressed: _carregando ? null : _carregar,
          ),
        ],
      ),
      body: _corpo(),
      floatingActionButton: _itens.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: _limpar,
              icon: const Icon(Icons.delete_sweep),
              label: const Text('Limpar histórico'),
            ),
    );
  }

  Widget _corpo() {
    if (_carregando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_erro != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 12),
              Text(_erro!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _carregar,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _carregar(mostrarEspera: false),
      child: _itens.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 160),
                Center(child: Text('Nenhuma localização registrada.')),
              ],
            )
          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
              itemCount: _itens.length,
              itemBuilder: (_, indice) =>
                  ItemLocalizacao(localizacao: _itens[indice]),
            ),
    );
  }
}
