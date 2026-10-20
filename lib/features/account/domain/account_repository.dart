import 'profile.dart';

abstract interface class AccountRepository {
  Future<Profile?> load();
  Future<void> save(Profile profile);
  Future<void> clear();
}
