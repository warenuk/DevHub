# DevHub

DevHub is a Flutter application that bundles together GitHub activity tracking, personal notes and AI assistants.

## Feature flags

### Web ads (Google Publisher Tag demo)

The web build can embed the Google Publisher Tag (GPT) demo inventory without requiring a production ad account. Ads are disabled by default.

| Define | Purpose | Default |
| --- | --- | --- |
| `ADS_MODE` | Selects the ads implementation (`web_gpt` or `off`). | `off` |
| `ADS_SLOT_ID` | DOM id of the GPT slot container. | `div-gpt-ad-1` |
| `ADS_SLOT_PATH` | GPT demo slot path. | `/6355419/Travel/Europe/France/Paris` |
| `ADS_SLOT_SIZE` | Banner size in the `WIDTHxHEIGHT` format. | `300x250` |

Enable the GPT demo during local development or QA:

```bash
flutter run -d chrome \
  --dart-define=ADS_MODE=web_gpt \
  --dart-define=ADS_SLOT_ID=div-gpt-ad-1 \
  --dart-define=ADS_SLOT_PATH=/6355419/Travel/Europe/France/Paris \
  --dart-define=ADS_SLOT_SIZE=300x250
```

To disable the integration simply omit `ADS_MODE` or set it to `off` when building or serving the web target.
