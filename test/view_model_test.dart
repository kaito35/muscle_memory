import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muscle_memory/app/dependencies.dart';
import 'package:muscle_memory/features/body_record/data/memory_body_record_repository.dart';
import 'package:muscle_memory/features/body_record/domain/body_records.dart';
import 'package:muscle_memory/features/body_record/presentation/body_record_view_model.dart';

class FailingRepository extends MemoryBodyRecordRepository {
  bool fail = false;
  @override
  Future<void> saveWeight(WeightEntry entry) async {
    if (fail) throw Exception('simulated failure');
    return super.saveWeight(entry);
  }
}

void main() {
  test('保存失敗時に前の表示を保持し、再試行で保存できる', () async {
    final repository = FailingRepository();
    final container = ProviderContainer(overrides: [
      ...demoOverrides,
      bodyRecordRepositoryProvider.overrideWithValue(repository)
    ]);
    addTearDown(container.dispose);
    await container.read(bodyRecordViewModelProvider.future);
    final vm = container.read(bodyRecordViewModelProvider.notifier);
    expect(await vm.recordWeight(kg: 65, date: DateTime.now()), isNull);
    repository.fail = true;
    expect(await vm.recordWeight(kg: 64, date: DateTime.now()), isNotNull);
    expect(
        container
            .read(bodyRecordViewModelProvider)
            .requireValue
            .weights
            .single
            .weight
            .kg,
        65);
    expect(container.read(bodyRecordViewModelProvider).isLoading, isFalse);
    repository.fail = false;
    expect(await vm.recordWeight(kg: 64, date: DateTime.now()), isNull);
    expect(
        container.read(bodyRecordViewModelProvider).requireValue.weights.length,
        2);
  });
}
