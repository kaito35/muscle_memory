import '../../../core/domain/domain_error.dart';
import '../../account/domain/profile.dart';
import '../domain/plan_generator.dart';
import '../domain/training.dart';

/// 固定テンプレートによるデモ。AI・医療判断・個別の負荷推定は行わない。
class DemoPlanGenerator implements PlanGenerator {
  @override
  Future<TrainingPlan> generate(Profile profile, DateTime week) async {
    final id = newId();
    final home = profile.location == '自宅';
    final names = home
        ? ['スクワット', 'プッシュアップ', 'ヒップリフト']
        : ['レッグプレス', 'チェストプレス', 'ラットプルダウン'];
    return TrainingPlan(
        id: id,
        week: weekStart(week),
        explanation:
            '週${profile.daysPerWeek}回・${profile.location}の入力を反映したサンプルです。'
            '負荷0kgは未設定を表します。器具や体調に合わせて編集してください。'
            '${profile.limitations.isEmpty ? '' : '\n痛み・制限の入力があります。このデモでは安全性や種目の適否を判定しません。'}',
        days: List.generate(
            profile.daysPerWeek,
            (index) => PlanDay(
                id: '$id-day-$index',
                weekday: 1 + (index * 7 ~/ profile.daysPerWeek),
                name: '全身トレーニング ${String.fromCharCode(65 + index)}',
                exercises: List.generate(
                    names.length,
                    (i) => ExerciseTarget(
                        id: '$id-$index-$i',
                        name: names[i],
                        kg: 0,
                        reps: 10,
                        sets: profile.minutesPerSession <= 30 ? 2 : 3)))));
  }
}
