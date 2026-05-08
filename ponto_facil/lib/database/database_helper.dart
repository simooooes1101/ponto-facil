import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/registro_ponto.dart';
import '../models/configuracao.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('ponto_facil.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE registros (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        data TEXT NOT NULL,
        hora TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        tipo TEXT NOT NULL,
        observacao TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE configuracoes (
        chave TEXT PRIMARY KEY,
        valor TEXT NOT NULL
      )
    ''');

    // Valores padrão
    await db.insert('configuracoes', {'chave': 'nome_usuario', 'valor': 'Usuário'});
    await db.insert('configuracoes', {'chave': 'pin_ativo', 'valor': 'false'});
    await db.insert('configuracoes', {'chave': 'pin_codigo', 'valor': ''});
    await db.insert('configuracoes', {'chave': 'tema', 'valor': 'sistema'});
    await db.insert('configuracoes', {'chave': 'lembrete_entrada', 'valor': 'false'});
    await db.insert('configuracoes', {'chave': 'lembrete_saida', 'valor': 'false'});
    await db.insert('configuracoes', {'chave': 'hora_lembrete_entrada', 'valor': '08:00'});
    await db.insert('configuracoes', {'chave': 'hora_lembrete_saida', 'valor': '17:00'});
    await db.insert('configuracoes', {'chave': 'carga_horaria_dia', 'valor': '8'});
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE registros ADD COLUMN observacao TEXT');
    }
  }

  // ── REGISTROS ──────────────────────────────────────────────

  Future<int> inserirRegistro(RegistroPonto registro) async {
    final db = await database;
    return await db.insert('registros', registro.toMap());
  }

  Future<List<RegistroPonto>> buscarTodosRegistros() async {
    final db = await database;
    final result = await db.query('registros', orderBy: 'timestamp DESC');
    return result.map((e) => RegistroPonto.fromMap(e)).toList();
  }

  Future<List<RegistroPonto>> buscarRegistrosPorData(String data) async {
    final db = await database;
    final result = await db.query(
      'registros',
      where: 'data = ?',
      whereArgs: [data],
      orderBy: 'timestamp ASC',
    );
    return result.map((e) => RegistroPonto.fromMap(e)).toList();
  }

  Future<List<RegistroPonto>> buscarRegistrosPorPeriodo(
      String dataInicio, String dataFim) async {
    final db = await database;
    final result = await db.query(
      'registros',
      where: 'data >= ? AND data <= ?',
      whereArgs: [dataInicio, dataFim],
      orderBy: 'timestamp ASC',
    );
    return result.map((e) => RegistroPonto.fromMap(e)).toList();
  }

  Future<RegistroPonto?> buscarUltimoRegistro() async {
    final db = await database;
    final result = await db.query(
      'registros',
      orderBy: 'timestamp DESC',
      limit: 1,
    );
    if (result.isEmpty) return null;
    return RegistroPonto.fromMap(result.first);
  }

  Future<bool> existeRegistroNoMinuto(DateTime momento) async {
    final db = await database;
    final inicio = DateTime(
        momento.year, momento.month, momento.day, momento.hour, momento.minute);
    final fim = inicio.add(const Duration(minutes: 1));
    final result = await db.query(
      'registros',
      where: 'timestamp >= ? AND timestamp < ?',
      whereArgs: [inicio.millisecondsSinceEpoch, fim.millisecondsSinceEpoch],
    );
    return result.isNotEmpty;
  }

  Future<int> atualizarRegistro(RegistroPonto registro) async {
    final db = await database;
    return await db.update(
      'registros',
      registro.toMap(),
      where: 'id = ?',
      whereArgs: [registro.id],
    );
  }

  Future<int> excluirRegistro(int id) async {
    final db = await database;
    return await db.delete('registros', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> buscarRegistrosPorMes(
      int ano, int mes) async {
    final db = await database;
    final mesStr = mes.toString().padLeft(2, '0');
    final prefix = '$ano-$mesStr';
    final result = await db.query(
      'registros',
      where: "data LIKE ?",
      whereArgs: ['$prefix%'],
      orderBy: 'timestamp ASC',
    );
    return result;
  }

  // ── CONFIGURAÇÕES ──────────────────────────────────────────

  Future<String?> lerConfig(String chave) async {
    final db = await database;
    final result = await db.query(
      'configuracoes',
      where: 'chave = ?',
      whereArgs: [chave],
    );
    if (result.isEmpty) return null;
    return result.first['valor'] as String?;
  }

  Future<void> salvarConfig(String chave, String valor) async {
    final db = await database;
    await db.insert(
      'configuracoes',
      {'chave': chave, 'valor': valor},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, String>> lerTodasConfigs() async {
    final db = await database;
    final result = await db.query('configuracoes');
    return Map.fromEntries(
      result.map((e) => MapEntry(e['chave'] as String, e['valor'] as String)),
    );
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
