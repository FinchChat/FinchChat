import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/api_config.dart'; // Adjust import path

class ApiConfigService {
  static const String _tableName = 'settings_api_configs';
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'finch_chat.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            id TEXT PRIMARY KEY,
            serviceName TEXT NOT NULL,
            serviceType TEXT NOT NULL,
            baseUrl TEXT NOT NULL,
            defaultModel TEXT,
            isEnabled INTEGER DEFAULT 1,
            additionalHeaders TEXT 
          )
        ''');
      },
    );
  }

  Future<List<ApiConfig>> getAllConfigs() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_tableName);

    List<ApiConfig> configs = [];
    for (var map in maps) {
      final config = ApiConfig.fromMap(map);
      // Fetch API key from secure storage
      config.apiKey = await _secureStorage.read(key: config.id);
      configs.add(config);
    }
    return configs;
  }

  Future<ApiConfig?> getConfigById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      final config = ApiConfig.fromMap(maps.first);
      config.apiKey = await _secureStorage.read(key: config.id);
      return config;
    }
    return null;
  }

  Future<String> saveConfig(ApiConfig config, String? apiKeyToStore) async {
    final db = await database;

    await db.insert(
      _tableName,
      config.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    if (apiKeyToStore != null && apiKeyToStore.isNotEmpty) {
      await _secureStorage.write(key: config.id, value: apiKeyToStore);
    } else {
      // If API key is cleared or not provided, delete it from secure storage
      await _secureStorage.delete(key: config.id);
    }
    return config.id; // Return the ID of the newly added or updated config
  }

  Future<void> updateConfig(ApiConfig config, String? apiKeyToStore) async {
    final db = await database;
    await db.update(
      _tableName,
      config.toMap(), // apiKey is not in toMap()
      where: 'id = ?',
      whereArgs: [config.id],
    );

    if (apiKeyToStore != null && apiKeyToStore.isNotEmpty) {
      await _secureStorage.write(key: config.id, value: apiKeyToStore);
    } else {
      // If API key is cleared or not provided during update, delete it
      await _secureStorage.delete(key: config.id);
    }
  }

  Future<void> deleteConfig(String id) async {
    final db = await database;
    await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
    await _secureStorage.delete(key: id);
  }

  Future<void> toggleConfigEnabled(String id, bool isEnabled) async {
    final db = await database;
    await db.update(
      _tableName,
      {'isEnabled': isEnabled ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
