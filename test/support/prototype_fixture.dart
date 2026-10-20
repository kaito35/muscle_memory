import 'dart:typed_data';
import 'package:muscle_memory/features/account/application/account_use_cases.dart';
import 'package:muscle_memory/features/account/data/memory_account_repository.dart';
import 'package:muscle_memory/features/account/domain/profile.dart';
import 'package:muscle_memory/features/ai_review/application/review_use_cases.dart';
import 'package:muscle_memory/features/ai_review/data/memory_review_repository.dart';
import 'package:muscle_memory/features/body_record/application/body_record_use_cases.dart';
import 'package:muscle_memory/features/body_record/data/memory_body_record_repository.dart';
import 'package:muscle_memory/features/body_record/domain/photo_source.dart';
import 'package:muscle_memory/features/training/application/training_use_cases.dart';
import 'package:muscle_memory/features/training/data/demo_plan_generator.dart';
import 'package:muscle_memory/features/training/data/memory_training_repository.dart';

Profile exampleProfile() => Profile(
    name: 'テスト',
    age: 30,
    heightCm: 170,
    initialWeightKg: 65,
    goal: TrainingGoal.muscle,
    daysPerWeek: 3,
    minutesPerSession: 45,
    experience: '初心者',
    location: 'ジム');

class FakePhotoSource implements PhotoSource {
  FakePhotoSource([this.bytes]);
  final Uint8List? bytes;
  @override
  Future<Uint8List?> pick() async => bytes;
}

class PrototypeFixture {
  final accounts = MemoryAccountRepository();
  final records = MemoryBodyRecordRepository();
  final training = MemoryTrainingRepository();
  final reviews = MemoryReviewRepository();
  late final accountCases =
      AccountUseCases(accounts, records, training, reviews);
  late final trainingCases =
      TrainingUseCases(training, accounts, DemoPlanGenerator());
  late final recordCases = BodyRecordUseCases(records, FakePhotoSource());
  late final reviewCases = ReviewUseCases(reviews, training, records);
  Future<void> initialize() async {
    await accountCases.register(exampleProfile());
    await trainingCases.propose();
    await trainingCases.adopt((await training.load()).draft!.id);
  }
}
