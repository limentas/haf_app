class FormsHistoryItem {
  final String tokenHash;
  DateTime lastEditTime;
  String formName;
  String secondaryId;

  FormsHistoryItem(
      {this.tokenHash, this.lastEditTime, this.formName, this.secondaryId});
}
