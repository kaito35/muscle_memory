import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/account/application/account_use_cases.dart';
import '../features/account/data/memory_account_repository.dart';
import '../features/account/domain/account_repository.dart';
import '../features/account/presentation/account_view_model.dart';
import '../features/ai_review/application/review_use_cases.dart';
import '../features/ai_review/data/memory_review_repository.dart';
import '../features/ai_review/domain/weekly_review.dart';
import '../features/ai_review/presentation/review_view_model.dart';
import '../features/body_record/application/body_record_use_cases.dart';
import '../features/body_record/data/gallery_photo_source.dart';
import '../features/body_record/data/memory_body_record_repository.dart';
import '../features/body_record/domain/body_record_repository.dart';
import '../features/body_record/domain/photo_source.dart';
import '../features/body_record/presentation/body_record_view_model.dart';
import '../features/training/application/training_use_cases.dart';
import '../features/training/data/demo_plan_generator.dart';
import '../features/training/data/memory_training_repository.dart';
import '../features/training/domain/training_repository.dart';
import '../features/training/presentation/training_view_model.dart';

// 具象実装を知るのはComposition rootのみ。API化はここの差し替えから始める。
final accountRepositoryProvider =
    Provider<AccountRepository>((ref) => MemoryAccountRepository());
final bodyRecordRepositoryProvider =
    Provider<BodyRecordRepository>((ref) => MemoryBodyRecordRepository());
final trainingRepositoryProvider =
    Provider<TrainingRepository>((ref) => MemoryTrainingRepository());
final reviewRepositoryProvider =
    Provider<ReviewRepository>((ref) => MemoryReviewRepository());
final photoSourceProvider =
    Provider<PhotoSource>((ref) => GalleryPhotoSource());

final demoOverrides = [
  accountUseCasesProvider.overrideWith((ref) => AccountUseCases(
      ref.watch(accountRepositoryProvider),
      ref.watch(bodyRecordRepositoryProvider),
      ref.watch(trainingRepositoryProvider),
      ref.watch(reviewRepositoryProvider))),
  bodyRecordUseCasesProvider.overrideWith((ref) => BodyRecordUseCases(
      ref.watch(bodyRecordRepositoryProvider), ref.watch(photoSourceProvider))),
  trainingUseCasesProvider.overrideWith((ref) => TrainingUseCases(
      ref.watch(trainingRepositoryProvider),
      ref.watch(accountRepositoryProvider),
      DemoPlanGenerator())),
  reviewUseCasesProvider.overrideWith((ref) => ReviewUseCases(
      ref.watch(reviewRepositoryProvider),
      ref.watch(trainingRepositoryProvider),
      ref.watch(bodyRecordRepositoryProvider))),
];
