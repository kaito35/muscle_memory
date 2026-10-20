import '../../account/domain/profile.dart';
import 'training.dart';

abstract interface class PlanGenerator {
  Future<TrainingPlan> generate(Profile profile, DateTime week);
}
