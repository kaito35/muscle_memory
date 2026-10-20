import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/domain/domain_error.dart';
import '../../body_record/domain/body_records.dart';
import '../../body_record/presentation/body_record_view_model.dart';
import '../../training/domain/training.dart';
import '../../training/presentation/training_view_model.dart';

class CalendarSummary {
  const CalendarSummary(this.records, this.training);
  final BodyRecords records;
  final TrainingData training;
  List<WeightEntry> weightsOn(DateTime date) =>
      records.weights.where((e) => sameDay(e.recordedAt, date)).toList();
  List<BodyPhoto> photosOn(DateTime date) =>
      records.photos.where((e) => sameDay(e.recordedAt, date)).toList();
  List<TrainingSession> sessionsOn(DateTime date) =>
      training.sessions.where((s) => sameDay(s.startedAt, date)).toList();
}

final calendarViewModelProvider = FutureProvider<CalendarSummary>((ref) async {
  final records = ref.watch(bodyRecordViewModelProvider.future);
  final training = ref.watch(trainingViewModelProvider.future);
  return CalendarSummary(await records, await training);
});
