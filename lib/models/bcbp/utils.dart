int hexToNumber(String hex) {
  return int.parse(hex, radix: 16);
}

String numberToHex(int n) {
  return n.toRadixString(16).padLeft(2, '0').toUpperCase();
}

String dateToDayOfYear(DateTime date, {bool addYearPrefix = false}) {
  const oneDay = 1000 * 60 * 60 * 24;
  final dayOfYear = (DateTime.utc(date.year, date.month, date.day)
      .difference(DateTime.utc(date.year, 1, 0))
      .inMilliseconds / oneDay)
      .round();

  String yearPrefix = "";
  if (addYearPrefix) {
    yearPrefix = date.year.toString().substring(date.year.toString().length - 1);
  }

  return "$yearPrefix${dayOfYear.toString().padLeft(3, '0')}";
}

DateTime dayOfYearToDate(String dayOfYear, bool hasYearPrefix, {int? referenceYear}) {
  final currentYear = referenceYear ?? DateTime.now().toUtc().year;
  String year = currentYear.toString();
  String daysToAdd = dayOfYear;

  if (hasYearPrefix) {
    year = year.substring(0, year.length - 1) + daysToAdd[0];
    daysToAdd = daysToAdd.substring(1);

    if (int.parse(year) - currentYear > 2) {
      year = (int.parse(year) - 10).toString();
    }
  }

  final date = DateTime.utc(int.parse(year), 1, 0);
  try {
    return date.add(Duration(days: int.parse(daysToAdd)));
  } catch (e) {
    throw Exception('Invalid day of year: $dayOfYear');
  }
}
