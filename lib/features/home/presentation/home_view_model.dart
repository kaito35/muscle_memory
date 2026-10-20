import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/domain/domain_error.dart';
import '../../account/domain/profile.dart';
import '../../account/presentation/account_view_model.dart';
import '../../body_record/domain/body_records.dart';
import '../../body_record/presentation/body_record_view_model.dart';
import '../../training/domain/training.dart';
import '../../training/presentation/training_view_model.dart';

class HomeSummary {
  const HomeSummary(
      {required this.profile,
      required this.records,
      required this.training,
      required this.now});
  final Profile? profile;
  final BodyRecords records;
  final TrainingData training;
  final DateTime now;
  TrainingPlan? get plan => training.planFor(now);
  PlanDay? get today =>
      plan?.days.where((d) => d.weekday == now.weekday).firstOrNull;
  int get completedThisWeek => training.sessions
      .where((s) => s.isComplete && !s.startedAt.isBefore(weekStart(now)))
      .length;
  List<WeightEntry> get recentWeights => records.weights
      .where((e) => !e.recordedAt
          .isBefore(dateOnly(now).subtract(const Duration(days: 29))))
      .toList();
}

/// 複数の機能の状態を、ホーム表示用の読み取りモデルへ合成する。
final homeViewModelProvider = FutureProvider<HomeSummary>((ref) async {
  final profile = ref.watch(accountViewModelProvider.future);
  final records = ref.watch(bodyRecordViewModelProvider.future);
  final training = ref.watch(trainingViewModelProvider.future);
  return HomeSummary(
      profile: await profile,
      records: await records,
      training: await training,
      now: DateTime.now());
});
