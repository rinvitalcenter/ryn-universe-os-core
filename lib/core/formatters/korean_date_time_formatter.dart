abstract final class KoreanDateTimeFormatter {
  static String compact(DateTime value) {
    final local = value.toLocal();
    return '${local.month}월 ${local.day}일 · ${_time(local)}';
  }

  static String full(DateTime value) {
    final local = value.toLocal();
    return '${local.year}년 ${local.month}월 ${local.day}일 · ${_time(local)}';
  }

  static String _time(DateTime value) {
    final period = value.hour < 12 ? '오전' : '오후';
    final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final minute = value.minute.toString().padLeft(2, '0');
    return '$period $hour:$minute';
  }
}
