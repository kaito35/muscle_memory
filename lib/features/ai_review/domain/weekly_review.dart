import '../../training/domain/training.dart';

class WeeklyReview {
  const WeeklyReview(
      {required this.week,
      required this.completedSessions,
      required this.plannedSessions,
      required this.recordedSets,
      required this.weightChange,
      required this.explanation,
      required this.proposal});
  final DateTime week;
  final int completedSessions;
  final int plannedSessions;
  final int recordedSets;
  final double? weightChange;
  final String explanation;
  final TrainingPlan proposal;
}

abstract interface class ReviewRepository {
  Future<List<WeeklyReview>> load();
  Future<void> save(WeeklyReview review);
  Future<void> clear();
}
