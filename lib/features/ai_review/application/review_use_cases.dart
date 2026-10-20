import '../../../core/domain/domain_error.dart';
import '../../body_record/domain/body_record_repository.dart';
import '../../training/domain/training.dart';
import '../../training/domain/training_repository.dart';
import '../domain/weekly_review.dart';

class ReviewUseCases {
  ReviewUseCases(this.reviews, this.training, this.records);
  final ReviewRepository reviews;
  final TrainingRepository training;
  final BodyRecordRepository records;
  Future<List<WeeklyReview>> load() => reviews.load();
  Future<void> generate() async {
    final now = DateTime.now();
    final week = weekStart(now);
    final data = await training.load();
    final plan = data.planFor(now);
    require(plan != null, '今週のプランを採用してからレビューを作成してください');
    final sessions = data.sessions
        .where((s) =>
            s.isComplete &&
            !s.startedAt.isBefore(week) &&
            !s.startedAt.isAfter(now))
        .toList();
    final weights = (await records.load())
        .weights
        .where(
            (w) => !w.recordedAt.isBefore(week) && !w.recordedAt.isAfter(now))
        .toList();
    final tired = sessions.any((s) => (s.fatigue ?? 0) >= 8);
    final explanation = tired
        ? '疲労度8以上の記録があります。次週はセット数を1つ減らす案を表示しています。痛みがある場合は運動を中断し、専門家に相談してください。'
        : '今週の記録を振り返り、次週も同じ負荷・回数を維持する案です。回数やフォームに余裕があるか、実際の体調を確認してください。';
    final id = newId();
    final draft = TrainingPlan(
        id: id,
        week: week.add(const Duration(days: 7)),
        explanation: explanation,
        days: plan!.days.map((d) => PlanDay(
            id: '$id-${d.id}',
            weekday: d.weekday,
            name: d.name,
            exercises: d.exercises.map((e) => ExerciseTarget(
                id: '$id-${e.id}',
                name: e.name,
                kg: e.kg,
                reps: e.reps,
                sets: tired && e.sets > 1 ? e.sets - 1 : e.sets)))));
    await reviews.save(WeeklyReview(
        week: week,
        completedSessions: sessions.length,
        plannedSessions: plan.days.length,
        recordedSets: sessions.fold(0, (sum, s) => sum + s.sets.length),
        weightChange: weights.length < 2
            ? null
            : weights.first.weight.kg - weights.last.weight.kg,
        explanation: explanation,
        proposal: draft));
  }

  Future<void> propose(WeeklyReview review) async {
    final data = await training.load();
    require(
        !data.plans.any((p) => p.id == review.proposal.id), 'この提案はすでに採用済みです');
    await training.save(data.withDraft(review.proposal));
  }
}
