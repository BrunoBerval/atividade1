import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class BancoLocalizacoes {
  BancoLocalizacoes._();

  static final BancoLocalizacoes instancia = BancoLocalizacoes._();

  static const String nomeBanco = 'localizacoes.db';
  static const int versao = 1;
  static const String tabela = 'localizacoes';

  Future<Database>? _abertura;

  /// Reutiliza a conexão. Se a abertura falhar, a próxima chamada tenta de novo.
  Future<Database> obter() async {
    final emAndamento = _abertura ??= _abrir();
    try {
      return await emAndamento;
    } catch (_) {
      _abertura = null;
      rethrow;
    }
  }

  Future<Database> _abrir() async {
    final caminho = p.join(await getDatabasesPath(), nomeBanco);
    return openDatabase(
      caminho,
      version: versao,
      onCreate: (db, versao) async {
        await db.execute('''
          CREATE TABLE $tabela (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            precisao REAL NOT NULL,
            instante TEXT NOT NULL
          )
        ''');
      },
    );
  }
}
