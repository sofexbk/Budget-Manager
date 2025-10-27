import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/expense.dart';

class DBHelper {
  static Database? _database;

  // Ouvre ou crée la base de données
  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'budget_manager.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE expenses(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            amount REAL,
            date TEXT
          )
        ''');
      },
    );
  }

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Insérer une dépense
  static Future<void> insertExpense(Expense expense) async {
    final db = await database;
    await db.insert('expenses', {
      'title': expense.title,
      'amount': expense.amount,
      'date': expense.date.toIso8601String(),
    });
  }

  // Récupérer toutes les dépenses
  static Future<List<Expense>> getAllExpenses() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('expenses');
    return List.generate(maps.length, (i) {
      return Expense(
        title: maps[i]['title'],
        amount: maps[i]['amount'],
        date: DateTime.parse(maps[i]['date']),
      );
    });
  }

  // Supprimer une dépense
  static Future<void> deleteExpense(int id) async {
    final db = await database;
    await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  // Supprimer toutes les dépenses
  static Future<void> clearAll() async {
    final db = await database;
    await db.delete('expenses');
  }
}
