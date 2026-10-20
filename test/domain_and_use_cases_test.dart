import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:muscle_memory/core/domain/domain_error.dart';
import 'package:muscle_memory/features/body_record/application/body_record_use_cases.dart';
import 'package:muscle_memory/features/body_record/domain/body_records.dart';
import 'package:muscle_memory/features/training/domain/training.dart';
import 'support/prototype_fixture.dart';

void main() {
  test('体重と体脂肪率の不正値をドメインで拒否する', () {
    for (final value in [0.0, -1.0, double.nan, double.infinity, 501.0]) {
      expect(() => Weight(value), throwsA(isA<DomainError>()));
    }
    expect(Weight(65), Weight(65));
    expect(
        () => WeightEntry(
            id: 'w',
            weight: Weight(65),
            recordedAt: DateTime.now(),
            bodyFat: 100),
        throwsA(isA<DomainError>()));
  });

  test('同日の複数測定を保持し、修正ではIDを増やさない', () async {
    final f = PrototypeFixture();
    final date = DateTime(2026, 1, 1, 8);
    await f.recordCases.recordWeight(id: 'morning', kg: 65, date: date);
    await f.recordCases.recordWeight(
        id: 'evening', kg: 66, date: date.add(const Duration(hours: 10)));
    await f.recordCases.recordWeight(id: 'morning', kg: 64.5, date: date);
    final data = await f.records.load();
    expect(data.weights.length, 2);
    expect(data.weights.first.id, 'evening');
    expect(data.weights.last.weight.kg, 64.5);
    await f.recordCases.deleteWeight('evening');
    expect((await f.records.load()).weights.single.id, 'morning');
  });

  test('未来の測定を拒否し、保存済みデータを壊さない', () async {
    final f = PrototypeFixture();
    await f.accountCases.register(exampleProfile());
    await expectLater(
        f.recordCases.recordWeight(
            kg: 60, date: DateTime.now().add(const Duration(days: 1))),
        throwsA(isA<DomainError>()));
    expect((await f.records.load()).weights.length, 1);
  });

  test('提案だけでは採用せず、古い提案IDも採用できない', () async {
    final f = PrototypeFixture();
    await f.accountCases.register(exampleProfile());
    await f.trainingCases.propose();
    expect((await f.training.load()).plans, isEmpty);
    await expectLater(
        f.trainingCases.adopt('stale'), throwsA(isA<DomainError>()));
    final draft = (await f.training.load()).draft!;
    await f.trainingCases.adopt(draft.id);
    expect((await f.training.load()).planFor(DateTime.now())!.id, draft.id);
    await expectLater(
        f.trainingCases.adopt(draft.id), throwsA(isA<DomainError>()));
  });

  test('セット保存は重複せず、予定と実績を分離し、完了後は変更できない', () async {
    final f = PrototypeFixture();
    await f.initialize();
    final plan = (await f.training.load()).planFor(DateTime.now())!;
    await f.trainingCases.start(plan.days.first.id);
    await expectLater(
        f.trainingCases.start(plan.days.last.id), throwsA(isA<DomainError>()));
    final target = plan.days.first.exercises.first;
    SetRecord record(double kg) => SetRecord(
        exerciseId: target.id,
        number: 1,
        kg: kg,
        reps: 8,
        exertion: 7,
        recordedAt: DateTime.now());
    await f.trainingCases.record(record(10));
    await f.trainingCases.record(record(12));
    final active = (await f.training.load()).activeSession!;
    expect(active.sets.length, 1);
    expect(active.sets.single.kg, 12);
    expect(active.targets.first.kg, 0);
    await f.trainingCases.complete(8, '疲労が強い');
    final finished = (await f.training.load()).sessions.single;
    expect(() => finished.record(record(15)), throwsA(isA<DomainError>()));
    expect(finished.memo, '疲労が強い');
    expect(() => finished.targets.clear(), throwsUnsupportedError);
  });

  test('プランの変更後も開始済みセッションの予定は保持する', () async {
    final f = PrototypeFixture();
    await f.initialize();
    final old = (await f.training.load()).planFor(DateTime.now())!;
    await f.trainingCases.start(old.days.first.id);
    await f.trainingCases.propose();
    final draft = (await f.training.load()).draft!;
    final target = draft.days.first.exercises.first;
    await f.trainingCases.editDraft(
        draft.days.first.id,
        ExerciseTarget(
            id: target.id, name: target.name, kg: 20, reps: 8, sets: 2));
    await f.trainingCases.adopt(draft.id);
    final data = await f.training.load();
    expect(data.planFor(DateTime.now())!.days.first.exercises.first.kg, 20);
    expect(data.activeSession!.targets.first.kg, 0);
    expect(data.activeSession!.planId, old.id);
  });

  test('未記録での完了と不正なセット番号を拒否する', () async {
    final f = PrototypeFixture();
    await f.initialize();
    final day = (await f.training.load()).planFor(DateTime.now())!.days.first;
    await f.trainingCases.start(day.id);
    await expectLater(
        f.trainingCases.complete(5, ''), throwsA(isA<DomainError>()));
    await expectLater(
        f.trainingCases.record(SetRecord(
            exerciseId: day.exercises.first.id,
            number: 99,
            kg: 0,
            reps: 10,
            exertion: 6,
            recordedAt: DateTime.now())),
        throwsA(isA<DomainError>()));
  });

  test('疲労を次週案に反映し、明示的な採用でも今週のプランを変えない', () async {
    final f = PrototypeFixture();
    await f.initialize();
    final plan = (await f.training.load()).planFor(DateTime.now())!;
    await f.trainingCases.start(plan.days.first.id);
    await f.trainingCases.record(SetRecord(
        exerciseId: plan.days.first.exercises.first.id,
        number: 1,
        kg: 0,
        reps: 10,
        exertion: 8,
        recordedAt: DateTime.now()));
    await f.trainingCases.complete(8, '');
    await f.reviewCases.generate();
    final review = (await f.reviews.load()).single;
    expect(review.completedSessions, 1);
    expect(review.proposal.days.first.exercises.first.sets, 2);
    expect((await f.training.load()).draft, isNull);
    await f.reviewCases.propose(review);
    expect((await f.training.load()).planFor(review.proposal.week), isNull);
    await f.trainingCases.adopt(review.proposal.id);
    expect((await f.training.load()).planFor(review.proposal.week)!.id,
        review.proposal.id);
    expect((await f.training.load()).planFor(DateTime.now())!.id, plan.id);
    await expectLater(
        f.reviewCases.propose(review), throwsA(isA<DomainError>()));
  });

  test('写真キャンセルは保存せず、写真と全記録を削除できる', () async {
    final f = PrototypeFixture();
    await f.initialize();
    await f.recordCases.addPhoto(PhotoAngle.front, DateTime.now(), '');
    expect((await f.records.load()).photos, isEmpty);
    final photos = BodyRecordUseCases(
        f.records, FakePhotoSource(Uint8List.fromList([1, 2, 3])));
    await photos.addPhoto(PhotoAngle.front, DateTime.now(), '確認');
    expect((await f.records.load()).photos.length, 1);
    await f.reviewCases.generate();
    await f.accountCases.deleteAll();
    expect(await f.accounts.load(), isNull);
    expect((await f.records.load()).photos, isEmpty);
    expect((await f.records.load()).weights, isEmpty);
    expect((await f.training.load()).plans, isEmpty);
    expect(await f.reviews.load(), isEmpty);
  });
}
