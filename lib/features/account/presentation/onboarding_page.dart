import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/presentation/widgets.dart';
import '../../body_record/presentation/body_record_view_model.dart';
import '../domain/profile.dart';
import 'account_view_model.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});
  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController(text: 'ゲスト');
  final _age = TextEditingController(text: '30');
  final _height = TextEditingController(text: '170');
  final _weight = TextEditingController(text: '65');
  final _limitations = TextEditingController();
  TrainingGoal _goal = TrainingGoal.muscle;
  int _days = 3;
  int _minutes = 45;
  String _experience = '初心者';
  String _location = 'ジム';
  bool _busy = false;
  @override
  void dispose() {
    for (final controller in [_name, _age, _height, _weight, _limitations]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PopScope(
      canPop: !_busy,
      child: Scaffold(
          appBar: AppBar(
              title: const Text('はじめの一歩'),
              leading: IconButton(
                  onPressed: _busy ? null : () => context.go('/welcome'),
                  icon: const Icon(Icons.arrow_back))),
          body: Form(
              key: _form,
              child: PageBody(children: [
                const PageHeading('YOUR STARTING POINT', 'あなたの目標を教えてください',
                    '入力値はデモ用の初期値です。自分に合わせて変更できます。'),
                TextFormField(
                    controller: _name,
                    decoration: const InputDecoration(labelText: '呼び名'),
                    maxLength: 40,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? '呼び名を入力してください' : null),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                      child: TextFormField(
                          controller: _age,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              labelText: '年齢', suffixText: '歳'),
                          validator: requiredNumber)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: TextFormField(
                          controller: _height,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: const InputDecoration(
                              labelText: '身長', suffixText: 'cm'),
                          validator: requiredNumber))
                ]),
                const SizedBox(height: 16),
                TextFormField(
                    controller: _weight,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                        labelText: '現在の体重', suffixText: 'kg'),
                    validator: requiredNumber),
                const SectionTitle('目指したいこと'),
                Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: TrainingGoal.values
                        .map((goal) => ChoiceChip(
                            label: Text(goal.label),
                            selected: _goal == goal,
                            onSelected: (_) => setState(() => _goal = goal)))
                        .toList()),
                const SectionTitle('続けやすいペース'),
                DropdownButtonFormField<int>(
                    value: _days,
                    decoration: const InputDecoration(labelText: '週のトレーニング回数'),
                    items: List.generate(
                        7,
                        (i) => DropdownMenuItem(
                            value: i + 1, child: Text('週${i + 1}回'))),
                    onChanged: (v) => setState(() => _days = v!)),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                    value: _minutes,
                    decoration: const InputDecoration(labelText: '1回の時間'),
                    items: [15, 30, 45, 60, 90]
                        .map((v) =>
                            DropdownMenuItem(value: v, child: Text('$v分')))
                        .toList(),
                    onChanged: (v) => setState(() => _minutes = v!)),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                    value: _experience,
                    decoration: const InputDecoration(labelText: '経験'),
                    items: ['初心者', '半年〜1年', '1年以上']
                        .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                        .toList(),
                    onChanged: (v) => setState(() => _experience = v!)),
                const SizedBox(height: 16),
                SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                          value: 'ジム',
                          label: Text('ジム'),
                          icon: Icon(Icons.fitness_center)),
                      ButtonSegment(
                          value: '自宅',
                          label: Text('自宅'),
                          icon: Icon(Icons.home_outlined))
                    ],
                    selected: {
                      _location
                    },
                    onSelectionChanged: (v) =>
                        setState(() => _location = v.first)),
                const SizedBox(height: 16),
                TextFormField(
                    controller: _limitations,
                    maxLength: 500,
                    maxLines: 2,
                    decoration:
                        const InputDecoration(labelText: '避けたい運動・痛み・制限（任意）')),
                const SizedBox(height: 16),
                FilledButton(
                    onPressed: _busy ? null : _submit,
                    child: Text(_busy ? '準備しています…' : 'プロフィールを保存して進む')),
                const SizedBox(height: 12),
                const Text(
                    'このデモは18歳以上を想定しています。プランは固定テンプレートで、入力内容から医療的な安全性を判断するものではありません。',
                    style: TextStyle(fontSize: 12)),
              ]))));

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    await ref.read(accountViewModelProvider.future);
    if (!mounted) return;
    final ok = await runAction(
        context,
        () => ref.read(accountViewModelProvider.notifier).register(Profile(
            name: _name.text.trim(),
            age: int.tryParse(_age.text) ?? 0,
            heightCm: double.parse(_height.text),
            initialWeightKg: double.parse(_weight.text),
            goal: _goal,
            daysPerWeek: _days,
            minutesPerSession: _minutes,
            experience: _experience,
            location: _location,
            limitations: _limitations.text.trim())));
    if (!mounted) return;
    if (ok) {
      ref.invalidate(bodyRecordViewModelProvider);
      context.go('/training');
    } else {
      setState(() => _busy = false);
    }
  }
}
