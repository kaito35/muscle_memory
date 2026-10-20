import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/presentation/command_view_model.dart';
import '../application/body_record_use_cases.dart';
import '../domain/body_records.dart';

final bodyRecordUseCasesProvider = Provider<BodyRecordUseCases>(
    (ref) => throw UnimplementedError('Composition rootで注入します'));
final bodyRecordViewModelProvider =
    AsyncNotifierProvider<BodyRecordViewModel, BodyRecords>(
        BodyRecordViewModel.new);

class BodyRecordViewModel extends CommandViewModel<BodyRecords> {
  BodyRecordUseCases get _useCases => ref.read(bodyRecordUseCasesProvider);
  @override
  Future<BodyRecords> load() => _useCases.load();
  Future<String?> recordWeight(
          {String? id,
          required double kg,
          double? bodyFat,
          required DateTime date,
          String memo = ''}) =>
      execute(() => _useCases.recordWeight(
          id: id, kg: kg, bodyFat: bodyFat, date: date, memo: memo));
  Future<String?> addPhoto(PhotoAngle angle, DateTime date, String memo) =>
      execute(() => _useCases.addPhoto(angle, date, memo));
  Future<String?> deleteWeight(String id) =>
      execute(() => _useCases.deleteWeight(id));
  Future<String?> deletePhoto(String id) =>
      execute(() => _useCases.deletePhoto(id));
}
