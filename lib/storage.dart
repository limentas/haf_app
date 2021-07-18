import 'package:collection/collection.dart';
import 'package:quiver/collection.dart';
import 'package:sqflite/sqflite.dart';
import 'logger.dart';
import 'model/empirical_evidence.dart';
import 'model/forms_history_item.dart';

class Storage {
  static const _default_values_table = "default_values";
  static const _forms_history_table = "forms_history";

  static Database _database; //TODO: consider closing the DB

  static Multimap<String, String> _defaultValues;
  static List<FormsHistoryItem> _formsHistory;
  static bool _inited = false;

  static Future<void> init() async {
    if (_inited) return;
    try {
      _defaultValues = await _loadDefaultValues();
      _formsHistory = await _loadFormsHistory();
      _inited = true;
    } on DatabaseException catch (e) {
      logger.e("Init database exception", e);
    }
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

  static Iterable<FormsHistoryItem> getFormsHistory() {
    return _formsHistory;
  }

  static void addFormsHistoryItem(FormsHistoryItem historyItem) {
    var existentItem = _formsHistory.firstWhere(
        (element) =>
            element.secondaryId == historyItem.secondaryId &&
            element.formName == historyItem.formName &&
            element.instanceNumber == historyItem.instanceNumber,
        orElse: () => null);
    if (existentItem != null) {
      updateHistoryItem(existentItem);
      return;
    }

    //This is a new item
    _formsHistory.add(historyItem);

    try {
      var dbTime = historyItem.lastEditTime.millisecondsSinceEpoch ~/ 1000;
      _database.insert(_forms_history_table, {
        "api_token": historyItem.tokenHash,
        "create_time": dbTime,
        "last_edit_time": dbTime,
        "form_name": historyItem.formName,
        "secondary_id": historyItem.secondaryId,
        "instance_number": historyItem.instanceNumber
      });
    } on Exception catch (e) {
      logger.e("Storage::addFormsHistoryItem exception ", e);
    }
  }

  static void removeHistoryItem(FormsHistoryItem historyItem) {
    try {
      _database.delete(_forms_history_table,
          where: "id = ?", whereArgs: [historyItem.id]);
      _formsHistory.removeWhere((element) => element.id == historyItem.id);
    } on Exception catch (e) {
      logger.e("Storage::removeHistoryItem exception ", e);
    }
  }

  static void updateHistoryItem(FormsHistoryItem historyItem) {
    historyItem.lastEditTime = DateTime.now();

    try {
      _database.update(
          _forms_history_table,
          {
            "last_edit_time":
                historyItem.lastEditTime.millisecondsSinceEpoch ~/ 1000,
          },
          where: "id = ?",
          whereArgs: [historyItem.id]);
      _formsHistory.removeWhere((element) => element.id == historyItem.id);
      _formsHistory.add(historyItem);
    } on Exception catch (e) {
      logger.e("Storage::updateHistoryItem exception ", e);
    }
  }

  static FormsHistoryItem findHistoryItem(
      String secondaryId, String formName, int instanceNumber) {
    var item = _formsHistory.firstWhere(
        (element) =>
            element.secondaryId == secondaryId &&
            element.formName == formName &&
            element.instanceNumber == instanceNumber,
        orElse: () => null);
    logger.d("find item $secondaryId $formName $instanceNumber $item");
    return item;
  }

  static Future<Multimap<String, String>> _loadDefaultValues() async {
    await _openDatabase();

    try {
      final valuesMap = await _database.query(_default_values_table);
      return Multimap.fromIterable(valuesMap,
          key: (item) => item["var_name"], value: (item) => item["value"]);
    } on Exception catch (e) {
      logger.e("Storage::_loadDefaultValues exception ", e);
    }

    return null;
  }

  static Future<Iterable<FormsHistoryItem>> _loadFormsHistory() async {
    await _openDatabase();

    try {
      final itemsMap = await _database.query(_forms_history_table);
      return List.generate(itemsMap.length, (i) {
        var item = itemsMap[i];
        return FormsHistoryItem(
            id: item["id"],
            tokenHash: item["api_token"],
            createTime:
                DateTime.fromMillisecondsSinceEpoch(item["create_time"] * 1000),
            lastEditTime: DateTime.fromMillisecondsSinceEpoch(
                item["last_edit_time"] * 1000),
            formName: item["form_name"],
            secondaryId: item["secondary_id"],
            instanceNumber: item["instance_number"]);
      });
    } on Exception catch (e) {
      logger.e("Storage::_loadFormsHistory exception ", e);
    }

    return null;
  }

  static Future<void> _openDatabase() async {
    if (_database != null) return;

    try {
      _database = await openDatabase(
        'hafspb.db',
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 1 && newVersion >= 1) {
            await db.execute(
                "CREATE TABLE $_default_values_table(var_name TEXT, value TEXT)");
          }
          if (oldVersion < 2 && newVersion >= 2) {
            await db.execute("CREATE TABLE $_forms_history_table("
                "id INTEGER PRIMARY KEY, "
                "api_token TEXT, "
                "last_edit_time INTEGER, "
                "form_name TEXT, "
                "secondary_id TEXT, "
                "instance_number INTEGER)");
          }
          if (oldVersion < 3 && newVersion >= 3) {
            await db.execute("ALTER TABLE $_forms_history_table "
                "ADD create_time INTEGER");
            //Updating existent records
            await db.execute("UPDATE $_forms_history_table "
                "SET create_time = last_edit_time");
          }
        },
        version: 3,
      );

      await _cleanDatabase();
    } on Exception catch (e) {
      logger.e("Storage::_openDatabase exception ", e);
    }
  }

  static Future<void> _cleanDatabase() async {
    if (_database == null) return;

    var now = DateTime.now();
    var lastEditDateTime = DateTime(now.year, now.month, now.day);
    try {
      var deletedItems = await _database.delete(_forms_history_table,
          where: "create_time < ?",
          whereArgs: [lastEditDateTime.millisecondsSinceEpoch ~/ 1000]);
      logger.d("Deleted $deletedItems items from history database");
    } on Exception catch (e) {
      logger.e("Storage::_cleanDatabase exception ", e);
    }
  }
}
