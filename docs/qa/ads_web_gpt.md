# Ads (web GPT) QA checklist

## Smoke (ADS_MODE=web_gpt)

- [ ] Build the web app with `--dart-define=ADS_MODE=web_gpt --dart-define=ADS_SLOT_ID=div-gpt-ad-1 --dart-define=ADS_SLOT_PATH=/6355419/Travel/Europe/France/Paris --dart-define=ADS_SLOT_SIZE=300x250` (slot parameters are optional when using the defaults).
- [ ] Open the Settings page and verify that the "Ad area (web demo)" block renders a filled GPT iframe with the demo creative visible on screen.
- [ ] Confirm that the iframe dimensions match the configured slot size (default 300×250).

## Smoke (ADS_MODE=off)

- [ ] Build or serve the web app without the `ADS_MODE` define (or explicitly set `ADS_MODE=off`).
- [ ] Verify that the "Ad area" block shows the disabled placeholder overlay and no GPT network requests are issued.

## Integration test

- [ ] Run `flutter test integration_test/ads_web_gpt_test.dart -d chrome --dart-define=ADS_MODE=web_gpt` and confirm it passes.
- [ ] Re-run the same test suite with `--dart-define=ADS_MODE=off`; the test should skip GPT assertions and validate the placeholder state.

## Golden / layout regression

- [ ] Capture goldens for the Settings page with ads enabled and disabled, ensuring that the height of the "Ad area" section stays constant and does not cause layout jumps when toggling ADS_MODE.

## CSP hardening plan

- [ ] The current implementation relies on host-based allowances for GPT assets in development QA builds. For production, switch to a strict nonce-based policy by minting a dedicated nonce (e.g. `devhub-ads-nonce`) and applying it both to the GPT bootstrap script and to dynamically injected GPT commands once service accounts become available.
- [ ] After moving to the dedicated nonce, remove the broad host entries that were added for `*.googlesyndication.com` and `*.doubleclick.net`.
