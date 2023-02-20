class ViewsModel {
  final String count;
  final String range;

  ViewsModel({required this.count, required this.range});

  factory ViewsModel.fromJson(Map<String, dynamic> json) {
    final counts = json['counts'].first;

    return ViewsModel(
        count: counts['count'],
        range: counts['timeRange'] == "ALL_TIME"
            ? "All"
            : counts['timeRange'] == "SEVEN_DAYS"
                ? "Week"
                : "Month");
  }
}
