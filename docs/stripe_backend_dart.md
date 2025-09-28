# DevHub Stripe Backend (Dart)

## Запуск
```bat
set STRIPE_SECRET_KEY=sk_test_...
run_stripe_backend.bat
```

API:
- `GET /health` -> `ok`
- `POST /subscriptions/create-checkout-session` { priceId **or** productId } -> { sessionId }

Підстав у фронті `STRIPE_BACKEND_URL=http://localhost:8787`. Для емулятора Android: `http://10.0.2.2:8787`.

## Тести
```bat
set TEST_BASE=http://localhost:8787
dart test
```
