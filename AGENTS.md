# BODYMAKE — Codex Project Instructions

## Mission
Build a mobile app that helps people track physique changes and workouts and receive an AI-adjusted training plan based on recorded progress. This project also serves as a learning exercise for the owner: explain architectural reasoning, teach rather than blindly generate code, and make changes in small reviewable increments. Communicate in Japanese.

## Start every task here
1. Inspect the *actual* project tree, `pubspec.yaml`, existing source/tests, Git status, and relevant documentation. Never claim a feature is implemented just because it is documented.
2. Read `docs/requirements.md`, `docs/architecture.md`, `docs/database-design.md`, `docs/api-design.md`, `docs/decisions.md`, and `docs/roadmap.md` as needed.
3. Briefly state the intended files and changes before editing. Ask the owner to make architectural or paid-service decisions; for ordinary small coding tasks, proceed with the requested scope.
4. Make the smallest useful change; explain why it is structured that way and what the owner should learn from it.
5. Run applicable formatting, analyzer, and tests if available; show results honestly. Never claim tests ran unless they did.
6. Update affected documentation when a decision changes. Separate accepted decisions, proposals, and actual implementation status.

## Current implementation status (as reported by owner on 2026-09-27)
Only a Flutter project folder has been created. Do not assume packages, app structure, Firebase configuration, Go backend, database, Git remote, or cloud resources have been created. Inspect first. The current opened folder may be the Flutter project root rather than a monorepo. Do not move it to `apps/mobile` without agreement.

### Update: Flutter prototype implemented on 2026-10-01
The owner explicitly requested a Flutter-only prototype using MVVM + DDD + Clean Architecture. The project now has feature-first presentation/application/domain/data layers, Riverpod ViewModels/DI, go_router, memory repositories, local image selection, and sample plan/review logic. See `docs/flutter-prototype.md` for implemented scope, limitations, and a learning guide. The older two-screen plan is historical. Go, cloud services, real authentication, real AI, and persistent storage remain unimplemented. Inspect actual files and tests before each task.

## Agreed technical direction / proposals
- Flutter / Dart, feature-first architecture with lightweight presentation, application, domain, and data layers; Riverpod for state and dependency injection; go_router for navigation; Dio as the proposed HTTP client.
- Future backend: Go REST API (modular monolith; Handler → UseCase → Repository), deployed on Google Cloud Run. Do not implement or provision this until its phase.
- Main relational data: PostgreSQL; Supabase used *only as PostgreSQL hosting* is the current tentative first choice, subject to renewed cost/operational review. Do not replace the relational database with Firestore automatically.
- Firebase is modular: Authentication, FCM, Crashlytics, Analytics as appropriate; using Firebase services does NOT imply using Firestore. Some integrations may be deferred beyond the first Flutter foundation sprint.
- Private physique images: Google Cloud Storage with restricted access and time-limited upload/download methods; metadata in PostgreSQL.
- AI: model API called by Go, not directly from Flutter. Validate structured outputs; Go business rules protect progression and safety; user explicitly adopts a proposed revised training plan.
- Avoid unnecessary dependencies, microservices, cloud charges, and premature abstractions.

## Security and data rules
- Never put AI API keys, service-account private keys, database credentials, or other secrets in Flutter, commits, logs, or the docs.
- Go must verify Firebase ID tokens and derive the authenticated user; do not trust a `user_id` supplied by Flutter. Enforce ownership of every record and photograph.
- Photos are private by default; support deletion and account deletion; avoid public permanent URLs. Minimize personal and sensitive data.
- Never auto-commit, push, provision billed services, modify cloud security rules, or deploy without the owner's explicit request.
- AI-generated workout advice is not medical diagnosis. Pain/injury constraints require caution; do not offer reckless load jumps.

## Initial development task
Inspect the existing Flutter project and propose a stepwise foundation plan. Implement only the specific next small step requested. Prefer an initial static 2-screen skeleton, then Riverpod/navigation and tests, then backend integration. Keep tests for existing generated code aligned if replacing the sample counter app.
