import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/presentation/command_view_model.dart';
import '../application/account_use_cases.dart';
import '../domain/profile.dart';

final accountUseCasesProvider = Provider<AccountUseCases>(
    (ref) => throw UnimplementedError('Composition rootで注入します'));
final accountViewModelProvider =
    AsyncNotifierProvider<AccountViewModel, Profile?>(AccountViewModel.new);

class AccountViewModel extends CommandViewModel<Profile?> {
  AccountUseCases get _useCases => ref.read(accountUseCasesProvider);
  @override
  Future<Profile?> load() => _useCases.load();
  Future<String?> register(Profile profile) =>
      execute(() => _useCases.register(profile));
  Future<String?> deleteAll() => execute(_useCases.deleteAll);
}
