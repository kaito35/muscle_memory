import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/domain_error.dart';

/// ViewModel共通の非同期状態。失敗しても入力済みのデータを捨てない。
abstract class CommandViewModel<T> extends AsyncNotifier<T> {
  Future<T> load();
  @override
  Future<T> build() => load();

  Future<String?> execute(Future<void> Function() command) async {
    if (state.isLoading) return '処理が完了するまでお待ちください';
    final previous = state;
    state = AsyncLoading<T>().copyWithPrevious(previous);
    try {
      await command();
      state = AsyncData(await load());
      return null;
    } on DomainError catch (error) {
      state = previous;
      return error.message;
    } catch (_) {
      state = previous;
      return '処理できませんでした。もう一度お試しください。写真の場合はアクセス許可も確認してください。';
    }
  }
}
