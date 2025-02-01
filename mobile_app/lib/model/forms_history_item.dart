class FormsHistoryItem {
  int id;
  final String tokenHash;
  DateTime lastEditTime;
  DateTime createTime;
  String formName;
  String secondaryId;
  int? instanceNumber; // null for non-repeating forms

  FormsHistoryItem(
      {this.id = -1,
      required this.tokenHash,
      required this.createTime,
      required this.lastEditTime,
      required this.formName,
      required this.secondaryId,
      required this.instanceNumber});
}
