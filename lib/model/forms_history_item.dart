class FormsHistoryItem {
  final String tokenHash;
  DateTime lastEditTime;
  String formName;
  String secondaryId;
  int instanceNumber;

  FormsHistoryItem(
      {this.tokenHash,
      this.lastEditTime,
      this.formName,
      this.secondaryId,
      this.instanceNumber});
}
