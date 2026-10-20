import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/domain/domain_error.dart';
import '../../../core/presentation/widgets.dart';
import '../domain/body_records.dart';
import 'body_record_view_model.dart';

class WeightEditorDialog extends ConsumerStatefulWidget {
  const WeightEditorDialog({super.key, this.entry});
  final WeightEntry? entry;
  @override
  ConsumerState<WeightEditorDialog> createState() => _WeightEditorDialogState();
}

class _WeightEditorDialogState extends ConsumerState<WeightEditorDialog> {
  late final _kg =
      TextEditingController(text: widget.entry?.weight.kg.toString() ?? '');
  late final _fat =
      TextEditingController(text: widget.entry?.bodyFat?.toString() ?? '');
  late final _memo = TextEditingController(text: widget.entry?.memo ?? '');
  late DateTime _date = widget.entry?.recordedAt ?? DateTime.now();
  @override
  void dispose() {
    _kg.dispose();
    _fat.dispose();
    _memo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => EditorDialog(
      title: widget.entry == null ? '体重を記録' : '体重記録を修正',
      fields: [
        TextFormField(
            controller: _kg,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration:
                const InputDecoration(labelText: '体重', suffixText: 'kg'),
            validator: requiredNumber),
        TextFormField(
            controller: _fat,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration:
                const InputDecoration(labelText: '体脂肪率（任意）', suffixText: '%'),
            validator: (v) =>
                v == null || v.trim().isEmpty ? null : requiredNumber(v)),
        DateField(
            date: _date, onChanged: (date) => setState(() => _date = date)),
        OutlinedButton.icon(
            icon: const Icon(Icons.schedule, size: 18),
            label: Text(timeLabel(_date)),
            onPressed: () async {
              final time = await showTimePicker(
                  context: context, initialTime: TimeOfDay.fromDateTime(_date));
              if (time != null && mounted) {
                setState(() => _date = DateTime(_date.year, _date.month,
                    _date.day, time.hour, time.minute));
              }
            }),
        TextFormField(
            controller: _memo,
            maxLength: 500,
            maxLines: 2,
            decoration: const InputDecoration(labelText: 'メモ（任意）')),
      ],
      onSave: () => ref.read(bodyRecordViewModelProvider.notifier).recordWeight(
          id: widget.entry?.id,
          kg: double.parse(_kg.text),
          bodyFat: _fat.text.trim().isEmpty ? null : double.parse(_fat.text),
          date: _date,
          memo: _memo.text));
}

class PhotoEditorDialog extends ConsumerStatefulWidget {
  const PhotoEditorDialog({super.key});
  @override
  ConsumerState<PhotoEditorDialog> createState() => _PhotoEditorDialogState();
}

class _PhotoEditorDialogState extends ConsumerState<PhotoEditorDialog> {
  final _memo = TextEditingController();
  DateTime _date = dateOnly(DateTime.now());
  PhotoAngle _angle = PhotoAngle.front;
  @override
  void dispose() {
    _memo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => EditorDialog(
      title: '写真を追加',
      saveLabel: '画像を選んで保存',
      fields: [
        const Text('1枚ずつ、5MB以下の画像を選択できます。'),
        DropdownButtonFormField<PhotoAngle>(
            value: _angle,
            decoration: const InputDecoration(labelText: '撮影方向'),
            items: PhotoAngle.values
                .map((angle) =>
                    DropdownMenuItem(value: angle, child: Text(angle.label)))
                .toList(),
            onChanged: (value) => setState(() => _angle = value!)),
        DateField(
            date: _date, onChanged: (date) => setState(() => _date = date)),
        TextFormField(
            controller: _memo,
            maxLength: 500,
            maxLines: 2,
            decoration: const InputDecoration(labelText: 'メモ（任意）')),
      ],
      onSave: () => ref
          .read(bodyRecordViewModelProvider.notifier)
          .addPhoto(_angle, _date, _memo.text));
}
