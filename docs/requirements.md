# BODYMAKE — Product Requirements v0.1
Updated: 2026-09-27. This is a summary of discussions, not evidence that the features are built.

## Vision and target
A personal training and physique journal: record → evaluate weekly → propose adjusted plan → repeat. Primary target: gym-going beginners to intermediate trainees who struggle with selecting exercises, tracking progression, and seeing physical change. A user's own decisions and adjustments override AI suggestions.

## MVP scope (first meaningful release)
1. Register/login, create training profile and goals.
2. Generate initial individualized weekly training plan with AI.
3. Display and let the user inspect/adjust/adopt the proposed plan.
4. Start a session, record each exercise and set: planned vs. actual load, reps, sets, notes, exertion/fatigue, timestamps; optional rest timer considered for MVP.
5. Record weight over time (multiple entries per day allowed); body-fat percentage optional; graph and weekly trend.
6. Private physique album with photo, date, type (front/side/back), comment. Calendar connects workout/weight/photo records.
7. Weekly review using adherence, load/reps, exertion, fatigue, weight trend; propose following-week modifications with explanations. User confirms adoption; no silent overwrite.
8. Basic account/data deletion, access control, error states.

## Onboarding information
Age or birth date, optional gender, height, initial weight, optional body-fat %, experience, objective (muscle gain / weight reduction / strength / wellbeing / body recomposition), optional target weight/deadline, weekly frequency, available time per session, gym/home, equipment, avoided exercises, pain or limitations. Keep input burden reasonable. Do not claim medical safety based solely on these fields.

## Typical journey
Login → onboarding → AI initial plan → confirmation → home showing today's workout and progress → session/set records → weight/photo calendar journal → weekly report → user adopts/edits next plan.

## AI boundaries and provisional quotas
- First initial plan: one generation at onboarding.
- Weekly review: once a week.
- Next-week plan: once a week; may later be combined with the review into one model call.
- Manual regeneration: provisionally 1–2/day.
- Open-ended AI chat: out of initial MVP.
These are planning assumptions to revisit after true usage-token and cost measurements. Avoid duplicate requests and enforce quotas server-side.

## Non-functional direction
- iOS and Android smartphones; tablet optimisation later.
- Private personal data and photos, HTTPS, token verification and record ownership.
- API keys server-side. AI service outage must not prevent normal record viewing/editing.
- Loading and failure UI; photos use thumbnails/lazy loading; quotas and backup policy before public launch.
- Offline-first syncing is not a first-MVP promise; reconsider gym network conditions later.
- Budget assumptions: aim near zero cost in local development; estimate for 100 users, then update after actual vendor and model selection. No guaranteed fixed monthly cost.

## Out of initial MVP / later candidate features
Meal tracking, social feed, rankings, Apple Health / Health Connect, smartwatch, AI visual body-fat estimation, video form analysis, advanced before/after slider, unrestricted AI coach chat.

## Product safety and privacy
Do not interpret images as medical diagnoses. Keep photographs non-public by default and deletable, request minimum personal data and clear consent/privacy disclosures. Review app-store rules and current privacy requirements before release.
