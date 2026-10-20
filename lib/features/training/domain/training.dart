import '../../../core/domain/domain_error.dart';

class ExerciseTarget {
  ExerciseTarget(
      {required this.id,
      required this.name,
      required this.kg,
      required this.reps,
      required this.sets}) {
    require(kg.isFinite && kg >= 0 && kg <= 500, '負荷は0〜500kgで入力してください');
    require(reps >= 1 && reps <= 100, '回数は1〜100回で入力してください');
    require(sets >= 1 && sets <= 10, 'セット数は1〜10で入力してください');
  }
  final String id;
  final String name;
  final double kg;
  final int reps;
  final int sets;
}

class PlanDay {
  PlanDay(
      {required this.id,
      required this.weekday,
      required this.name,
      required Iterable<ExerciseTarget> exercises})
      : exercises = List.unmodifiable(exercises) {
    require(weekday >= 1 && weekday <= 7, '曜日が不正です');
    require(this.exercises.isNotEmpty, '種目を1つ以上指定してください');
  }
  final String id;
  final int weekday;
  final String name;
  final List<ExerciseTarget> exercises;
}

class TrainingPlan {
  TrainingPlan(
      {required this.id,
      required this.week,
      required Iterable<PlanDay> days,
      required this.explanation})
      : days = List.unmodifiable(days) {
    require(this.days.isNotEmpty, 'プランにトレーニング日が必要です');
    require(this.days.map((d) => d.weekday).toSet().length == this.days.length,
        '曜日が重複しています');
  }
  final String id;
  final DateTime week;
  final List<PlanDay> days;
  final String explanation;

  TrainingPlan editExercise(String dayId, ExerciseTarget target) =>
      TrainingPlan(
          id: id,
          week: week,
          explanation: explanation,
          days: days.map((day) => day.id != dayId
              ? day
              : PlanDay(
                  id: day.id,
                  weekday: day.weekday,
                  name: day.name,
                  exercises: day.exercises
                      .map((e) => e.id == target.id ? target : e))));
}

class SetRecord {
  SetRecord(
      {required this.exerciseId,
      required this.number,
      required this.kg,
      required this.reps,
      required this.exertion,
      required this.recordedAt}) {
    require(kg.isFinite && kg >= 0 && kg <= 500, '負荷は0〜500kgで入力してください');
    require(reps >= 1 && reps <= 100, '回数は1〜100回で入力してください');
    require(exertion >= 1 && exertion <= 10, 'きつさは1〜10で指定してください');
    require(number >= 1, 'セット番号が不正です');
  }
  final String exerciseId;
  final int number;
  final double kg;
  final int reps;
  final int exertion;
  final DateTime recordedAt;
}

/// セッションが集約ルート。予定のスナップショットと実績を別に持つ。
class TrainingSession {
  TrainingSession(
      {required this.id,
      required this.planId,
      required this.dayName,
      required this.startedAt,
      required Iterable<ExerciseTarget> targets,
      Iterable<SetRecord> sets = const [],
      this.completedAt,
      this.fatigue,
      this.memo = ''})
      : targets = List.unmodifiable(targets),
        sets = List.unmodifiable(sets);
  final String id;
  final String planId;
  final String dayName;
  final DateTime startedAt;
  final DateTime? completedAt;
  final List<ExerciseTarget> targets;
  final List<SetRecord> sets;
  final int? fatigue;
  final String memo;
  bool get isComplete => completedAt != null;
  int get plannedSets => targets.fold(0, (sum, e) => sum + e.sets);

  TrainingSession record(SetRecord record) {
    require(!isComplete, '完了済みのトレーニングは変更できません');
    final target = targets.where((e) => e.id == record.exerciseId).firstOrNull;
    require(target != null && record.number <= target.sets, '対象のセットが見つかりません');
    return TrainingSession(
        id: id,
        planId: planId,
        dayName: dayName,
        startedAt: startedAt,
        targets: targets,
        sets: [
          ...sets.where((s) => !(s.exerciseId == record.exerciseId &&
              s.number == record.number)),
          record
        ]);
  }

  TrainingSession complete(DateTime at, int fatigue, String memo) {
    require(!isComplete, 'すでに完了しています');
    require(sets.isNotEmpty, '1セット以上記録してから完了してください');
    require(fatigue >= 1 && fatigue <= 10, '疲労度は1〜10で指定してください');
    require(memo.length <= 500, 'メモは500文字以内で入力してください');
    return TrainingSession(
        id: id,
        planId: planId,
        dayName: dayName,
        startedAt: startedAt,
        targets: targets,
        sets: sets,
        completedAt: at,
        fatigue: fatigue,
        memo: memo.trim());
  }
}

class TrainingData {
  TrainingData(
      {Iterable<TrainingPlan> plans = const [],
      this.draft,
      Iterable<TrainingSession> sessions = const []})
      : plans = List.unmodifiable(plans),
        sessions = List.unmodifiable(sessions);
  final List<TrainingPlan> plans;
  final TrainingPlan? draft;
  final List<TrainingSession> sessions;
  TrainingPlan? planFor(DateTime date) =>
      plans.reversed.where((p) => sameDay(p.week, weekStart(date))).firstOrNull;
  TrainingSession? get activeSession =>
      sessions.where((s) => !s.isComplete).firstOrNull;
  TrainingData withDraft(TrainingPlan plan) =>
      TrainingData(plans: plans, draft: plan, sessions: sessions);
  TrainingData adopt(String draftId) {
    require(draft != null && draft!.id == draftId, '提案が更新されています。もう一度確認してください');
    return TrainingData(plans: [...plans, draft!], sessions: sessions);
  }

  TrainingData saveSession(TrainingSession session) => TrainingData(
      plans: plans,
      draft: draft,
      sessions: [...sessions.where((s) => s.id != session.id), session]);
}
