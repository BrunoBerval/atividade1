import 'package:sqflite/sqflite.dart';

import '../../models/localizacao.dart';
import '../database/banco_localizacoes.dart';

class RepositorioException implements Exception {
  const RepositorioException(this.mensagem);

  final String mensagem;

  @override
  String toString() => mensagem;
}

class RepositorioLocalizacoes {
  RepositorioLocalizacoes({BancoLocalizacoes? banco})
    : _banco = banco ?? BancoLocalizacoes.instancia;

  final BancoLocalizacoes _banco;

  static const int limitePadrao = 100;

  Future<int> inserir(Localizacao localizacao) async {
    try {
      final db = await _banco.obter();
      return await db.insert(BancoLocalizacoes.tabela, localizacao.toMap());
    } on DatabaseException catch (e) {
      throw RepositorioException('Falha ao salvar a localização: $e');
    }
  }

  /// Retorna as últimas [limite] localizações, da mais recente para a mais antiga.
  /// O limite vale só para a consulta; nada é apagado.
  Future<List<Localizacao>> consultarUltimas({
    int limite = limitePadrao,
  }) async {
    try {
      final db = await _banco.obter();
      final linhas = await db.query(
        BancoLocalizacoes.tabela,
        orderBy: 'instante DESC, id DESC',
        limit: limite,
      );
      return linhas.map(Localizacao.fromMap).toList();
    } on DatabaseException catch (e) {
      throw RepositorioException('Falha ao consultar o histórico: $e');
    }
  }

  /// Remove todas as linhas, preservando a tabela e o arquivo do banco.
  Future<void> excluirTodas() async {
    try {
      final db = await _banco.obter();
      await db.delete(BancoLocalizacoes.tabela);
    } on DatabaseException catch (e) {
      throw RepositorioException('Falha ao limpar o histórico: $e');
    }
  }
}
