class FormsHistoryItem {
  int id = -1;
  final String tokenHash;
  DateTime lastEditTime;
  DateTime createTime;
  String formName;
  String secondaryId;
  int instanceNumber;

  FormsHistoryItem(
      {this.id,
      this.tokenHash,
      this.createTime,
      this.lastEditTime,
      this.formName,
      this.secondaryId,
      this.instanceNumber});
}
