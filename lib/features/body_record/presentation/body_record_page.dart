import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/domain/domain_error.dart';
import '../../../core/presentation/widgets.dart';
import '../domain/body_records.dart';
import 'body_record_view_model.dart';
import 'record_dialogs.dart';
import 'weight_chart.dart';

class BodyRecordPage extends ConsumerStatefulWidget {
  const BodyRecordPage({super.key});
  @override
  ConsumerState<BodyRecordPage> createState() => _BodyRecordPageState();
}

class _BodyRecordPageState extends ConsumerState<BodyRecordPage> {
  bool _photos = false;
  int _days = 30;
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bodyRecordViewModelProvider);
    return AsyncContent(
        value: state,
        retry: () => ref.invalidate(bodyRecordViewModelProvider),
        builder: (data) {
          final since =
              dateOnly(DateTime.now()).subtract(Duration(days: _days - 1));
          final entries =
              data.weights.where((e) => !e.recordedAt.isBefore(since)).toList();
          final change = entries.length < 2
              ? null
              : entries.first.weight.kg - entries.last.weight.kg;
          return PageBody(children: [
            const PageHeading(
                'BODY JOURNAL', '小さな変化を、見つけよう。', '数字と写真で、あなたの歩みを残します。'),
            SegmentedButton<bool>(segments: const [
              ButtonSegment(
                  value: false,
                  label: Text('体重'),
                  icon: Icon(Icons.monitor_weight_outlined)),
              ButtonSegment(
                  value: true,
                  label: Text('写真'),
                  icon: Icon(Icons.photo_library_outlined))
            ], selected: {
              _photos
            }, onSelectionChanged: (v) => setState(() => _photos = v.first)),
            const SizedBox(height: 24),
            if (!_photos) ...[
              Panel(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    const Text('最新の体重'),
                    const SizedBox(height: 4),
                    Text(
                        data.weights.isEmpty
                            ? '— kg'
                            : '${data.weights.first.weight.kg.toStringAsFixed(1)} kg',
                        style: Theme.of(context).textTheme.headlineLarge),
                    Text(change == null
                        ? '2件以上記録すると変化が表示されます'
                        : '期間内の変化 ${change > 0 ? '+' : ''}${change.toStringAsFixed(1)} kg'),
                    const SizedBox(height: 16),
                    Wrap(
                        spacing: 8,
                        children: [7, 30, 90]
                            .map((days) => ChoiceChip(
                                label: Text('$days日'),
                                selected: _days == days,
                                onSelected: (_) =>
                                    setState(() => _days = days)))
                            .toList()),
                    const SizedBox(height: 20),
                    WeightChart(entries: entries),
                  ])),
              const SizedBox(height: 16),
              FilledButton.icon(
                  onPressed: state.isLoading
                      ? null
                      : () => showDialog<void>(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => const WeightEditorDialog()),
                  icon: const Icon(Icons.add),
                  label: const Text('体重を記録')),
              const SectionTitle('測定履歴'),
              if (data.weights.isEmpty)
                const EmptyState('最初の体重を記録しましょう', '1日に複数回記録できます。測定した日時も変更できます。')
              else
                ...data.weights.map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Card(
                        child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 8),
                      title: Text('${entry.weight.kg.toStringAsFixed(1)} kg',
                          style: Theme.of(context).textTheme.titleMedium),
                      subtitle: Text(
                          '${dateLabel(entry.recordedAt)} ${timeLabel(entry.recordedAt)}'
                          '${entry.bodyFat == null ? '' : '\n体脂肪率 ${entry.bodyFat}%'}${entry.memo.isEmpty ? '' : '\n${entry.memo}'}'),
                      trailing: PopupMenuButton<String>(
                          tooltip: '体重記録の操作',
                          enabled: !state.isLoading,
                          itemBuilder: (_) => const [
                                PopupMenuItem(value: 'edit', child: Text('修正')),
                                PopupMenuItem(
                                    value: 'delete', child: Text('削除'))
                              ],
                          onSelected: (action) async {
                            if (action == 'edit') {
                              await showDialog<void>(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (_) =>
                                      WeightEditorDialog(entry: entry));
                            } else if (await confirm(context, '体重記録を削除しますか？',
                                '${dateLabel(entry.recordedAt)}の${entry.weight.kg}kgの記録を削除します。')) {
                              if (context.mounted) {
                                await runAction(
                                    context,
                                    () => ref
                                        .read(bodyRecordViewModelProvider
                                            .notifier)
                                        .deleteWeight(entry.id));
                              }
                            }
                          }),
                    )))),
            ] else ...[
              const Panel(
                  color: Color(0xFFEAF0DC),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.lock_outline, size: 20),
                        SizedBox(width: 10),
                        Expanded(
                            child: Text('写真はこのデモ内だけで表示します。外部へ送信せず、再起動で消えます。'))
                      ])),
              const SizedBox(height: 16),
              FilledButton.icon(
                  onPressed: state.isLoading
                      ? null
                      : () => showDialog<void>(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => const PhotoEditorDialog()),
                  icon: const Icon(Icons.add_photo_alternate_outlined),
                  label: const Text('写真を追加')),
              const SectionTitle('からだのアルバム'),
              if (data.photos.isEmpty)
                const EmptyState(
                    '変化のスタートを残しましょう', '正面・側面・背面など、同じ角度で撮ると振り返りやすくなります。',
                    icon: Icons.photo_camera_outlined)
              else
                LayoutBuilder(
                    builder: (context, constraints) => Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: data.photos
                            .map((photo) => SizedBox(
                                width: (constraints.maxWidth - 12) / 2,
                                child: PhotoCard(
                                    photo: photo, busy: state.isLoading)))
                            .toList())),
            ],
          ]);
        });
  }
}

class PhotoCard extends ConsumerWidget {
  const PhotoCard({super.key, required this.photo, required this.busy});
  final BodyPhoto photo;
  final bool busy;
  @override
  Widget build(BuildContext context, WidgetRef ref) => Card(
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        InkWell(
            onTap: () => showDialog<void>(
                context: context,
                builder: (context) => Dialog(
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                      Flexible(
                          child: InteractiveViewer(
                              child: Image.memory(photo.bytes,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => const Padding(
                                      padding: EdgeInsets.all(32),
                                      child: Text('この画像は表示できません'))))),
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('閉じる'))
                    ]))),
            child: AspectRatio(
                aspectRatio: 0.85,
                child: Image.memory(photo.bytes,
                    fit: BoxFit.cover,
                    cacheWidth: 480,
                    errorBuilder: (_, __, ___) => const Center(
                        child: Icon(Icons.broken_image_outlined))))),
        Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 4, 8),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${dayLabel(photo.recordedAt)} · ${photo.angle.label}',
                  style: Theme.of(context).textTheme.titleSmall),
              if (photo.memo.isNotEmpty)
                Text(photo.memo, maxLines: 2, overflow: TextOverflow.ellipsis),
              Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                      tooltip: '写真を削除',
                      icon: const Icon(Icons.delete_outline, size: 20),
                      onPressed: busy
                          ? null
                          : () async {
                              if (!await confirm(context, '写真を削除しますか？',
                                  '選択した写真とメモを、このデモから削除します。')) return;
                              if (context.mounted) {
                                await runAction(
                                    context,
                                    () => ref
                                        .read(bodyRecordViewModelProvider
                                            .notifier)
                                        .deletePhoto(photo.id));
                              }
                            })),
            ])),
      ]));
}
