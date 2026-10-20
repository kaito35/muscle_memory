# BODYMAKE — PostgreSQL Data Model v0.1 (conceptual; do not run as migration)

## Planned tables
| Table | Purpose / important links |
|---|---|
| `users` | Internal UUID PK, unique Firebase UID; created/updated timestamps. Never store password. |
| `user_profiles` | One-to-one via `user_id` PK/FK; onboarding settings/goals. |
| `body_weights` | Many per user; measurement value/time, optional body-fat and memo. Multiple same-day entries allowed. |
| `body_photos` | Many per user; private storage path, type, date/time, comment; not image bytes. |
| `exercises` | Shared exercise catalog; deactivation rather than deletion when referenced. |
| `training_plans` | Plan proposals and adopted plans, week start, status/version and source. |
| `training_plan_days` | Multiple plan days; weekday/day ordering/name. |
| `training_plan_exercises` | Planned exercise, load, min/max reps, sets, rest, order. |
| `training_sessions` | Actual session, optional source plan day, start/end, state, subjective fatigue/condition, note. |
| `training_session_exercises` | Actual exercises within session, order, memo, relation to planned exercise when useful. |
| `training_sets` | Set number, load, reps, completion and potentially other measurement kinds. |
| `ai_reviews` | Review period, input summary/model metadata, structured findings, explanation, draft plan reference, status. |

## Key relations
```text
users 1—1 user_profiles
users 1—N body_weights / body_photos / training_plans / training_sessions / ai_reviews
training_plans 1—N training_plan_days 1—N training_plan_exercises N—1 exercises
training_sessions 1—N training_session_exercises 1—N training_sets
training_session_exercises N—1 exercises
```

## Constraints / invariants to design
- Internal user ID UUID distinct from unique Firebase UID. Authenticated owner ID derived server-side.
- Weight > 0. Load can be zero for bodyweight exercises; plank/time-distance exercise measurement needs later extension.
- `training_sets` unique `(training_session_exercise_id, set_number)`; positivity and reasonable upper-bound constraints; timestamps timezone-aware.
- Indexed `(user_id, recorded_at)` for history queries; indexes for frequently queried child FK and week/current-plan retrieval as appropriate.
- User deletion must remove their associated records and private photo objects; DB FK cascade alone does not delete cloud objects. Prefer a carefully orchestrated deletion workflow.
- Deleting a draft plan must not erase already completed session results; keep necessary historical snapshots.
- Do **not** blindly apply a unique `(user_id, week_start_date)` to `training_plans`: multiple drafts/versions conflict with it. Decide on a status-aware partial unique index for one adopted/current plan or an explicit version strategy.
- Planned and actual values remain separate, ideally snapshot targets at workout start to preserve history when a plan changes.
- `body_photos.weight_kg` should not duplicate body-weight data without a considered historical snapshot requirement.
- `body_photos` per-image vs a parent album/journal entry is open; choose after finalizing photo/comment UX.

## Next DB design task
Produce reviewed ERD and concrete column types/NULL/CHECK/FK/index/ON DELETE choices. Only then create versioned migration files. Earlier conversational SQL was illustrative, not a production migration.
