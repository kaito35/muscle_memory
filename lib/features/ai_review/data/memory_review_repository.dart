import '../domain/weekly_review.dart';

class MemoryReviewRepository implements ReviewRepository {
  final List<WeeklyReview> _reviews = [];
  @override
  Future<List<WeeklyReview>> load() async => List.unmodifiable(_reviews);
  @override
  Future<void> save(WeeklyReview review) async {
    _reviews.removeWhere((r) => r.week == review.week);
    _reviews.insert(0, review);
  }

  @override
  Future<void> clear() async => _reviews.clear();
}
