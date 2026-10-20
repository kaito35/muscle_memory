import '../domain/training.dart';
import '../domain/training_repository.dart';

class MemoryTrainingRepository implements TrainingRepository {
  TrainingData _data = TrainingData();
  @override
  Future<TrainingData> load() async => _data;
  @override
  Future<void> save(TrainingData data) async => _data = data;
  @override
  Future<void> clear() async => _data = TrainingData();
}
