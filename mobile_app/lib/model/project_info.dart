import 'dart:collection';

import 'package:haf_spb_app/model/smart_variables_dependencies_extractor.dart';
import 'package:quiver/collection.dart';
import 'package:quiver/strings.dart';
import 'package:xml/xml.dart';

import '../logger.dart';
import 'data_type.dart';
import 'empirical_evidence.dart';
import 'fields_group.dart';
import 'form_permission.dart';
import 'instrument_field.dart';
import 'code_list.dart';
import 'field_type.dart';
import 'field_type_enum.dart';
import 'instrument_info.dart';
import 'text_validation_type.dart';

class ProjectInfo {
  final String name;
  final instrumentsByOid = new Map<String, InstrumentInfo>(); //Key - OID
  final instrumentsByName =
      new Map<String, InstrumentInfo>(); //Key - Form name ID
  final List<InstrumentInfo> repeatInstruments = [];
  final fieldsByVariable =
      new Map<String, InstrumentField>(); //Key - field Name
  final String recordIdFieldName;
  final String secondaryIdFieldName;
  final bool autonumberingEnabled;

  InstrumentField? birthdayField; //birthday
  InstrumentInfo? _initInstrument;
  InstrumentInfo get initInstrument {
    if (_initInstrument != null) return _initInstrument!;
    _initInstrument = instrumentsByName.values.firstWhere((instrument) =>
        EmpiricalEvidence.isInstrumentInitial(instrument, recordIdFieldName));
    if (_initInstrument == null) {
      logger.w(
          "Couldn't find initial instrument. It should have Record ID field.");
    }
    return _initInstrument!;
  }

  ProjectInfo(this.name, this.recordIdFieldName, this.secondaryIdFieldName,
      this.autonumberingEnabled);

  static ProjectInfo? fromXml(
      String xml, Map<String, FormPermission> permissions) {
    try {
      var document = XmlDocument.parse(xml);
      var rootElement = document.rootElement;
      if (rootElement.name.local != "ODM")
        throw new FormatException("Root element must be 'ODM'");
      var projectName = rootElement.getAttribute("Description");
      var studyElement = rootElement.getElement("Study");
      var globalVariablesElement = studyElement!.getElement("GlobalVariables");
      var autonumberingElement = globalVariablesElement!
          .getElement("redcap:RecordAutonumberingEnabled");
      var autonumberingEnabled = autonumberingElement?.innerText == "1";
      var secondaryKeyElement =
          globalVariablesElement.getElement("redcap:SecondaryUniqueField");
      var secondaryKey = secondaryKeyElement?.innerText;
      EmpiricalEvidence.secondaryId = secondaryKey ?? "";
      var repeatingInstrumentsAndEventsElement = globalVariablesElement
          .getElement("redcap:RepeatingInstrumentsAndEvents");
      var repeatingInstrumentsElement = repeatingInstrumentsAndEventsElement!
          .getElement("redcap:RepeatingInstruments");

      // Reading redcap:RepeatingInstruments
      var repeatingInstrumentElements = repeatingInstrumentsElement!
          .findAllElements("redcap:RepeatingInstrument");
      var repeatingInstruments = new Map<String, List<String>>();
      for (var repeatingInstrumentElement in repeatingInstrumentElements) {
        String? formNameId;
        List<String> customLabels = [];
        for (var attr in repeatingInstrumentElement.attributes) {
          switch (attr.name.qualified) {
            case "redcap:RepeatInstrument":
              formNameId = attr.value;
              break;
            case "redcap:CustomLabel":
              customLabels = attr.value.isEmpty
                  ? []
                  : SmartVariablesDependenciesExtractor.getVariablesDependOn(
                          attr.value)
                      .toList();
              break;
          }
        }
        if (formNameId != null)
          repeatingInstruments.putIfAbsent(formNameId, () => customLabels);
      }

      // Reading FormDef elements
      var metadataElement = studyElement.getElement("MetaDataVersion");
      var recordIdFieldName =
          metadataElement!.getAttribute("redcap:RecordIdField");
      var project = new ProjectInfo(projectName!, recordIdFieldName!,
          secondaryKey!, autonumberingEnabled);
      //key - group item oid, value - instrument oid
      var fieldGroupsMap = new Map<String, String>();
      //key - field item oid, value - group oid
      var fieldsMap = new LinkedHashMap<String, String>();

      var forms = metadataElement.findAllElements("FormDef");
      for (var form in forms) {
        String oid = form.getAttribute("OID")!;
        String formNameId = form.getAttribute("redcap:FormName")!;
        String formName = form.getAttribute("Name")!;

        var repeatingInstrument = repeatingInstruments[formNameId];
        var instrument = InstrumentInfo(oid, formNameId, formName, project,
            isRepeating: repeatingInstrument != null,
            customLabel: repeatingInstrument ?? []);
        instrument.permission =
            permissions[formNameId] ?? FormPermission.NoAccess;
        project.instrumentsByOid[oid] = instrument;
        project.instrumentsByName[formNameId] = instrument;
        if (instrument.isRepeating) project.repeatInstruments.add(instrument);

        var itemGroupRefs = form.findAllElements("ItemGroupRef");
        for (var itemGroupRef in itemGroupRefs) {
          var groupOid = itemGroupRef.getAttribute("ItemGroupOID");
          if (groupOid == null) {
            logger.w("ItemGroupRef@ItemGroupOID == null");
          } else {
            fieldGroupsMap[groupOid] = oid;
          }
        }
      }

      //Reading ItemGroupDef elements
      var itemGroupDefs = metadataElement.findAllElements("ItemGroupDef");
      for (var itemGroupDef in itemGroupDefs) {
        var groupOid = itemGroupDef.getAttribute("OID")!;
        var groupName = itemGroupDef.getAttribute("Name")!;
        var instrumentOid = fieldGroupsMap[groupOid];
        if (instrumentOid == null) {
          logger.w("Couldn't find instrument for group $groupOid");
          continue;
        }
        final fieldsGroup = new FieldsGroup(groupOid, name: groupName);
        project.instrumentsByOid[instrumentOid]!.fieldGroups[groupOid] =
            fieldsGroup;

        var itemRefs = itemGroupDef.findAllElements("ItemRef");
        for (var itemRef in itemRefs) {
          var oid = itemRef.getAttribute("ItemOID");
          if (oid == null) {
            logger.w("Oid of item == null");
            continue;
          }
          fieldsMap[oid] = groupOid;
        }
      }

      //Reading CodeList elements
      var codeListMap = new ListMultimap<
          String, //key - redcap:Variable
          CodeList>();
      var codeLists = metadataElement.findAllElements("CodeList");
      for (var codeListElement in codeLists) {
        var variable = codeListElement.getAttribute("redcap:Variable");
        if (variable == null) {
          logger.w("redcap:Variable of codelist element == null");
          continue;
        }
        var codeList = new CodeList(codeListElement.getAttribute("OID")!,
            codeListElement.getAttribute("Name")!, variable,
            checkboxesChoices:
                codeListElement.getAttribute("redcap:CheckboxChoices") ?? "");
        codeListMap.add(variable, codeList);

        var codeListItems = codeListElement.findAllElements("CodeListItem");
        for (var codeListItem in codeListItems) {
          var codedValue = codeListItem.getAttribute("CodedValue");
          if (codedValue == null) {
            logger.w("CodedValue of CodeListItem element == null");
            continue;
          }
          var translatedText = codeListItem
              .getElement("Decode")
              ?.getElement("TranslatedText")
              ?.innerText;

          codeList.codeListItems[codedValue] =
              translatedText ?? "Unknown value";
        }
      }

      //Reading ItemDef elements
      var itemDefs = metadataElement.findAllElements("ItemDef");
      for (var itemDef in itemDefs) {
        var oid = itemDef.getAttribute("OID");
        if (oid == null) {
          logger.w("oid of itemdef element == null");
          continue;
        }

        var variable = itemDef.getAttribute("redcap:Variable");
        if (variable == null) {
          logger.w("redcap:Variable of itemdef element == null");
          continue;
        }

        var fieldTypeEnum =
            parseFieldTypeEnum(itemDef.getAttribute("redcap:FieldType")!);
        if (fieldTypeEnum == null) {
          logger.w("Skipping ItemDef element $oid");
          continue;
        }

        var fieldsGroupOid = fieldsMap[oid];
        if (fieldsGroupOid == null) {
          logger.w("Couldn't find fields groudp for field $oid");
          continue;
        }

        var instrumentOid = fieldGroupsMap[fieldsGroupOid];
        var instrument = project.instrumentsByOid[instrumentOid];

        if (instrument == null) {
          logger.w(
              "Couldn't find an instrument by oid $instrumentOid. Looks like broken project xml.");
          continue;
        }

        //Skipping checkboxes not-necessary ItemDefs
        //One variable - one itemdef
        if (fieldTypeEnum == FieldTypeEnum.Checkboxes &&
            instrument.fieldsByVariable.containsKey(variable)) {
          continue;
        }

        var questionElement = itemDef.getElement("Question");
        var question = questionElement
            ?.getElement("redcap:FormattedTranslatedText")
            ?.innerText;
        if (question == null)
          question =
              questionElement?.getElement("TranslatedText")?.innerText ?? "";

        String minValue = "", maxValue = "";
        var rangeCheckElements = itemDef.findAllElements("RangeCheck");
        for (var rangeCheckElement in rangeCheckElements) {
          var softHardAttr = rangeCheckElement.getAttribute("SoftHard");
          if (softHardAttr != "Soft") //Just warn, don't know what does it mean
            logger.w("SoftHard attribute = $softHardAttr");
          var comparator = rangeCheckElement.getAttribute("Comparator");
          var value = rangeCheckElement.getElement("CheckValue")!.innerText;
          if (comparator == "GE")
            minValue = value;
          else if (comparator == "LE")
            maxValue = value;
          else
            logger.e("Unknown comparator value: '$comparator'");
        }

        var codeListOid =
            itemDef.getElement("CodeListRef")?.getAttribute("CodeListOID");

        Iterable<CodeList> codeLists = [];
        if (codeListOid != null) codeLists = codeListMap[variable];

        var fieldType = FieldType.create(
          fieldTypeEnum,
          codeLists,
        );

        var dataType = parseDataType(itemDef.getAttribute("DataType")!);
        if (dataType == null) {
          logger.w("Skipping ItemDef element $oid");
          continue;
        }

        var field = new InstrumentField(
          instrument,
          oid,
          variable,
          itemDef.getAttribute("redcap:FieldAnnotation") ?? "",
          name: itemDef.getAttribute("Name")!,
          question: question,
          note: itemDef.getAttribute("redcap:FieldNote") ?? "",
          isMandatory: itemDef.getAttribute("redcap:RequiredField") == "y",
          fieldTypeEnum: fieldTypeEnum,
          fieldType: fieldType,
          dataType: dataType,
          sectionName: itemDef.getAttribute("redcap:SectionHeader") ?? "",
          textValidationType: parseTextValidationType(
              itemDef.getAttribute("redcap:TextValidationType")),
          length: int.tryParse(itemDef.getAttribute("Length") ?? ""),
          branchingLogic: itemDef.getAttribute("redcap:BranchingLogic") ?? "",
          matrixGroupName: itemDef.getAttribute("redcap:MatrixGroupName") ?? "",
          minValue: minValue,
          maxValue: maxValue,
          isRecordId: fieldsMap.keys.first == oid,
          isSecondaryId: secondaryKey == oid,
        );

        if (fieldType == null && !field.isHidden) {
          logger.e("Project error: Field ${field.variable} of instrument "
              "${instrument.formName} has type ${fieldTypeEnum}. "
              "This field type is not implemented and should be hidden "
              "using @HIDDEN or @HIDDEN-APP annptation");
          throw new UnimplementedError();
        }

        if (fieldType != null) fieldType.instrumentField = field;

        if (EmpiricalEvidence.isFieldFormStatus(field))
          instrument.formStatusField = field;
        else if (EmpiricalEvidence.isFieldFillingDate(field))
          instrument.fillingDateField = field;
        else if (EmpiricalEvidence.isFieldFillingPlace(field))
          instrument.fillingPlaceField = field;
        else if (EmpiricalEvidence.isFieldBirthday(field))
          project.birthdayField = field;

        instrument.fieldsByVariable[variable] = field;
        var fieldGroup = instrument.fieldGroups[fieldsGroupOid]!;
        fieldGroup.fields.add(field);
        fieldGroup.fieldsMap[variable] = field;
        project.fieldsByVariable[variable] = field;
      }

      project._fillVarDependencies();
      return project;
    } on XmlParserException catch (e) {
      logger.e("Project xml parse error: ${e.toString()}");
      return null;
    } on NoSuchMethodError catch (e) {
      logger.e("Project xml structure error",
          error: e, stackTrace: e.stackTrace);
      return null;
    } on TypeError catch (e) {
      logger.e("Project xml type error", error: e, stackTrace: e.stackTrace);
      return null;
    } catch (e) {
      logger.e("Project xml other error: ${e.toString()}");
      return null;
    }
  }

  //For each variables fills its dependentVariables property
  void _fillVarDependencies() {
    for (var field in fieldsByVariable.values) {
      if (isEmpty(field.branchingLogic)) continue;
      var dependOnVars =
          SmartVariablesDependenciesExtractor.getVariablesDependOn(
              field.branchingLogic);
      for (var varibleName in dependOnVars) {
        fieldsByVariable[varibleName]!.hasDependentVariables = true;
      }
    }
  }
}
