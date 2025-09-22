# Web deployment notes

This project now enforces an offline-first PWA build and reproducible web artefacts directly from CI.

## Build profile

- `flutter build web --release --pwa-strategy=offline-first --tree-shake-icons`
- Renderer matrix: HTML and CanvasKit (see `.github/workflows/web_ci.yaml`).
- Icon tree shaking is always enabled to reduce bundle size.

## Service worker

- The repository ships the generated `web/flutter_service_worker.js` and pins `sql-wasm.js`/`sql-wasm.wasm` for Drift persistence.
- Web builds automatically reuse the offline-first service worker via the CI build command above.

## Local reproduction

To reproduce the same bundle locally:

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter build web --release --pwa-strategy=offline-first --tree-shake-icons --web-renderer html
flutter build web --release --pwa-strategy=offline-first --tree-shake-icons --web-renderer canvaskit
```

The generated output will be placed in `build/web` for the respective renderer.
