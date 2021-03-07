class TestProject {
  static final xml = '''<?xml version="1.0" encoding="UTF-8" ?>
<ODM xmlns="http://www.cdisc.org/ns/odm/v1.3" xmlns:ds="http://www.w3.org/2000/09/xmldsig#" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:redcap="https://projectredcap.org" xsi:schemaLocation="http://www.cdisc.org/ns/odm/v1.3 schema/odm/ODM1-3-1.xsd" ODMVersion="1.3.1" FileOID="000-00-0000" FileType="Snapshot" Description="Test" AsOfDateTime="2021-02-13T12:31:58" CreationDateTime="2021-02-13T12:31:58" SourceSystem="REDCap" SourceSystemVersion="8.10.7">
<Study OID="Project.Test">
<GlobalVariables>
	<StudyName>Test</StudyName>
	<StudyDescription>This file contains the metadata, events, and data for REDCap project "Test".</StudyDescription>
	<ProtocolName>Test</ProtocolName>
	<redcap:RecordAutonumberingEnabled>1</redcap:RecordAutonumberingEnabled>
	<redcap:CustomRecordLabel></redcap:CustomRecordLabel>
	<redcap:SecondaryUniqueField>secondary_id</redcap:SecondaryUniqueField>
	<redcap:SchedulingEnabled>0</redcap:SchedulingEnabled>
	<redcap:SurveysEnabled>0</redcap:SurveysEnabled>
	<redcap:SurveyInvitationEmailField></redcap:SurveyInvitationEmailField>
	<redcap:Purpose>4</redcap:Purpose>
	<redcap:PurposeOther></redcap:PurposeOther>
	<redcap:ProjectNotes></redcap:ProjectNotes>
	<redcap:RepeatingInstrumentsAndEvents>
		<redcap:RepeatingInstruments>
			<redcap:RepeatingInstrument redcap:UniqueEventName="event_1_arm_1" redcap:RepeatInstrument="test_instrument" redcap:CustomLabel=""/>
		</redcap:RepeatingInstruments>
	</redcap:RepeatingInstrumentsAndEvents>
</GlobalVariables>
<MetaDataVersion OID="Metadata.Test_2021-02-13_1231" Name="Test" redcap:RecordIdField="record_id">
	<FormDef OID="Form.initial_form" Name="Initial Form" Repeating="No" redcap:FormName="initial_form">
		<ItemGroupRef ItemGroupOID="initial_form.record_id" Mandatory="No"/>
		<ItemGroupRef ItemGroupOID="initial_form.initial_form_complete" Mandatory="No"/>
	</FormDef>
	<FormDef OID="Form.test_instrument" Name="Test instrument" Repeating="No" redcap:FormName="test_instrument">
		<ItemGroupRef ItemGroupOID="test_instrument.text_field1" Mandatory="No"/>
		<ItemGroupRef ItemGroupOID="test_instrument.test_instrument_complete" Mandatory="No"/>
	</FormDef>
	<ItemGroupDef OID="initial_form.record_id" Name="Initial Form" Repeating="No">
		<ItemRef ItemOID="record_id" Mandatory="No" redcap:Variable="record_id"/>
		<ItemRef ItemOID="secondary_id" Mandatory="Yes" redcap:Variable="secondary_id"/>
	</ItemGroupDef>
	<ItemGroupDef OID="test_instrument.text_field1" Name="Test instrument" Repeating="No">
		<ItemRef ItemOID="text_field1" Mandatory="No" redcap:Variable="text_field1"/>
		<ItemRef ItemOID="text_field2" Mandatory="No" redcap:Variable="text_field2"/>
		<ItemRef ItemOID="text_field3" Mandatory="No" redcap:Variable="text_field3"/>
		<ItemRef ItemOID="int_field1" Mandatory="No" redcap:Variable="int_field1"/>
		<ItemRef ItemOID="int_field2" Mandatory="No" redcap:Variable="int_field2"/>
		<ItemRef ItemOID="int_field3" Mandatory="No" redcap:Variable="int_field3"/>
		<ItemRef ItemOID="checkbox_field1___1" Mandatory="No" redcap:Variable="checkbox_field1"/>
		<ItemRef ItemOID="checkbox_field1___2" Mandatory="No" redcap:Variable="checkbox_field1"/>
		<ItemRef ItemOID="checkbox_field1___3" Mandatory="No" redcap:Variable="checkbox_field1"/>
		<ItemRef ItemOID="yesno_field1" Mandatory="No" redcap:Variable="yesno_field1"/>
		<ItemRef ItemOID="date_field1" Mandatory="No" redcap:Variable="date_field1"/>
		<ItemRef ItemOID="datetime_field1" Mandatory="No" redcap:Variable="datetime_field1"/>
		<ItemRef ItemOID="radio_field1" Mandatory="No" redcap:Variable="radio_field1"/>
	</ItemGroupDef>
	<ItemGroupDef OID="test_instrument.test_instrument_complete" Name="Form Status" Repeating="No">
		<ItemRef ItemOID="test_instrument_complete" Mandatory="No" redcap:Variable="test_instrument_complete"/>
	</ItemGroupDef>
	<ItemDef OID="record_id" Name="record_id" DataType="text" Length="999" redcap:Variable="record_id" redcap:FieldType="text">
		<Question><TranslatedText>Record ID</TranslatedText></Question>
	</ItemDef>
	<ItemDef OID="secondary_id" Name="secondary_id" DataType="text" Length="999" redcap:Variable="secondary_id" redcap:FieldType="text" redcap:FieldNote="" redcap:RequiredField="y">
		<Question><TranslatedText>Secondary id:</TranslatedText></Question>
	</ItemDef>
	<ItemDef OID="text_field1" Name="text_field1" DataType="text" Length="999" redcap:Variable="text_field1" redcap:FieldType="text">
		<Question><TranslatedText>text_field1</TranslatedText></Question>
	</ItemDef>
	<ItemDef OID="text_field2" Name="text_field2" DataType="text" Length="999" redcap:Variable="text_field2" redcap:FieldType="text">
		<Question><TranslatedText>text_field2</TranslatedText></Question>
	</ItemDef>
	<ItemDef OID="text_field3" Name="text_field3" DataType="text" Length="999" redcap:Variable="text_field3" redcap:FieldType="text">
		<Question><TranslatedText>text_field3</TranslatedText></Question>
	</ItemDef>
	<ItemDef OID="int_field1" Name="int_field1" DataType="integer" Length="999" redcap:Variable="int_field1" redcap:FieldType="text" redcap:TextValidationType="int">
		<Question><TranslatedText>int_field1</TranslatedText></Question>
	</ItemDef>
	<ItemDef OID="int_field2" Name="int_field2" DataType="integer" Length="999" redcap:Variable="int_field2" redcap:FieldType="text" redcap:TextValidationType="int">
		<Question><TranslatedText>int_field2</TranslatedText></Question>
	</ItemDef>
	<ItemDef OID="int_field3" Name="int_field3" DataType="text" Length="999" redcap:Variable="int_field3" redcap:FieldType="text">
		<Question><TranslatedText>int_field3</TranslatedText></Question>
	</ItemDef>
	<ItemDef OID="checkbox_field1___1" Name="checkbox_field1___1" DataType="boolean" Length="1" redcap:Variable="checkbox_field1" redcap:FieldType="checkbox">
		<Question><TranslatedText>checkbox_field1</TranslatedText></Question>
		<CodeListRef CodeListOID="checkbox_field1___1.choices"/>
	</ItemDef>
	<ItemDef OID="checkbox_field1___2" Name="checkbox_field1___2" DataType="boolean" Length="1" redcap:Variable="checkbox_field1" redcap:FieldType="checkbox">
		<Question><TranslatedText>checkbox_field1</TranslatedText></Question>
		<CodeListRef CodeListOID="checkbox_field1___2.choices"/>
	</ItemDef>
	<ItemDef OID="checkbox_field1___3" Name="checkbox_field1___3" DataType="boolean" Length="1" redcap:Variable="checkbox_field1" redcap:FieldType="checkbox">
		<Question><TranslatedText>checkbox_field1</TranslatedText></Question>
		<CodeListRef CodeListOID="checkbox_field1___3.choices"/>
	</ItemDef>
	<ItemDef OID="yesno_field1" Name="yesno_field1" DataType="boolean" Length="1" redcap:Variable="yesno_field1" redcap:FieldType="yesno">
		<Question><TranslatedText>yesno_field1</TranslatedText></Question>
		<CodeListRef CodeListOID="yesno_field1.choices"/>
	</ItemDef>
	<ItemDef OID="date_field1" Name="date_field1" DataType="date" Length="999" redcap:Variable="date_field1" redcap:FieldType="text" redcap:TextValidationType="date_dmy">
		<Question><TranslatedText>date_field1</TranslatedText></Question>
	</ItemDef>
	<ItemDef OID="datetime_field1" Name="datetime_field1" DataType="partialDatetime" Length="999" redcap:Variable="datetime_field1" redcap:FieldType="text" redcap:TextValidationType="datetime_dmy">
		<Question><TranslatedText>datetime_field1</TranslatedText></Question>
	</ItemDef>
	<ItemDef OID="radio_field1" Name="radio_field1" DataType="text" Length="1" redcap:Variable="radio_field1" redcap:FieldType="radio">
		<Question><TranslatedText>radio_field1</TranslatedText></Question>
		<CodeListRef CodeListOID="radio_field1.choices"/>
	</ItemDef>
	<ItemDef OID="test_instrument_complete" Name="test_instrument_complete" DataType="text" Length="1" redcap:Variable="test_instrument_complete" redcap:FieldType="select" redcap:SectionHeader="Form Status">
		<Question><TranslatedText>Complete?</TranslatedText></Question>
		<CodeListRef CodeListOID="test_instrument_complete.choices"/>
	</ItemDef>
	<CodeList OID="checkbox_field1___1.choices" Name="checkbox_field1___1" DataType="boolean" redcap:Variable="checkbox_field1" redcap:CheckboxChoices="1, option1 | 2, option2 | 3, option3">
		<CodeListItem CodedValue="1"><Decode><TranslatedText>Checked</TranslatedText></Decode></CodeListItem>
		<CodeListItem CodedValue="0"><Decode><TranslatedText>Unchecked</TranslatedText></Decode></CodeListItem>
	</CodeList>
	<CodeList OID="checkbox_field1___2.choices" Name="checkbox_field1___2" DataType="boolean" redcap:Variable="checkbox_field1" redcap:CheckboxChoices="1, option1 | 2, option2 | 3, option3">
		<CodeListItem CodedValue="1"><Decode><TranslatedText>Checked</TranslatedText></Decode></CodeListItem>
		<CodeListItem CodedValue="0"><Decode><TranslatedText>Unchecked</TranslatedText></Decode></CodeListItem>
	</CodeList>
	<CodeList OID="checkbox_field1___3.choices" Name="checkbox_field1___3" DataType="boolean" redcap:Variable="checkbox_field1" redcap:CheckboxChoices="1, option1 | 2, option2 | 3, option3">
		<CodeListItem CodedValue="1"><Decode><TranslatedText>Checked</TranslatedText></Decode></CodeListItem>
		<CodeListItem CodedValue="0"><Decode><TranslatedText>Unchecked</TranslatedText></Decode></CodeListItem>
	</CodeList>
	<CodeList OID="yesno_field1.choices" Name="yesno_field1" DataType="boolean" redcap:Variable="yesno_field1">
		<CodeListItem CodedValue="1"><Decode><TranslatedText>Yes</TranslatedText></Decode></CodeListItem>
		<CodeListItem CodedValue="0"><Decode><TranslatedText>No</TranslatedText></Decode></CodeListItem>
	</CodeList>
	<CodeList OID="radio_field1.choices" Name="radio_field1" DataType="text" redcap:Variable="radio_field1">
		<CodeListItem CodedValue="1"><Decode><TranslatedText>option1</TranslatedText></Decode></CodeListItem>
		<CodeListItem CodedValue="2"><Decode><TranslatedText>option2</TranslatedText></Decode></CodeListItem>
		<CodeListItem CodedValue="3"><Decode><TranslatedText>option3</TranslatedText></Decode></CodeListItem>
	</CodeList>
	<CodeList OID="test_instrument_complete.choices" Name="test_instrument_complete" DataType="text" redcap:Variable="test_instrument_complete">
		<CodeListItem CodedValue="0"><Decode><TranslatedText>Incomplete</TranslatedText></Decode></CodeListItem>
		<CodeListItem CodedValue="1"><Decode><TranslatedText>Unverified</TranslatedText></Decode></CodeListItem>
		<CodeListItem CodedValue="2"><Decode><TranslatedText>Complete</TranslatedText></Decode></CodeListItem>
	</CodeList>
</MetaDataVersion>
</Study>
</ODM>''';
}
