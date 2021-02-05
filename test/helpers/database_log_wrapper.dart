import 'package:sqflite/sqlite_api.dart';

class CallLog {
  final List<dynamic> arguments;
  final DateTime start;

  const CallLog({
    required this.arguments,
    required this.start,
  });
}

class MethodLog {
  MethodLog(this.method);

  final String method;
  final List<CallLog> logs = [];

  int get count => logs.length;
  bool get wasCalled => count > 0;

  void log(List<dynamic> arguments) {
    logs.add(CallLog(arguments: arguments, start: DateTime.now()));
  }
}

class DatabaseLogWrapper implements Database {
  final Database db;
  final Map<String, MethodLog> calls = {};
  DatabaseLogWrapper(this.db);

  MethodLog getMethodLog(String method) {
    MethodLog? methodLog = calls[method];
    if (methodLog == null) {
      methodLog = MethodLog(method);
      calls[method] = methodLog;
    }
    return methodLog;
  }

  void _logCall(String method, [List<dynamic>? arguments]) {
    getMethodLog(method).log(arguments ?? []);
  }

  bool wasMethodCalled(String method) {
    return getMethodLog(method).wasCalled;
  }

  @override
  Batch batch() {
    // TODO: implement batch
    throw UnimplementedError();
  }

  @override
  Future<void> close() {
    _logCall('close');
    return db.close();
  }

  @override
  Future<int> delete(String table, {String? where, List<Object?>? whereArgs}) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future<T> devInvokeMethod<T>(String method, [arguments]) {
    // TODO: implement devInvokeMethod
    throw UnimplementedError();
  }

  @override
  Future<T> devInvokeSqlMethod<T>(String method, String sql,
      [List<Object?>? arguments]) {
    // TODO: implement devInvokeSqlMethod
    throw UnimplementedError();
  }

  @override
  Future<void> execute(String sql, [List<Object?>? arguments]) {
    _logCall('execute', [sql, arguments]);
    if (arguments == null) {
      return db.execute(sql);
    }
    return db.execute(sql, arguments);
  }

  @override
  Future<int> getVersion() {
    // TODO: implement getVersion
    throw UnimplementedError();
  }

  @override
  Future<int> insert(String table, Map<String, Object?> values,
      {String? nullColumnHack, ConflictAlgorithm? conflictAlgorithm}) {
    // TODO: implement insert
    throw UnimplementedError();
  }

  @override
  // TODO: implement isOpen
  bool get isOpen => throw UnimplementedError();

  @override
  // TODO: implement path
  String get path => throw UnimplementedError();

  @override
  Future<List<Map<String, Object?>>> query(String table,
      {bool? distinct,
      List<String>? columns,
      String? where,
      List<Object?>? whereArgs,
      String? groupBy,
      String? having,
      String? orderBy,
      int? limit,
      int? offset}) {
    // TODO: implement query
    throw UnimplementedError();
  }

  @override
  Future<int> rawDelete(String sql, [List<Object?>? arguments]) {
    // TODO: implement rawDelete
    throw UnimplementedError();
  }

  @override
  Future<int> rawInsert(String sql, [List<Object?>? arguments]) {
    // TODO: implement rawInsert
    throw UnimplementedError();
  }

  @override
  Future<List<Map<String, Object?>>> rawQuery(String sql,
      [List<Object?>? arguments]) {
    _logCall('rawQuery', [sql, arguments]);
    if (arguments == null) {
      return db.rawQuery(sql);
    }
    return db.rawQuery(sql, arguments);
  }

  @override
  Future<int> rawUpdate(String sql, [List<Object?>? arguments]) {
    // TODO: implement rawUpdate
    throw UnimplementedError();
  }

  @override
  Future<void> setVersion(int version) {
    // TODO: implement setVersion
    throw UnimplementedError();
  }

  @override
  Future<T> transaction<T>(Future<T> Function(Transaction txn) action,
      {bool? exclusive}) {
    // TODO: implement transaction
    throw UnimplementedError();
  }

  @override
  Future<int> update(String table, Map<String, Object?> values,
      {String? where,
      List<Object?>? whereArgs,
      ConflictAlgorithm? conflictAlgorithm}) {
    // TODO: implement update
    throw UnimplementedError();
  }
}
