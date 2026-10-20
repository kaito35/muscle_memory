import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/domain/domain_error.dart';
import '../../../core/presentation/widgets.dart';
import '../../body_record/presentation/body_record_page.dart';
import '../../training/presentation/training_page.dart';
import 'calendar_view_model.dart';

class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});
  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  DateTime _selected = dateOnly(DateTime.now());
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  @override
  Widget build(BuildContext context) => AsyncContent(
      value: ref.watch(calendarViewModelProvider),
      retry: () => ref.invalidate(calendarViewModelProvider),
      builder: (summary) {
        final weights = summary.weightsOn(_selected);
        final photos = summary.photosOn(_selected);
        final sessions = summary.sessionsOn(_selected);
        final offset = _month.weekday - 1;
        final count = DateTime(_month.year, _month.month + 1, 0).day;
        return PageBody(children: [
          const PageHeading(
              'YOUR JOURNEY', '続けてきた日々を、ひと目で。', 'トレーニング・体重・写真を、日付で振り返ります。'),
          Panel(
              child: Column(children: [
            Row(children: [
              IconButton(
                  tooltip: '前の月',
                  onPressed: () => setState(
                      () => _month = DateTime(_month.year, _month.month - 1)),
                  icon: const Icon(Icons.chevron_left)),
              Expanded(
                  child: Text('${_month.year}年${_month.month}月',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium)),
              IconButton(
                  tooltip: '次の月',
                  onPressed: () => setState(
                      () => _month = DateTime(_month.year, _month.month + 1)),
                  icon: const Icon(Icons.chevron_right))
            ]),
            const SizedBox(height: 12),
            Row(
                children: weekdays
                    .map((day) => Expanded(child: Center(child: Text(day))))
                    .toList()),
            const SizedBox(height: 8),
            GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: ((offset + count) / 7).ceil() * 7,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7, mainAxisExtent: 49),
                itemBuilder: (context, index) {
                  final number = index - offset + 1;
                  if (number < 1 || number > count) {
                    return const SizedBox.shrink();
                  }
                  final date = DateTime(_month.year, _month.month, number);
                  final hasTraining = summary.sessionsOn(date).isNotEmpty;
                  final hasWeight = summary.weightsOn(date).isNotEmpty;
                  final hasPhoto = summary.photosOn(date).isNotEmpty;
                  final selected = sameDay(date, _selected);
                  return Semantics(
                      label:
                          '${dateLabel(date)}${hasTraining ? ' トレーニング' : ''}${hasWeight ? ' 体重' : ''}${hasPhoto ? ' 写真' : ''}',
                      selected: selected,
                      child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => setState(() => _selected = date),
                          child: Container(
                              margin: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                  color:
                                      selected ? const Color(0xFFE4EEC5) : null,
                                  borderRadius: BorderRadius.circular(12),
                                  border: sameDay(date, DateTime.now())
                                      ? Border.all(
                                          color: const Color(0xFF526642))
                                      : null),
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('$number'),
                                    const SizedBox(height: 3),
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          if (hasTraining)
                                            const _Dot(Color(0xFF526642)),
                                          if (hasWeight)
                                            const _Dot(Color(0xFFB17C46)),
                                          if (hasPhoto)
                                            const _Dot(Color(0xFF7F8BB0)),
                                        ]),
                                  ]))));
                }),
            const SizedBox(height: 12),
            const Wrap(spacing: 14, runSpacing: 6, children: [
              Text('● トレーニング',
                  style: TextStyle(fontSize: 11, color: Color(0xFF526642))),
              Text('● 体重',
                  style: TextStyle(fontSize: 11, color: Color(0xFFB17C46))),
              Text('● 写真',
                  style: TextStyle(fontSize: 11, color: Color(0xFF7F8BB0)))
            ]),
          ])),
          SectionTitle('${dateLabel(_selected)}の記録'),
          if (weights.isEmpty && photos.isEmpty && sessions.isEmpty)
            const EmptyState('この日の記録はまだありません', '記録した体重・写真・トレーニングがここに集まります。',
                icon: Icons.calendar_today_outlined),
          ...weights.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Panel(
                  child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.monitor_weight_outlined),
                      title: Text('${entry.weight.kg.toStringAsFixed(1)} kg'),
                      subtitle: Text(
                          '${timeLabel(entry.recordedAt)} ${entry.memo}'))))),
          ...sessions.map((session) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: session.isComplete
                  ? SessionHistory(session: session)
                  : Panel(
                      child: Text(
                          '${session.dayName} · 進行中 / ${session.sets.length}セット記録')))),
          ...photos.map((photo) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: PhotoCard(photo: photo, busy: false))),
        ]);
      });
}

class _Dot extends StatelessWidget {
  const _Dot(this.color);
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
      width: 4,
      height: 4,
      margin: const EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(color: color, shape: BoxShape.circle));
}
