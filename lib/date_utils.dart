class DateUtils {
  static int daysInMonth(int year, int month) {
    var firstMonthDay = DateTime(year, month);
    var firstNextMonthDay = DateTime(year, month + 1);
    return firstNextMonthDay.difference(firstMonthDay).inDays;
  }
}
