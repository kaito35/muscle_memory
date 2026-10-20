import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/presentation/command_view_model.dart';
import '../application/training_use_cases.dart';
import '../domain/training.dart';

final trainingUseCasesProvider = Provider<TrainingUseCases>(
    (ref) => throw UnimplementedError('Composition rootで注入します'));
final trainingViewModelProvider =
    AsyncNotifierProvider<TrainingViewModel, TrainingData>(
        TrainingViewModel.new);

class TrainingViewModel extends CommandViewModel<TrainingData> {
  TrainingUseCases get _useCases => ref.read(trainingUseCasesProvider);
  @override
  Future<TrainingData> load() => _useCases.load();
  Future<String?> propose() => execute(_useCases.propose);
  Future<String?> adopt(String id) => execute(() => _useCases.adopt(id));
  Future<String?> editDraft(String dayId, ExerciseTarget target) =>
      execute(() => _useCases.editDraft(dayId, target));
  Future<String?> start(String dayId) => execute(() => _useCases.start(dayId));
  Future<String?> record(SetRecord record) =>
      execute(() => _useCases.record(record));
  Future<String?> complete(int fatigue, String memo) =>
      execute(() => _useCases.complete(fatigue, memo));
}
