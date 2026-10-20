import '../domain/body_record_repository.dart';
import '../domain/body_records.dart';

class MemoryBodyRecordRepository implements BodyRecordRepository {
  final Map<String, WeightEntry> _weights = {};
  final Map<String, BodyPhoto> _photos = {};
  @override
  Future<BodyRecords> load() async =>
      BodyRecords(weights: _weights.values, photos: _photos.values);
  @override
  Future<void> saveWeight(WeightEntry entry) async =>
      _weights[entry.id] = entry;
  @override
  Future<void> deleteWeight(String id) async => _weights.remove(id);
  @override
  Future<void> savePhoto(BodyPhoto photo) async => _photos[photo.id] = photo;
  @override
  Future<void> deletePhoto(String id) async => _photos.remove(id);
  @override
  Future<void> clear() async {
    _weights.clear();
    _photos.clear();
  }
}
