# Mirra - Source Brief

## Title
Mirra - AI before/after previews for aesthetic clinics

## Description
Mirra lets aesthetic clinics, salons and med-spas show clients a realistic AI preview of a new hairstyle, a makeup look, or a filler / Botox result on the client's own photo before they commit to a treatment. A client confirms they are 18+, signs up (which starts a 3-day free trial), accepts an informed-consent screen and takes a guided selfie. They then pick a style, look or treatment area and amount. Each result is a before/after comparison with a permanent "AI simulation" label and a medical-outcome disclaimer, and the client can save it to their clinic. Clinic staff see the day's sessions and each client's shared preview history. After the trial, access continues through a monthly in-app subscription with a clear cancellation path. The app is available in English and Hebrew, and the Hebrew UI is fully right-to-left.

## Store links
Not yet published (POC).

## Platform
Both - iOS and Android from one Flutter codebase.

## Category
Health & Fitness / Beauty (aesthetic treatment visualization).

## Features
- English / Hebrew with full RTL layout
- 18+ age gate before sign up
- Sign up starts a 3-day free trial automatically
- Informed consent (4 explicit acknowledgements) required before any photo is processed
- Guided photo capture with framing and lighting checks, encrypted upload
- Hairstyle simulation: 6 styles x 5 colors
- Makeup simulation: looks + intensity
- Filler / Botox preview by area: lips, cheeks, jawline, under-eye (ml) and forehead lines (units), natural-look toggle
- Generation progress screen (upload, face mapping, generation, quality check)
- Before/after drag slider, permanent AI simulation badge, outcome disclaimer
- Save preview to clinic, share or keep private
- History with type filters
- Paywall after trial: 79 ILS / month, restore purchases
- Subscription management: renewal date, cancel with access until period end
- Privacy center: stored photo count, 30-day auto-delete, delete single or all data, clinic visibility toggle
- Clinic admin view: today's sessions, shared previews, booking conversion, client history with consent status

## Tech stack
- Flutter 3.44 / Dart 3.12
- State: flutter_riverpod 3 (Notifier)
- Navigation: go_router 17 with a stateful tab shell
- Billing: in_app_purchase (StoreKit 2 / Google Play Billing) behind a `BillingService` interface
- Image generation: Gemini 2.5 Flash Image ("Nano Banana") image-edit API through `GeminiSimulationService`, swappable for OpenAI gpt-image-1
- Localization: flutter_localizations, EN + HE string table
- Tests: flutter_test unit and widget tests for the subscription / billing flow, integration_test for screenshots and the demo walkthrough

## Industry
Aesthetic medicine, med-spas, hair and beauty salons.

## Metrics
Unpublished POC, no store metrics. Scope: 16 core screens, 14 automated tests (12 billing rule / controller tests, 2 widget flow tests), verified running on the iPhone 17 Pro simulator and a physical Pixel 7a.

## Research notes
- Verified: full client flow from age gate to before/after result runs on iOS and Android. The billing rules (trial, purchase during trial, renewal, cancel, quota) are covered by passing tests. The Hebrew RTL layout renders correctly.
- Mocked: "after" images in the offline demo are pre-rendered local edits of a bundled portrait (lip volume warp, makeup tint, hair recolor). The live Gemini client exists but was not run during capture. Store purchases go through `MockBillingService`. The clinic sessions and statistics are fixture data.
- Future expansion: backend function for the image API and signed-URL photo storage, server-side receipt validation and store notifications, clinic multi-staff accounts and booking integration, real camera capture with on-device face detection for framing checks, and the body-contouring simulation once feasibility is validated.
