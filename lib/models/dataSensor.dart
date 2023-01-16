class dataSensorFields {
  static final String kelembaban = 'kelembaban';
  static final String suhu = 'suhu';
  static final String updated_at = 'updated_at';

  static List<String> getFields() => [kelembaban, suhu, updated_at];
}

class dataSensor {
  final String kelembaban;
  final String suhu;
  final String updated_at;

  const dataSensor ({
    required this.kelembaban,
    required this.suhu,
    required this.updated_at
  });

  static dataSensor fromJson(Map<String, dynamic> json) => dataSensor(
    kelembaban: json[dataSensorFields.kelembaban],
    suhu:  json[dataSensorFields.suhu],
    updated_at: json[dataSensorFields.updated_at],
  );

  Map<String, dynamic> toJson() => {
    dataSensorFields.kelembaban: kelembaban,
    dataSensorFields.suhu: suhu,
    dataSensorFields.updated_at: updated_at
  };
}
