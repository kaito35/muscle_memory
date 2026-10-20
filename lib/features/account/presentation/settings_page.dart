import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/presentation/widgets.dart';
import '../../ai_review/presentation/review_view_model.dart';
import '../../body_record/presentation/body_record_view_model.dart';
import '../../training/presentation/training_view_model.dart';
import 'account_view_model.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(accountViewModelProvider).valueOrNull;
    return Scaffold(
        appBar: AppBar(title: const Text('プロフィールと設定')),
        body: PageBody(children: [
          const PageHeading('YOUR PROFILE', '自分のペースを、大切に。', '現在のプロフィールとデータ管理'),
          if (profile != null)
            Panel(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text('${profile.name}さん',
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 16),
                  Text(
                      '${profile.age}歳 / ${profile.heightCm.toStringAsFixed(0)}cm'),
                  Text('目標：${profile.goal.label}'),
                  Text(
                      '週${profile.daysPerWeek}回 / ${profile.minutesPerSession}分 / ${profile.location}'),
                  Text('経験：${profile.experience}'),
                  if (profile.limitations.isNotEmpty)
                    Text('制限：${profile.limitations}'),
                ])),
          const SectionTitle('この体験版について'),
          const Panel(
              child: Text(
                  '認証・AI・保存先は仮実装です。データはアプリの実行中だけ保持され、再起動・ブラウザの再読み込みで消えます。\n\n写真を含む入力データはサーバーへ送信しません。プロフィールの変更は、デモをリセットしてやり直せます。')),
          const SizedBox(height: 24),
          OutlinedButton.icon(
              icon: const Icon(Icons.delete_outline),
              label: const Text('デモデータをすべて削除'),
              onPressed: ref.watch(accountViewModelProvider).isLoading
                  ? null
                  : () async {
                      if (!await confirm(context, 'デモをリセットしますか？',
                          'プロフィール、体重、写真、トレーニング、レビューをすべて削除します。元には戻せません。')) {
                        return;
                      }
                      if (!context.mounted) return;
                      final ok = await runAction(
                          context,
                          ref
                              .read(accountViewModelProvider.notifier)
                              .deleteAll);
                      if (ok) {
                        ref.invalidate(bodyRecordViewModelProvider);
                        ref.invalidate(trainingViewModelProvider);
                        ref.invalidate(reviewViewModelProvider);
                      }
                    }),
        ]));
  }
}
