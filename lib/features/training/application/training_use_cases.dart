import '../../../core/domain/domain_error.dart';
import '../../account/domain/account_repository.dart';
import '../domain/plan_generator.dart';
import '../domain/training.dart';
import '../domain/training_repository.dart';

class TrainingUseCases {
  TrainingUseCases(this.repository, this.accounts, this.generator);
  final TrainingRepository repository;
  final AccountRepository accounts;
  final PlanGenerator generator;
  Future<TrainingData> load() => repository.load();
  Future<void> propose() async {
    final profile = await accounts.load();
    require(profile != null, '先にプロフィールを設定してください');
    final data = await repository.load();
    final draft = await generator.generate(profile!, DateTime.now());
    await repository.save(data.withDraft(draft));
  }

  Future<void> editDraft(String dayId, ExerciseTarget target) async {
    final data = await repository.load();
    require(data.draft != null, '編集中の提案がありません');
    await repository
        .save(data.withDraft(data.draft!.editExercise(dayId, target)));
  }

  Future<void> adopt(String draftId) async {
    final data = await repository.load();
    await repository.save(data.adopt(draftId));
  }

  Future<void> start(String dayId) async {
    final data = await repository.load();
    require(data.activeSession == null, '進行中のトレーニングを先に完了してください');
    final plan = data.planFor(DateTime.now());
    final day = plan?.days.where((d) => d.id == dayId).firstOrNull;
    require(day != null, '今週の採用済みプランを選択してください');
    await repository.save(data.saveSession(TrainingSession(
        id: newId(),
        planId: plan!.id,
        dayName: day!.name,
        startedAt: DateTime.now(),
        targets: day.exercises)));
  }

  Future<void> record(SetRecord record) async {
    final data = await repository.load();
    require(data.activeSession != null, '進行中のトレーニングがありません');
    await repository.save(data.saveSession(data.activeSession!.record(record)));
  }

  Future<void> complete(int fatigue, String memo) async {
    final data = await repository.load();
    require(data.activeSession != null, '進行中のトレーニングがありません');
    await repository.save(data.saveSession(
        data.activeSession!.complete(DateTime.now(), fatigue, memo)));
  }
}
