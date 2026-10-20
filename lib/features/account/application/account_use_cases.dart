import '../../../core/domain/domain_error.dart';
import '../../ai_review/domain/weekly_review.dart';
import '../../body_record/domain/body_record_repository.dart';
import '../../body_record/domain/body_records.dart';
import '../../training/domain/training_repository.dart';
import '../domain/account_repository.dart';
import '../domain/profile.dart';

class AccountUseCases {
  AccountUseCases(this.accounts, this.records, this.training, this.reviews);
  final AccountRepository accounts;
  final BodyRecordRepository records;
  final TrainingRepository training;
  final ReviewRepository reviews;
  Future<Profile?> load() => accounts.load();
  Future<void> register(Profile profile) async {
    await records.saveWeight(WeightEntry(
        id: newId(),
        weight: Weight(profile.initialWeightKg),
        recordedAt: DateTime.now(),
        memo: 'スタート時の体重'));
    await accounts.save(profile);
  }

  Future<void> deleteAll() async {
    await records.clear();
    await training.clear();
    await reviews.clear();
    await accounts.clear();
  }
}
