# BODYMAKE — Architecture v0.3

## Flutter prototype implementation (2026-10-01)
ユーザーの指定により、Flutter側を **MVVM + DDD + Clean Architecture** で仮実装した。
クラウド構成は引き続き計画段階。以下のFlutter実装状況と区別する。

- `presentation`: WidgetをView、RiverpodのAsyncNotifierをViewModelとして使用。
- `application`: UseCaseが操作の手順をまとめ、Repositoryのインターフェースを呼ぶ。
- `domain`: Entity、Value Object、集約の業務ルール、Repository/外部サービスの契約。純粋なDart。
- `data`: メモリRepository、固定テンプレートのプラン生成、画像選択の実装。
- `app/dependencies.dart`: Composition root。具象実装を組み立てて注入する唯一の場所。
- `home`と`calendar`は既存の記録を合成する読み取り専用ViewModel。保存用の層は増やさない。
- 画面遷移はgo_router、状態管理と依存注入はRiverpod。HTTP通信がないためDioは未導入。

詳しい責務、コードの読み順、仮実装の制限は [flutter-prototype.md](flutter-prototype.md) を参照。

## Planned high-level topology
```text
Flutter iOS / Android
  ├─ Firebase Authentication (sign-in and ID token)
  ├─ Firebase Cloud Messaging / Crashlytics / Analytics (when required)
  └─ HTTPS REST + Firebase ID token → Go API on Cloud Run
                                         ├─ PostgreSQL (tentatively Supabase hosting only)
                                         ├─ OpenAI-compatible AI service / provider
                                         └─ authorizes temporary private Cloud Storage access for photos
Flutter may upload image bytes directly to Cloud Storage only using backend-issued restricted, expiring access.
```
Firebase is not mandated as the app database; PostgreSQL is the selected database type. Using FCM independently of the database is intentional. Supabase as provider remains a tentative hosting choice, not a locked vendor.

## Flutter
- Feature-first, lightweight layered structure, e.g. `lib/app`, `lib/core`, and `lib/features/{auth,onboarding,home,training,body_weight,body_photo,calendar,ai_review}`.
- Within complex features: `presentation` (widgets, Riverpod notifiers), `application` (use cases if warranted), `domain` (entities and repository contract), `data` (DTO, client and repository implementation).
- Riverpod and go_router are implemented in the Flutter prototype. Dio remains a future HTTP-client candidate. API DTO and domain entity should not be casually mixed.
- Flutter performs friendly validation; Go remains authoritative for all security and business rules.

## Go
- Single deployable modular monolith: handler (HTTP) → usecase (workflows) → repository interface; infrastructure implementations for PostgreSQL, Firebase verification, storage and AI provider.
- Use Firebase Admin SDK to verify ID tokens; map UID to internal UUID. Never trust client-supplied ownership IDs.
- Structured AI output must be parsed, validated and subjected to explicit rules; review and revised plan are drafts until user adopts.
- Plan for asynchronous model generation/job status if response duration merits it; idempotency for retryable writes.

## Storage
- PostgreSQL owns profiles, sessions, exercise/set history, weight history, plan versions, photo metadata, reviews. Photos themselves in private object storage. Avoid persistent public photo URLs.
- Timestamp storage UTC with timezone-aware values; date/grouping in user's timezone. For weekly dates, clearly define a week boundary and locale.

## Deployment and environments
- Start with local Flutter only, then local Go, auth, DB, end-to-end; dev and prod environment separation before any public release.
- No billable provisioning/deployment without explicit approval. Verify up-to-date quotas/costs; Cloud Run + DB connection capacity and potential cold starts/egress require testing.
