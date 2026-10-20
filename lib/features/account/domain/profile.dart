import '../../../core/domain/domain_error.dart';

enum TrainingGoal {
  muscle('筋肉をつける'),
  fatLoss('体重を落とす'),
  strength('筋力を高める'),
  wellbeing('健康を維持する'),
  recomposition('体型を整える');

  const TrainingGoal(this.label);
  final String label;
}

class Profile {
  Profile(
      {required this.name,
      required this.age,
      required this.heightCm,
      required this.initialWeightKg,
      required this.goal,
      required this.daysPerWeek,
      required this.minutesPerSession,
      required this.experience,
      required this.location,
      this.limitations = ''}) {
    require(name.trim().isNotEmpty && name.length <= 40, '名前は1〜40文字で入力してください');
    require(age >= 18 && age <= 100, 'このデモでは年齢を18〜100歳で入力してください');
    require(heightCm.isFinite && heightCm >= 100 && heightCm <= 250,
        '身長は100〜250cmで入力してください');
    require(
        initialWeightKg.isFinite &&
            initialWeightKg > 0 &&
            initialWeightKg <= 500,
        '体重は0より大きく500kg以下で入力してください');
    require(daysPerWeek >= 1 && daysPerWeek <= 7, '頻度は週1〜7回で指定してください');
    require(minutesPerSession >= 15 && minutesPerSession <= 180,
        '時間は15〜180分で指定してください');
  }
  final String name;
  final int age;
  final double heightCm;
  final double initialWeightKg;
  final TrainingGoal goal;
  final int daysPerWeek;
  final int minutesPerSession;
  final String experience;
  final String location;
  final String limitations;
}
