import 'body_records.dart';

abstract interface class BodyRecordRepository {
  Future<BodyRecords> load();
  Future<void> saveWeight(WeightEntry entry);
  Future<void> deleteWeight(String id);
  Future<void> savePhoto(BodyPhoto photo);
  Future<void> deletePhoto(String id);
  Future<void> clear();
}
