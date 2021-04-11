import 'package:collection/collection.dart';
import 'package:quiver/collection.dart';
import 'package:sqflite/sqflite.dart';
import 'logger.dart';
import 'model/empirical_evidence.dart';
import 'model/saved_form.dart';
import 'model/forms_history_item.dart';

class Storage {
  static const _default_values_table = "default_values";
  static const _saved_forms_references_table = "saved_forms_references";
  static const _saved_forms_table = "saved_forms";
  static const _forms_history_table = "forms_history";

  static Database _database; //TODO: consider closing the DB

  static Multimap<String, String> _defaultValues;
  static List<SavedForm> _savedForms;
  static List<FormsHistoryItem> _formsHistory;
  static bool _inited = false;

  static Future<void> init() async {
    if (_inited) return;
    try {
      _defaultValues = await _loadDefaultValues();
      _savedForms = await _loadSavedForms();
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

  static Iterable<SavedForm> getSavedForms() {
    return _savedForms;
  }

  static void addSavedForm(SavedForm savedForm) async {
    try {
      var id = await _database.insert(_saved_forms_references_table, {
        "api_token": savedForm.tokenHash,
        "last_edit_time": savedForm.lastEditTime.millisecondsSinceEpoch ~/ 1000,
        "form_name": savedForm.formName,
        "secondary_id": savedForm.secondaryId
      });

      savedForm.id = id;
      var batch = _database.batch();
      savedForm.instrumentInstance.valuesMap.forEach((key, value) {
        batch.insert(_saved_forms_table,
            {"reference_id": id, "variable": key, "value": value});
      });

      batch.commit(noResult: true);

      _savedForms.add(savedForm);
    } on Exception catch (e) {
      logger.e("Storage::addSavedForm exception ", e);
    }
  }

  static void removeSavedForm(SavedForm savedForm) async {
    try {
      await _database.delete(_saved_forms_references_table,
          where: "\$id = ?", whereArgs: [savedForm.id]);

      _savedForms.removeWhere((element) => element.id == savedForm.id);
    } on Exception catch (e) {
      logger.e("Storage::removeSavedForm exception ", e);
    }
  }

  static Future<void> updateSavedFormVars(SavedForm savedForm) async {
    try {
      savedForm.lastEditTime = DateTime.now();

      var batch = _database.batch();

      batch.update(
          _saved_forms_references_table,
          {
            "last_edit_time":
                savedForm.lastEditTime.millisecondsSinceEpoch ~/ 1000,
          },
          where: "\$id = ?",
          whereArgs: [savedForm.id]);

      batch.delete(_saved_forms_table,
          where: "\$reference_id = ?", whereArgs: [savedForm.id]);

      savedForm.instrumentInstance.valuesMap.forEach((key, value) {
        batch.insert(_saved_forms_table,
            {"reference_id": savedForm.id, "variable": key, "value": value});
      });

      batch.commit(noResult: true);

      _savedForms.removeWhere((form) => form.id == savedForm.id);
      _savedForms.add(savedForm);
    } on Exception catch (e) {
      logger.e("Storage::removeSavedForm exception ", e);
    }
  }

  static Iterable<FormsHistoryItem> getFormsHistory() {
    return _formsHistory;
  }

  static void addFormsHistoryItem(FormsHistoryItem historyItem) {
    _formsHistory.add(historyItem);

    try {
      _database.insert(_forms_history_table, {
        "api_token": historyItem.tokenHash,
        "last_edit_time":
            historyItem.lastEditTime.millisecondsSinceEpoch ~/ 1000,
        "form_name": historyItem.formName,
        "secondary_id": historyItem.secondaryId,
        "instance_number": historyItem.instanceNumber
      });
    } on Exception catch (e) {
      logger.e("Storage::addFormsHistoryItem exception ", e);
    }
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

  static Future<Iterable<SavedForm>> _loadSavedForms() async {
    await _openDatabase();

    try {
      var formsReferences =
          await _database.query(_saved_forms_references_table);

      var savedForms = new List<SavedForm>();
      for (var savedFormItem in formsReferences) {
        var savedForm = new SavedForm(
            id: savedFormItem["id"],
            tokenHash: savedFormItem["api_token"],
            lastEditTime: DateTime.fromMillisecondsSinceEpoch(
                savedFormItem["last_edit_time"] * 1000),
            formName: savedFormItem["form_name"],
            secondaryId: savedFormItem["secondary_id"]);

        var items = await _database.query(_saved_forms_table,
            where: "\$reference_id = ?", whereArgs: [savedForm.id]);
        for (var item in items) {
          savedForm.instrumentInstance.valuesMap
              .add(item["variable"], item["value"]);
        }

        savedForms.add(savedForm);
      }

      return savedForms;
    } on Exception catch (e) {
      logger.e("Storage::_loadSavedForms exception ", e);
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
            tokenHash: item["api_token"],
            lastEditTime:
                DateTime.fromMillisecondsSinceEpoch(item["last_edit_time"]),
            formName: item["form_name"],
            secondaryId: item["secondary_id"],
            instanceNumber: item["instance_number"]);
      });
    } on Exception catch (e) {
      logger.e("Storage::_loadFormsHistory exception ", e);
    }

    return null;
  }

  //TODO: clean database on init: remove outdated history items

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
                "api_token TEXT, "
                "last_edit_time INTEGER, "
                "form_name TEXT, "
                "secondary_id TEXT, "
                "instance_number INTEGER)");
            await db.execute("CREATE TABLE $_saved_forms_references_table("
                "id INTEGER PRIMARY KEY, "
                "api_token TEXT, "
                "last_edit_time INTEGER, "
                "form_name TEXT, "
                "secondary_id TEXT)");
            await db.execute("CREATE TABLE $_saved_forms_table("
                "reference_id INTEGER NOT NULL, "
                "variable TEXT, "
                "value TEXT, "
                "FOREIGN KEY(reference_id) "
                "REFERENCES $_saved_forms_references_table(id))");
          }
        },
        version: 2,
      );
    } on Exception catch (e) {
      logger.e("Storage::_openDatabase exception ", e);
    }
  }
}
