class FormsHistoryItem {
  int id = -1;
  final String tokenHash;
  DateTime lastEditTime;
  String formName;
  String secondaryId;
  int instanceNumber;

  FormsHistoryItem(
      {this.id,
      this.tokenHash,
      this.lastEditTime,
      this.formName,
      this.secondaryId,
      this.instanceNumber});
}
