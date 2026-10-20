import 'training.dart';

abstract interface class TrainingRepository {
  Future<TrainingData> load();
  Future<void> save(TrainingData data);
  Future<void> clear();
}
