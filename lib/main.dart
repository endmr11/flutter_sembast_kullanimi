import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast_veritabani_kullanimi1/models/todo_model.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:english_words/english_words.dart' as english_words;

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const dbAdi = 'demo.db';
  static const _dbStokAdi = 'example_stok';

  late Future<bool> _olusturDbFuture;
  late Database _db;
  late StoreRef<int, Map<String, dynamic>> _stok;
  List<TodoModel> _todos = [];

  @override
  void initState() {
    super.initState();
    this._olusturDbFuture = _olusturDb();
  }

  Future<bool> _olusturDb() async {
    final dbDosya = await path_provider.getApplicationDocumentsDirectory();
    final dbYol = dbAdi;
    this._db = await databaseFactoryIo.openDatabase(dbDosya.path + "/" + dbYol);
    print('Db created at $dbYol');
    this._stok = intMapStoreFactory.store(_dbStokAdi);
    _getirTodoModels();
    return true;
  }

  // Retrieves records from the db store.
  Future<void> _getirTodoModels() async {
    final finder = Finder();
    final recordSnapshots = await this._stok.find(this._db, finder: finder);
    this._todos = recordSnapshots
        .map((snapshot) => TodoModel.fromJsonMap({
              ...snapshot.value,
              'id': snapshot.key,
            }))
        .toList();
  }

  Future<void> _ekleTodoModel(TodoModel todo) async {
    final int id = await this._stok.add(this._db, todo.toJsonMap());
    print('Inserted todo item with id=$id.');
  }

  Future<void> _isaretleTodoModel(TodoModel todo) async {
    todo.isDone = !todo.isDone;
    final int count = await this._stok.update(
          this._db,
          todo.toJsonMap(),
          finder: Finder(filter: Filter.byKey(todo.id)),
        );
    print('Değiştireln: $count.');
  }

  Future<void> _silTodoModel(TodoModel todo) async {
    final int count = await this._stok.delete(
          this._db,
          finder: Finder(filter: Filter.byKey(todo.id)),
        );
    print('Silinen $count.');
  }

  Future _yenileUI() async {
    await _getirTodoModels();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            "Sembast Kullanımı",
          ),
          centerTitle: true,
        ),
        body: FutureBuilder<bool>(
          future: this._olusturDbFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return ListView(
              children: this._todos.map(_itemToListTile).toList(),
            );
          },
        ),
        floatingActionButton: _buildFloatingActionButton(),
      ),
    );
  }

  ListTile _itemToListTile(TodoModel todo) => ListTile(
        title: Text(
          todo.content,
          style: TextStyle(
              fontStyle: todo.isDone ? FontStyle.italic : null,
              color: todo.isDone ? Colors.grey : null,
              decoration: todo.isDone ? TextDecoration.lineThrough : null),
        ),
        subtitle: Text('id=${todo.id}\noluşturuldu: ${todo.createdAt}'),
        isThreeLine: true,
        leading: IconButton(
          icon: Icon(
            todo.isDone ? Icons.check_box : Icons.check_box_outline_blank,
          ),
          onPressed: () async {
            await _isaretleTodoModel(todo);
            _yenileUI();
          },
        ),
        trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              await _silTodoModel(todo);
              _yenileUI();
            }),
      );

  FloatingActionButton _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () async {
        await _ekleTodoModel(
          TodoModel(
            content: english_words.generateWordPairs().first.asPascalCase,
            createdAt: DateTime.now(),
          ),
        );
        _yenileUI();
      },
      child: const Icon(Icons.add),
    );
  }
}
