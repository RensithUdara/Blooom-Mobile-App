class WellnessLog {
  const WellnessLog({
    this.id,
    required this.date,
    required this.mood,
    required this.symptoms,
    this.weightKg,
    this.temperatureC,
    this.sleepHours,
    this.waterGlasses,
    this.energyLevel = 3,
    this.hadSex = false,
    this.protectedSex = true,
    this.notes = '',
  });

  final int? id;
  final DateTime date;
  final String mood;
  final List<String> symptoms;
  final double? weightKg;
  final double? temperatureC;
  final double? sleepHours;
  final int? waterGlasses;
  final int energyLevel;
  final bool hadSex;
  final bool protectedSex;
  final String notes;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'mood': mood,
      'symptoms': symptoms.join('|'),
      'weight_kg': weightKg,
      'temperature_c': temperatureC,
      'sleep_hours': sleepHours,
      'water_glasses': waterGlasses,
      'energy_level': energyLevel,
      'had_sex': hadSex ? 1 : 0,
      'protected_sex': protectedSex ? 1 : 0,
      'notes': notes,
    };
  }

  factory WellnessLog.fromMap(Map<String, Object?> map) {
    final symptomText = map['symptoms'] as String? ?? '';
    return WellnessLog(
      id: map['id'] as int?,
      date: DateTime.parse(map['date'] as String),
      mood: map['mood'] as String,
      symptoms: symptomText.isEmpty ? const [] : symptomText.split('|'),
      weightKg: (map['weight_kg'] as num?)?.toDouble(),
      temperatureC: (map['temperature_c'] as num?)?.toDouble(),
      sleepHours: (map['sleep_hours'] as num?)?.toDouble(),
      waterGlasses: map['water_glasses'] as int?,
      energyLevel: map['energy_level'] as int? ?? 3,
      hadSex: (map['had_sex'] as int? ?? 0) == 1,
      protectedSex: (map['protected_sex'] as int? ?? 1) == 1,
      notes: map['notes'] as String? ?? '',
    );
  }
}
