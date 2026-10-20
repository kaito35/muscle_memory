import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/domain_error.dart';

String dayLabel(DateTime date) => '${date.month}/${date.day}';
String dateLabel(DateTime date) => '${date.year}年${date.month}月${date.day}日';
String timeLabel(DateTime date) =>
    '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
const weekdays = ['月', '火', '水', '木', '金', '土', '日'];

class PageBody extends StatelessWidget {
  const PageBody({super.key, required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              children: children)));
}

class PageHeading extends StatelessWidget {
  const PageHeading(this.eyebrow, this.title, this.subtitle, {super.key});
  final String eyebrow, title, subtitle;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(eyebrow,
            style: const TextStyle(
                fontSize: 11,
                letterSpacing: 2.4,
                fontWeight: FontWeight.w700,
                color: Color(0xFF687C56))),
        const SizedBox(height: 8),
        Text(title, style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 8),
        Text(subtitle, style: TextStyle(color: Colors.grey.shade700)),
      ]));
}

class Panel extends StatelessWidget {
  const Panel({super.key, required this.child, this.color});
  final Widget child;
  final Color? color;
  @override
  Widget build(BuildContext context) => Card(
      color: color,
      child: Padding(padding: const EdgeInsets.all(20), child: child));
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.trailing});
  final String title;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Row(children: [
        Expanded(
            child: Text(title, style: Theme.of(context).textTheme.titleMedium)),
        if (trailing != null) trailing!
      ]));
}

class EmptyState extends StatelessWidget {
  const EmptyState(this.title, this.message,
      {super.key, this.icon = Icons.spa_outlined, this.action});
  final String title, message;
  final IconData icon;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Panel(
          child: Column(children: [
        Icon(icon, size: 36, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 12),
        Text(title,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(message, textAlign: TextAlign.center),
        if (action != null) ...[const SizedBox(height: 16), action!],
      ]));
}

class AsyncContent<T> extends StatelessWidget {
  const AsyncContent(
      {super.key,
      required this.value,
      required this.builder,
      required this.retry});
  final AsyncValue<T> value;
  final Widget Function(T) builder;
  final VoidCallback retry;
  @override
  Widget build(BuildContext context) {
    if (value.hasValue) {
      return Stack(children: [
        builder(value.requireValue),
        if (value.isLoading)
          const Positioned(
              top: 0, left: 0, right: 0, child: LinearProgressIndicator())
      ]);
    }
    if (value.hasError) {
      return Center(
          child: EmptyState('読み込めませんでした', '時間をおいて、もう一度お試しください。',
              action:
                  FilledButton(onPressed: retry, child: const Text('再読み込み'))));
    }
    return const Center(child: CircularProgressIndicator());
  }
}

Future<bool> runAction(BuildContext context, Future<String?> Function() action,
    {String? success}) async {
  String? error;
  try {
    error = await action();
  } on DomainError catch (e) {
    error = e.message;
  } catch (_) {
    error = '処理できませんでした。入力内容を確認して、もう一度お試しください。';
  }
  if (!context.mounted) return error == null;
  if (error != null || success != null) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(error ?? success!)));
  }
  return error == null;
}

Future<bool> confirm(
        BuildContext context, String title, String message) async =>
    await showDialog<bool>(
        context: context,
        builder: (context) =>
            AlertDialog(title: Text(title), content: Text(message), actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('キャンセル')),
              FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('削除する'))
            ])) ??
    false;

String? requiredNumber(String? value) =>
    double.tryParse(value ?? '')?.isFinite == true ? null : '数値を入力してください';

class DateField extends StatelessWidget {
  const DateField({super.key, required this.date, required this.onChanged});
  final DateTime date;
  final ValueChanged<DateTime> onChanged;
  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
      icon: const Icon(Icons.calendar_today_outlined, size: 18),
      label: Text(dateLabel(date)),
      onPressed: () async {
        final picked = await showDatePicker(
            context: context,
            initialDate: date,
            firstDate: DateTime(2000),
            lastDate: DateTime.now());
        if (picked != null) {
          onChanged(DateTime(
              picked.year, picked.month, picked.day, date.hour, date.minute));
        }
      });
}

/// 保存中に二重送信とダイアログの破棄を防ぐフォーム。
class EditorDialog extends StatefulWidget {
  const EditorDialog(
      {super.key,
      required this.title,
      required this.fields,
      required this.onSave,
      this.saveLabel = '保存する'});
  final String title, saveLabel;
  final List<Widget> fields;
  final Future<String?> Function() onSave;
  @override
  State<EditorDialog> createState() => _EditorDialogState();
}

class _EditorDialogState extends State<EditorDialog> {
  final _form = GlobalKey<FormState>();
  bool _busy = false;
  @override
  Widget build(BuildContext context) => PopScope(
      canPop: !_busy,
      child: AlertDialog(
          title: Text(widget.title),
          content: SizedBox(
              width: 400,
              child: SingleChildScrollView(
                  child: Form(
                      key: _form,
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: widget.fields
                              .expand((field) =>
                                  [field, const SizedBox(height: 16)])
                              .toList())))),
          actions: [
            TextButton(
                onPressed: _busy ? null : () => Navigator.pop(context),
                child: const Text('キャンセル')),
            FilledButton(
                onPressed: _busy
                    ? null
                    : () async {
                        if (!_form.currentState!.validate()) return;
                        setState(() => _busy = true);
                        final ok = await runAction(context, widget.onSave);
                        if (!context.mounted) return;
                        if (ok) {
                          Navigator.pop(context);
                        } else {
                          setState(() => _busy = false);
                        }
                      },
                child: Text(_busy ? '保存中…' : widget.saveLabel))
          ]));
}
