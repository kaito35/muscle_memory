# BODYMAKE — Roadmap / Current State
Updated: 2026-10-01.

## Current implementation (verified from code)
Flutterのみの操作可能な仮実装を追加した。MVVM + DDD + Clean Architectureを採用。

- デモ入口、プロフィール登録、初期体重の記録、ホームの集計。
- サンプルプランの生成・負荷/回数/セット数の編集・採用。
- セッション開始、セットごとの実績/きつさ、完了時の疲労/メモ、履歴。
- 体重の複数回記録・修正・削除、7/30/90日のグラフ。
- ギャラリーからの写真選択、方向/日付/メモ、表示・拡大・削除。
- 体重・写真・セッションを日別に表示するカレンダー。
- 実際の記録に基づくサンプル週次レビュー、次週案の編集・採用。
- 全デモデータ削除。再起動時にも消えるメモリ保存。
- Domain/UseCase/ViewModel/Widgetのテストを追加。検証結果と制限は `flutter-prototype.md` を参照。

## Next Flutter tasks
1. ユーザーが画面と操作をレビューし、仮のUI・入力項目・動線を調整。
2. iOS/Android実機で画像選択、権限拒否、ライフサイクル、戻る操作を確認。
3. ローカル永続化の必要性を決める。導入時はデータ形式と写真の保持・削除方針を設計。
4. API契約確定後、data層にDTOとAPI Repositoryを追加。認証・エラー仕様を接続。

以下は作成時の計画・履歴。上の実装状況を優先する。

## What has been discussed (design drafts, not implemented)
- Product concept and initial audience
- MVP, initial onboarding, home, recording, weight/photo calendar, weekly AI review
- Preliminary non-functional/privacy/AI-usage requirements and cost assumptions
- Preferred architecture, conceptual PostgreSQL data model and draft REST endpoints
- Flutter project organisation and suggested sample two-screen foundation

## What owner reports is actually done
- A Flutter project folder has been created. Everything else must be verified by inspecting files. No assumption that Riverpod/go_router, demo screens, tests, Go project, Firebase, database, Git/GitHub, or cloud environments exist.

## Immediate sprint: Flutter foundation only (no chargeable services)
1. Inspect folder tree, `pubspec.yaml`, `lib`, `test`, `flutter --version`, `flutter doctor`, `git status`.
2. Agree initial incremental changes before editing existing files.
3. Add minimum structure and theme; use go_router only if appropriate to current installed version.
4. Add static home and body-weight placeholder routes.
5. Wire Riverpod root (`ProviderScope`) when installing package; do not fabricate use cases before needed.
6. Align generated `widget_test.dart` with new app; run `dart format`, `flutter analyze`, `flutter test`, and `flutter run` if target available.
7. Review diff and create a Git commit when owner asks.

## Next phases
- Implement body-weight UI with local fake repository to learn Notifier → UseCase → Repository, then test.
- Local Go `/health` and authentication strategy; API DTO contracts; repository implementation.
- Firebase project and auth; development vs production separation.
- PostgreSQL migrations/provider; Go auth token verification and owned data operations.
- End-to-end training logs, AI draft/review process, private photo flow and calendar.
- Crash/reporting, security, backup/restore, monitoring, accessibility, store requirements, cost validation, release.

## Working style
One small reviewable task at a time. Owner learns the reasoning, implements/reviews code and receives test guidance. Never spend money or deploy implicitly.
