import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muscle_memory/app/app.dart';
import 'package:muscle_memory/app/dependencies.dart';
import 'package:muscle_memory/app/router.dart';
import 'package:muscle_memory/features/account/presentation/account_view_model.dart';
import 'package:muscle_memory/features/body_record/presentation/body_record_view_model.dart';
import 'package:muscle_memory/features/training/presentation/training_view_model.dart';
import 'support/prototype_fixture.dart';

Future<void> tapText(WidgetTester tester, String label) async {
  final finder = find.text(label);
  if (finder.evaluate().isEmpty) {
    await tester.drag(find.byType(ListView).first, const Offset(0, 5000));
    await tester.pumpAndSettle();
    for (var i = 0; i < 40 && finder.evaluate().isEmpty; i++) {
      await tester.drag(find.byType(ListView).first, const Offset(0, -300));
      await tester.pumpAndSettle();
    }
  }
  expect(finder, findsWidgets, reason: label);
  await Scrollable.ensureVisible(tester.element(finder.first), alignment: 0.5);
  await tester.pumpAndSettle();
  await tester.tap(finder.first);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('プロフィール → プラン採用 → セット記録 → 体重 → レビュー → 全削除', (tester) async {
    tester.view.physicalSize = const Size(430, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final container = ProviderContainer(overrides: demoOverrides);
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
        container: container, child: const BodymakeApp()));
    await tester.pumpAndSettle();
    await tapText(tester, 'デモをはじめる');
    await tapText(tester, 'プロフィールを保存して進む');
    expect(find.text('一回ずつ、強くなる。'), findsOneWidget);
    await tapText(tester, 'サンプルプランを作成');
    await tapText(tester, 'このプランを採用する');
    await tapText(tester, 'このメニューを開始');
    await tapText(tester, '記録');
    await tester.enterText(find.byType(TextFormField).first, '12.5');
    await tapText(tester, '保存する');
    expect(
        container
            .read(trainingViewModelProvider)
            .requireValue
            .activeSession!
            .sets
            .single
            .kg,
        12.5);
    await tapText(tester, 'トレーニングを完了');
    await tapText(tester, '完了して保存');
    expect(
        container
            .read(trainingViewModelProvider)
            .requireValue
            .sessions
            .single
            .isComplete,
        isTrue);
    await tapText(tester, 'からだ');
    await tapText(tester, '体重を記録');
    await tester.enterText(find.byType(TextFormField).first, '0');
    await tapText(tester, '保存する');
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(
        container.read(bodyRecordViewModelProvider).requireValue.weights.length,
        1);
    await tester.enterText(find.byType(TextFormField).first, '64.2');
    await tapText(tester, '保存する');
    expect(
        container.read(bodyRecordViewModelProvider).requireValue.weights.length,
        2);
    await tapText(tester, 'カレンダー');
    expect(find.text('64.2 kg'), findsOneWidget);
    await tapText(tester, 'レビュー');
    await tapText(tester, '今週のレビューを作成');
    expect(find.text('トレーニング 1回 / 予定 3回'), findsOneWidget);
    await tapText(tester, '来週の提案を確認する');
    await tapText(tester, 'このプランを採用する');
    expect(
        container.read(trainingViewModelProvider).requireValue.plans.length, 2);
    await tester.tap(find.byTooltip('プロフィールと設定'));
    await tester.pumpAndSettle();
    await tapText(tester, 'デモデータをすべて削除');
    await tapText(tester, '削除する');
    expect(
        container.read(routerProvider).routeInformationProvider.value.uri.path,
        '/welcome');
    expect(await container.read(accountRepositoryProvider).load(), isNull);
    expect((await container.read(bodyRecordRepositoryProvider).load()).weights,
        isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('幅320pxで主要画面を表示し、ホームにも体重の変更を反映する', (tester) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final container = ProviderContainer(overrides: demoOverrides);
    addTearDown(container.dispose);
    await container.read(accountUseCasesProvider).register(exampleProfile());
    await container.read(accountViewModelProvider.future);
    await tester.pumpWidget(UncontrolledProviderScope(
        container: container, child: const BodymakeApp()));
    container.read(routerProvider).go('/home');
    await tester.pumpAndSettle();
    expect(find.text('65.0'), findsOneWidget);
    for (final route in [
      '/training',
      '/body',
      '/calendar',
      '/review',
      '/home'
    ]) {
      container.read(routerProvider).go(route);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: route);
    }
    await container
        .read(bodyRecordViewModelProvider.notifier)
        .recordWeight(kg: 63.2, date: DateTime.now());
    await tester.pumpAndSettle();
    expect(find.text('63.2'), findsOneWidget);
  });

  testWidgets('未登録の保護画面への遷移を開始画面へ戻す', (tester) async {
    final container = ProviderContainer(overrides: demoOverrides);
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
        container: container, child: const BodymakeApp()));
    await tester.pumpAndSettle();
    container.read(routerProvider).go('/training');
    await tester.pumpAndSettle();
    expect(
        container.read(routerProvider).routeInformationProvider.value.uri.path,
        '/welcome');
  });

  testWidgets('画像選択アダプターを差し替えて写真追加と削除を操作できる', (tester) async {
    tester.view.physicalSize = const Size(430, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final bytes = base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+a7WQAAAAASUVORK5CYII=');
    final container = ProviderContainer(overrides: [
      ...demoOverrides,
      photoSourceProvider.overrideWithValue(FakePhotoSource(bytes)),
    ]);
    addTearDown(container.dispose);
    await container.read(accountUseCasesProvider).register(exampleProfile());
    await container.read(accountViewModelProvider.future);
    await tester.pumpWidget(UncontrolledProviderScope(
        container: container, child: const BodymakeApp()));
    container.read(routerProvider).go('/body');
    await tester.pumpAndSettle();
    await tapText(tester, '写真');
    await tapText(tester, '写真を追加');
    await tapText(tester, '画像を選んで保存');
    expect(
        container.read(bodyRecordViewModelProvider).requireValue.photos.length,
        1);
    await tester.ensureVisible(find.byTooltip('写真を削除'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('写真を削除'));
    await tester.pumpAndSettle();
    await tapText(tester, '削除する');
    expect(container.read(bodyRecordViewModelProvider).requireValue.photos,
        isEmpty);
    expect(tester.takeException(), isNull);
  });
}
