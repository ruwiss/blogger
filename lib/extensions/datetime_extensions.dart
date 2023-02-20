extension FormatDate on DateTime {
  String formatDate(bool hours) {
    return "${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/$year ${!hours ? '' : '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}'}";
  }

  String convertToBloggerFormat() {
    return "$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}T${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')}-${timeZoneOffset.inHours.toString().padLeft(2, '0')}:00";
  }
}
