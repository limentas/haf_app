import 'package:collection/collection.dart';
import 'package:quiver/collection.dart';
import 'package:sqflite/sqflite.dart';
import 'model/empirical_evidence.dart';

class Storage {
  static const _default_values_table = "default_values";

  static Database _database; //TODO: consider closing the DB

  static Multimap<String, String> _defaultValues;
  static bool _inited = false;

  static Future<void> init() async {
    if (_inited) return;
    _defaultValues = await _loadDefaultValues();
    _inited = true;
  }

  static Iterable<String> getDefaultValue(String varName) {
    var unifiedName = EmpiricalEvidence.nameToStoreForField(varName);
    return _defaultValues[unifiedName];
  }

  static void setDefaultValue(String varName, Iterable<String> newValue) async {
    var unifiedName = EmpiricalEvidence.nameToStoreForField(varName);
    var currentValue = _defaultValues[unifiedName];
    if (DeepCollectionEquality.unordered().equals(currentValue, newValue))
      return;

    await _openDatabase();

    _defaultValues.removeAll(unifiedName);
    _defaultValues.addValues(unifiedName, newValue);

    var batch = _database.batch();
    batch.delete(_default_values_table,
        where: "var_name = ?", whereArgs: [unifiedName]);

    for (var newValueItem in newValue) {
      batch.insert(_default_values_table,
          {"var_name": unifiedName, "value": newValueItem});
    }

    await batch.commit();
  }

  static Future<Multimap<String, String>> _loadDefaultValues() async {
    await _openDatabase();

    final valuesMap = await _database.query(_default_values_table);
    return Multimap.fromIterable(valuesMap,
        key: (item) => item["var_name"], value: (item) => item["value"]);
  }

  static Future<void> _openDatabase() async {
    if (_database != null) return;
    _database = await openDatabase(
      'hafspb.db',
      onCreate: (db, version) {
        // Run the CREATE TABLE statement on the database.
        return db.execute(
          "CREATE TABLE $_default_values_table(var_name TEXT, value TEXT)",
        );
      },
      version: 1,
    );
  }
}
