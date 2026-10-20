import '../../../core/domain/domain_error.dart';
import '../domain/body_record_repository.dart';
import '../domain/body_records.dart';
import '../domain/photo_source.dart';

class BodyRecordUseCases {
  BodyRecordUseCases(this.repository, this.photoSource);
  final BodyRecordRepository repository;
  final PhotoSource photoSource;
  Future<BodyRecords> load() => repository.load();
  Future<void> recordWeight(
      {String? id,
      required double kg,
      double? bodyFat,
      required DateTime date,
      String memo = ''}) async {
    require(!date.isAfter(DateTime.now()), '未来の日時には記録できません');
    return repository.saveWeight(WeightEntry(
        id: id ?? newId(),
        weight: Weight(kg),
        recordedAt: date,
        bodyFat: bodyFat,
        memo: memo.trim()));
  }

  Future<void> addPhoto(PhotoAngle angle, DateTime date, String memo) async {
    require(!date.isAfter(DateTime.now()), '未来の日時には記録できません');
    final bytes = await photoSource.pick();
    if (bytes == null) return;
    await repository.savePhoto(BodyPhoto(
        id: newId(),
        bytes: bytes,
        recordedAt: date,
        angle: angle,
        memo: memo.trim()));
  }

  Future<void> deleteWeight(String id) => repository.deleteWeight(id);
  Future<void> deletePhoto(String id) => repository.deletePhoto(id);
}
