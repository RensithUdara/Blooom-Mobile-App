class PeriodEntry {
  const PeriodEntry({
    this.id,
    required this.startDate,
    required this.endDate,
    required this.flowIntensity,
    this.notes = '',
  });

  final int? id;
  final DateTime startDate;
  final DateTime endDate;
  final int flowIntensity;
  final String notes;

  int get periodLength => endDate.difference(startDate).inDays + 1;

  PeriodEntry copyWith({
    int? id,
    DateTime? startDate,
    DateTime? endDate,
    int? flowIntensity,
    String? notes,
  }) {
    return PeriodEntry(
      id: id ?? this.id,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      flowIntensity: flowIntensity ?? this.flowIntensity,
      notes: notes ?? this.notes,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'flow_intensity': flowIntensity,
      'notes': notes,
    };
  }

  factory PeriodEntry.fromMap(Map<String, Object?> map) {
    return PeriodEntry(
      id: map['id'] as int?,
      startDate: DateTime.parse(map['start_date'] as String),
      endDate: DateTime.parse(map['end_date'] as String),
      flowIntensity: map['flow_intensity'] as int,
      notes: map['notes'] as String? ?? '',
    );
  }
}
