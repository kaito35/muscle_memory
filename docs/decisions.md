# BODYMAKE — Decision Log & Open Questions
Updated 2026-09-27. Distinguish directions from confirmed provisioning and actual code.

## Accepted and implemented on 2026-10-01
- ユーザーがFlutter側全体の仮実装と、MVVM + DDD + Clean Architectureを指定。
- プロジェクトルートとDartパッケージ名`muscle_memory`は維持。Flutter内の表示名はBODYMAKE。
- Riverpod 2.6.1 / go_router 14.6.2 / image_picker 1.1.2を現在のFlutter 3.24.2・Dart 3.5.2で導入。SDKは更新しない。
- 認証はアカウント登録不要のデモ入口で代替。AIは固定テンプレートとルールによるサンプルであることを画面に明示。
- 全データはメモリ保存。写真は選択した画像をメモリに保持し、外部送信しない。再起動・再読み込みで消える。
- `account`、`training`、`body_record`、`ai_review`を機能境界とする。体重と写真は同じ記録機能内で管理。
- 週の始まりは月曜、日付区切りは端末ローカル時間。これはプロトタイプ内の取り決めで、将来のサーバー仕様確定ではない。
- プラン採用は対象週の最新採用版を有効にする。旧版とセッション開始時の予定は保持。来週案の採用で今週を変更しない。
- 仮の入力上限（体重500kg、負荷500kg等）は入力エラーを防ぐためのUI/ドメイン制約であり、医学的安全性の基準ではない。
- クラウド・Go・DB・実AI・本番認証は未実装。初期2画面だけの計画を、今回のユーザー指示により操作可能なプロトタイプへ拡張した。

## Discussed/accepted product direction
- Physique album + weight and workout calendar + AI initial plan + weekly performance-aware adjustments form the core product.
- MVP-first approach; no social, food tracking, wearables, unrestricted AI chat or AI image diagnosis initially.
- Planned vs actual training separate; model cannot silently overwrite adopted plan.
- Privacy-first photo storage, record ownership, account/data deletion.
- App owner wants to learn reasoning, coding, review and tests during end-to-end development; not just paste AI-generated code.

## Selected or preferred technical direction (not yet implemented)
- Flutter / Dart, Riverpod, go_router, prospective Dio.
- Go REST API on Cloud Run planned for later; PostgreSQL is primary DB type.
- Firebase modules used selectively (Auth, FCM, Crashlytics, Analytics); intentionally do not assume Firestore.
- Supabase as *PostgreSQL host only* was the most recent provisional DB hosting choice after comparing Cloud SQL and Neon. Provider choice may be revisited; never buy/provision without approval.
- Private images in Google Cloud Storage; AI only behind Go service.

## Provisional assumptions, not final contracts
- AI: one initial generation, one weekly review and one next-week plan per user, manual regeneration 1–2/day; actual model-call count can differ if calls are combined.
- 100 active users used for early cost estimates. Low operational cost preferred; earlier rough numbers (e.g. ¥2,000/month early, ~¥5,000 reserve at paid-DB stage) are goals, not quotes or billing guarantees.
- Photos: up to three per journal entry, example cap 5 MB/image; compression, quotas and storage billing require confirmation.
- Workouts: a rest timer was recommended but exact MVP priority remains subject to scope review.

## Must resolve before implementation/public release
1. Actual Flutter project location/name and existing contents (inspect). No assumption about Git remote or installed packages.
2. App's published name and visual design.
3. DB provider/plan, region, backup/restore policy, connection approach from Cloud Run and actual cost.
4. Plan versions and unique-current-plan constraint; workout snapshots; bodyweight calendar day/timezone policy.
5. Exercise set data types for timed/cardio/bodyweight movements; exercise catalog and substitute exercises.
6. AI model/provider, structured response schema, escalation for pain, retry budget/quotas and real token-cost measurement.
7. Photo entry/comment schema, bucket access rules, upload/delete consistency, privacy and retention.
8. Authentication UX and applicable platform sign-in/store rules, privacy policy, app-account deletion flow.
9. Free vs paid monetization; release scope; actual App Store/Play registration fees and operational prices at release time.

## Corrections / avoid repeating past overstatements
- The earlier sample SQL's `UNIQUE(user_id, week_start_date)` conflicts with draft versions and needs redesign.
- Do not treat previously provided cloud/model prices as verified current pricing without checking official rates.
- Do not assume an earlier illustrative sample implementation exists on disk.
