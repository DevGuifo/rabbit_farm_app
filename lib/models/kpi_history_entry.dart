/// Modèle pour l'historique des KPIs (Phase 4)
/// Stocke les valeurs quotidiennes des indicateurs de performance
class KpiHistoryEntry {
  final int? id;
  final DateTime date;
  final String kpiName; // 'mortalite', 'gmq', 'roi', 'reproduction', etc.
  final double value;

  KpiHistoryEntry({
    this.id,
    required this.date,
    required this.kpiName,
    required this.value,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'kpi_name': kpiName,
      'value': value,
    };
  }

  factory KpiHistoryEntry.fromMap(Map<String, dynamic> map) {
    return KpiHistoryEntry(
      id: map['id'] as int?,
      date: DateTime.parse(map['date'] as String),
      kpiName: map['kpi_name'] as String,
      value: (map['value'] as num).toDouble(),
    );
  }
}
