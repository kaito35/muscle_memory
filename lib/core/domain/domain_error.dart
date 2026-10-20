/// 業務ルール違反。Flutterや通信ライブラリには依存しない。
class DomainError implements Exception {
  const DomainError(this.message);
  final String message;
  @override
  String toString() => message;
}

void require(bool condition, String message) {
  if (!condition) throw DomainError(message);
}

int _sequence = 0;
// Webでは時計の分解能が低いため連番も使う。API接続時はサーバーのUUIDへ置換。
String newId() => '${DateTime.now().microsecondsSinceEpoch}-${_sequence++}';

DateTime dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);
DateTime weekStart(DateTime date) =>
    dateOnly(date).subtract(Duration(days: date.weekday - 1));
bool sameDay(DateTime a, DateTime b) => dateOnly(a) == dateOnly(b);
