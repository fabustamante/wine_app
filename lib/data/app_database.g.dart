// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $AppDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $AppDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<AppDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder implements $AppDatabaseBuilderContract {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $AppDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  UsersDao? _usersDaoInstance;

  WinesDao? _winesDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `User` (`id` INTEGER NOT NULL, `username` TEXT NOT NULL, `password` TEXT NOT NULL, `email` TEXT NOT NULL, `age` INTEGER, `avatarPath` TEXT, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Wine` (`id` TEXT NOT NULL, `name` TEXT NOT NULL, `year` TEXT NOT NULL, `grapes` TEXT NOT NULL, `country` TEXT NOT NULL, `region` TEXT NOT NULL, `description` TEXT NOT NULL, `pictureUrl` TEXT, PRIMARY KEY (`id`))');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  UsersDao get usersDao {
    return _usersDaoInstance ??= _$UsersDao(database, changeListener);
  }

  @override
  WinesDao get winesDao {
    return _winesDaoInstance ??= _$WinesDao(database, changeListener);
  }
}

class _$UsersDao extends UsersDao {
  _$UsersDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _userInsertionAdapter = InsertionAdapter(
            database,
            'User',
            (User item) => <String, Object?>{
                  'id': item.id,
                  'username': item.username,
                  'password': item.password,
                  'email': item.email,
                  'age': item.age,
                  'avatarPath': item.avatarPath
                }),
        _userUpdateAdapter = UpdateAdapter(
            database,
            'User',
            ['id'],
            (User item) => <String, Object?>{
                  'id': item.id,
                  'username': item.username,
                  'password': item.password,
                  'email': item.email,
                  'age': item.age,
                  'avatarPath': item.avatarPath
                }),
        _userDeletionAdapter = DeletionAdapter(
            database,
            'User',
            ['id'],
            (User item) => <String, Object?>{
                  'id': item.id,
                  'username': item.username,
                  'password': item.password,
                  'email': item.email,
                  'age': item.age,
                  'avatarPath': item.avatarPath
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<User> _userInsertionAdapter;

  final UpdateAdapter<User> _userUpdateAdapter;

  final DeletionAdapter<User> _userDeletionAdapter;

  @override
  Future<List<User>> getAll() async {
    return _queryAdapter.queryList('SELECT * FROM User',
        mapper: (Map<String, Object?> row) => User(
            id: row['id'] as int,
            username: row['username'] as String,
            password: row['password'] as String,
            email: row['email'] as String,
            age: row['age'] as int?,
            avatarPath: row['avatarPath'] as String?));
  }

  @override
  Future<User?> getById(int id) async {
    return _queryAdapter.query('SELECT * FROM User WHERE id = ?1',
        mapper: (Map<String, Object?> row) => User(
            id: row['id'] as int,
            username: row['username'] as String,
            password: row['password'] as String,
            email: row['email'] as String,
            age: row['age'] as int?,
            avatarPath: row['avatarPath'] as String?),
        arguments: [id]);
  }

  @override
  Future<User?> findByCredentials(
    String username,
    String password,
  ) async {
    return _queryAdapter.query(
        'SELECT * FROM User WHERE username = ?1 AND password = ?2 LIMIT 1',
        mapper: (Map<String, Object?> row) => User(
            id: row['id'] as int,
            username: row['username'] as String,
            password: row['password'] as String,
            email: row['email'] as String,
            age: row['age'] as int?,
            avatarPath: row['avatarPath'] as String?),
        arguments: [username, password]);
  }

  @override
  Future<void> insertOne(User user) async {
    await _userInsertionAdapter.insert(user, OnConflictStrategy.abort);
  }

  @override
  Future<void> insertMany(List<User> users) async {
    await _userInsertionAdapter.insertList(users, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateOne(User user) async {
    await _userUpdateAdapter.update(user, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteOne(User user) async {
    await _userDeletionAdapter.delete(user);
  }
}

class _$WinesDao extends WinesDao {
  _$WinesDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _wineInsertionAdapter = InsertionAdapter(
            database,
            'Wine',
            (Wine item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'year': item.year,
                  'grapes': item.grapes,
                  'country': item.country,
                  'region': item.region,
                  'description': item.description,
                  'pictureUrl': item.pictureUrl
                }),
        _wineUpdateAdapter = UpdateAdapter(
            database,
            'Wine',
            ['id'],
            (Wine item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'year': item.year,
                  'grapes': item.grapes,
                  'country': item.country,
                  'region': item.region,
                  'description': item.description,
                  'pictureUrl': item.pictureUrl
                }),
        _wineDeletionAdapter = DeletionAdapter(
            database,
            'Wine',
            ['id'],
            (Wine item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'year': item.year,
                  'grapes': item.grapes,
                  'country': item.country,
                  'region': item.region,
                  'description': item.description,
                  'pictureUrl': item.pictureUrl
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Wine> _wineInsertionAdapter;

  final UpdateAdapter<Wine> _wineUpdateAdapter;

  final DeletionAdapter<Wine> _wineDeletionAdapter;

  @override
  Future<List<Wine>> getAll() async {
    return _queryAdapter.queryList('SELECT * FROM Wine',
        mapper: (Map<String, Object?> row) => Wine(
            id: row['id'] as String,
            name: row['name'] as String,
            year: row['year'] as String,
            grapes: row['grapes'] as String,
            country: row['country'] as String,
            region: row['region'] as String,
            description: row['description'] as String,
            pictureUrl: row['pictureUrl'] as String?));
  }

  @override
  Future<Wine?> getById(String id) async {
    return _queryAdapter.query('SELECT * FROM Wine WHERE id = ?1',
        mapper: (Map<String, Object?> row) => Wine(
            id: row['id'] as String,
            name: row['name'] as String,
            year: row['year'] as String,
            grapes: row['grapes'] as String,
            country: row['country'] as String,
            region: row['region'] as String,
            description: row['description'] as String,
            pictureUrl: row['pictureUrl'] as String?),
        arguments: [id]);
  }

  @override
  Future<void> insertOne(Wine wine) async {
    await _wineInsertionAdapter.insert(wine, OnConflictStrategy.abort);
  }

  @override
  Future<void> insertMany(List<Wine> wines) async {
    await _wineInsertionAdapter.insertList(wines, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateOne(Wine wine) async {
    await _wineUpdateAdapter.update(wine, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteOne(Wine wine) async {
    await _wineDeletionAdapter.delete(wine);
  }
}
