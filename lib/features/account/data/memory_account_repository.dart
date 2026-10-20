import '../domain/account_repository.dart';
import '../domain/profile.dart';

class MemoryAccountRepository implements AccountRepository {
  Profile? _profile;
  @override
  Future<Profile?> load() async => _profile;
  @override
  Future<void> save(Profile profile) async => _profile = profile;
  @override
  Future<void> clear() async => _profile = null;
}
