import 'package:timeago/timeago.dart';

class MyCustomTimeagoMessages implements LookupMessages {
  @override String prefixAgo() => '';
  @override String prefixFromNow() => '';
  @override String suffixAgo() => '';
  @override String suffixFromNow() => '';
  @override String lessThanOneMinute(int seconds) => 'baru saja';
  @override String aboutAMinute(int minutes) => '${minutes}m';
  @override String minutes(int minutes) => '${minutes}m';
  @override String aboutAnHour(int minutes) => '${minutes}m';
  @override String hours(int hours) => '${hours}j';
  @override String aDay(int hours) => '${hours}j';
  @override String days(int days) => '${days}h';
  @override String aboutAMonth(int days) => '${days}h';
  @override String months(int months) => '${months}b';
  @override String aboutAYear(int year) => '${year}t';
  @override String years(int years) => '${years}t';
  @override String wordSeparator() => ' ';
}