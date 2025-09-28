# Remote Config: Onboarding Variant

**Parameter**: `onboarding_variant` (NUMBER)

**Values:**
- `1` — Orbit (neon-inspired)
- `2` — Blueprint (wireframe style)
- `3` — Pulse (gradient-driven)

**Default:** `1` (kept in code via `RemoteConfigDefaults.onboardingVariant`). Unknown values gracefully fall back to this default.

## Where it is used in code
- Keys: `lib/shared/config/remote_config/remote_config_keys.dart` → `onboarding_variant`
- Defaults: `lib/shared/config/remote_config/remote_config_defaults.dart` → `onboardingVariant = 1`
- Reading RC: `lib/shared/config/remote_config/application/remote_config_controller.dart` → `getInt(onboarding_variant)`
- Mapping to UI: `lib/features/onboarding/domain/entities/onboarding_variant.dart` + `lib/features/onboarding/presentation/providers/onboarding_providers.dart`

## How to enable / change
1. Open **Firebase Console → Remote Config** for this project.
2. Import `docs/remote_config/remote_config_onboarding.json` (or create param manually).
3. Set **Default value** of `onboarding_variant` to desired variant (1/2/3).
4. **Publish changes**. In **Debug** builds the app fetches immediately (minimumFetchInterval = 0); in Release it respects intervals.

> Runtime flags: The app will use real Firebase Remote Config only when `USE_FIREBASE=true` and `USE_FIREBASE_REMOTE_CONFIG=true` (defaults). If Firebase hasn’t been initialized yet, app temporarily falls back to in-memory RC.

## Testing locally
- Run the app, then change `onboarding_variant` in Console and publish.
- In-app, trigger a refresh via `RemoteConfigController.refresh(force: true)` (e.g., from a debug action) or just restart the app.

## Optional: audiences / A/B
You can create conditions (by country, app version, user property, or random percent) and assign conditional values to `onboarding_variant` to roll out different flows to different cohorts.
