import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/presentation/widgets.dart';
import '../domain/training.dart';
import 'training_view_model.dart';

class WorkoutEntryDialog extends ConsumerStatefulWidget {
  const WorkoutEntryDialog(
      {super.key,
      required this.target,
      this.dayId,
      this.number,
      this.existing});
  final ExerciseTarget target;
  final String? dayId;
  final int? number;
  final SetRecord? existing;
  @override
  ConsumerState<WorkoutEntryDialog> createState() => _WorkoutEntryDialogState();
}

class _WorkoutEntryDialogState extends ConsumerState<WorkoutEntryDialog> {
  late final _kg =
      TextEditingController(text: '${widget.existing?.kg ?? widget.target.kg}');
  late final _reps = TextEditingController(
      text: '${widget.existing?.reps ?? widget.target.reps}');
  late final _sets = TextEditingController(text: '${widget.target.sets}');
  late int _exertion = widget.existing?.exertion ?? 6;
  @override
  void dispose() {
    _kg.dispose();
    _reps.dispose();
    _sets.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => EditorDialog(
      title: widget.dayId == null
          ? '${widget.target.name}・セット${widget.number}'
          : '${widget.target.name}の予定',
      fields: [
        TextFormField(
            controller: _kg,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
                labelText: '負荷',
                suffixText: 'kg',
                helperText: '自重種目は0kgで記録できます'),
            validator: requiredNumber),
        TextFormField(
            controller: _reps,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: '回数', suffixText: '回'),
            validator: requiredNumber),
        if (widget.dayId != null)
          TextFormField(
              controller: _sets,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'セット数'),
              validator: requiredNumber)
        else
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('きつさ $_exertion / 10'),
            Slider(
                value: _exertion.toDouble(),
                min: 1,
                max: 10,
                divisions: 9,
                label: '$_exertion',
                onChanged: (v) => setState(() => _exertion = v.round()))
          ]),
      ],
      onSave: () {
        final vm = ref.read(trainingViewModelProvider.notifier);
        if (widget.dayId != null) {
          return vm.editDraft(
              widget.dayId!,
              ExerciseTarget(
                  id: widget.target.id,
                  name: widget.target.name,
                  kg: double.parse(_kg.text),
                  reps: int.tryParse(_reps.text) ?? 0,
                  sets: int.tryParse(_sets.text) ?? 0));
        }
        return vm.record(SetRecord(
            exerciseId: widget.target.id,
            number: widget.number!,
            kg: double.parse(_kg.text),
            reps: int.tryParse(_reps.text) ?? 0,
            exertion: _exertion,
            recordedAt: DateTime.now()));
      });
}

class CompleteWorkoutDialog extends ConsumerStatefulWidget {
  const CompleteWorkoutDialog({super.key});
  @override
  ConsumerState<CompleteWorkoutDialog> createState() =>
      _CompleteWorkoutDialogState();
}

class _CompleteWorkoutDialogState extends ConsumerState<CompleteWorkoutDialog> {
  final _memo = TextEditingController();
  int _fatigue = 5;
  @override
  void dispose() {
    _memo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => EditorDialog(
      title: '今日もおつかれさまでした',
      saveLabel: '完了して保存',
      fields: [
        const Text('未記録のセットは実績に含めず、記録済みのセットを保存します。'),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('全体の疲労度 $_fatigue / 10'),
          Slider(
              value: _fatigue.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              label: '$_fatigue',
              onChanged: (v) => setState(() => _fatigue = v.round()))
        ]),
        TextFormField(
            controller: _memo,
            maxLines: 3,
            maxLength: 500,
            decoration: const InputDecoration(labelText: '体調や気づき（任意）')),
      ],
      onSave: () => ref
          .read(trainingViewModelProvider.notifier)
          .complete(_fatigue, _memo.text));
}
