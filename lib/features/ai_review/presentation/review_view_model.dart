import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/presentation/command_view_model.dart';
import '../application/review_use_cases.dart';
import '../domain/weekly_review.dart';

final reviewUseCasesProvider = Provider<ReviewUseCases>(
    (ref) => throw UnimplementedError('Composition rootで注入します'));
final reviewViewModelProvider =
    AsyncNotifierProvider<ReviewViewModel, List<WeeklyReview>>(
        ReviewViewModel.new);

class ReviewViewModel extends CommandViewModel<List<WeeklyReview>> {
  ReviewUseCases get _useCases => ref.read(reviewUseCasesProvider);
  @override
  Future<List<WeeklyReview>> load() => _useCases.load();
  Future<String?> generate() => execute(_useCases.generate);
  Future<String?> propose(WeeklyReview review) =>
      execute(() => _useCases.propose(review));
}
