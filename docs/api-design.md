# BODYMAKE — REST API Contract v0.1 (draft)

Base path: `/api/v1`; JSON over HTTPS. Authenticate protected routes using `Authorization: Bearer <Firebase ID token>`; verify server-side and derive current internal user ID. Do not accept `user_id` as proof of ownership. Date-time values ISO 8601 with timezone. IDs UUID in final implementation.

## Candidate endpoints
| Method | Path | Purpose |
|---|---|---|
| POST | `/users/me` | Register/profile bootstrap after Firebase auth |
| GET | `/users/me` | Current user |
| PUT | `/users/me/profile` | Update onboarding/profile |
| DELETE | `/users/me` | Account and associated data deletion workflow |
| POST | `/training-plans/generations` | Request initial or revised AI plan; returns job/draft status |
| GET | `/training-plans/current` | Adopted current plan |
| GET | `/training-plans/{id}` | One plan, owned by user |
| PATCH | `/training-plan-exercises/{id}` | Edit planned exercise |
| POST | `/training-sessions` | Start session |
| GET | `/training-sessions` | List sessions by date |
| GET | `/training-sessions/{id}` | Session detail |
| POST | `/training-sessions/{id}/sets` | Add completed set, retry-safe where needed |
| POST | `/training-sessions/{id}/complete` | Finish session |
| POST | `/body-weights` | Add weight measurement |
| GET | `/body-weights` | History / trend |
| PATCH | `/body-weights/{id}` | Correct measurement |
| POST | `/body-photos/upload-requests` | Authorize temporary upload |
| POST | `/body-photos` | Register uploaded photo metadata |
| GET | `/body-photos` | Private album listing |
| DELETE | `/body-photos/{id}` | Delete metadata and object safely |
| POST | `/ai/weekly-reviews` | Request weekly analysis |
| GET | `/ai/weekly-reviews` | Review history |
| GET | `/ai/weekly-reviews/{id}` | Review detail/job state |
| POST | `/ai/weekly-reviews/{id}/adopt` | User adopts revised plan |

## Example: body weight creation
Request:
```http
POST /api/v1/body-weights
Authorization: Bearer <Firebase ID token>
Content-Type: application/json
```
```json
{"weight_kg":89.5,"body_fat_percentage":26.3,"recorded_at":"2026-09-26T07:00:00+09:00","memo":"朝食前に測定"}
```
Success: HTTP 201 with generated ID, normalized timestamp and saved fields. Exact DTO to be finalized when implementing.

## Error and reliability rules
- Consistent error shape, e.g. `{ "error": { "code": "INVALID_WEIGHT", "message": "..." } }`.
- Usual status codes 400, 401, 403 where relevant, 404, 409, 422, 429, 500, 503. Do not leak private record existence across users.
- Session sets should be persisted incrementally so app crashes do not lose all progress. Add idempotency keys or resource-level duplicate protection for retryable writes.
- AI generation may use asynchronous job resource; server enforces user quotas, validates output, and never auto-applies a proposal.
- When AI provider is unavailable, user can still read and record workouts and body data.

## Open API design decisions
Pagination/cursors; error schema and error catalog; conflict/idempotency semantics; exact photo upload sequence; status polling/notification for model jobs; OpenAPI specification and schema generation; rate limits and timezone handling.
