# Stripe тестова інтеграція для DevHub

Цей документ описує, як активувати веб-оплату Stripe у тестовому режимі для додатку DevHub.

## Передумови

1. **Stripe акаунт** з увімкненим тестовим режимом.
2. **Публічний ключ** (Publishable key) і **secret key** з панелі Stripe.
3. **Серверна функція** (наприклад, Cloud Functions, Firebase, Cloud Run чи власний бекенд), яка створює сесії Checkout.

## Налаштування змінних середовища

Під час запуску Flutter Web додатку необхідно передати `dart-define` значення:

```bash
flutter run \
  --dart-define=STRIPE_PUBLISHABLE_KEY=pk_test_xxxxxxxxxxxxxxxxxxxxx \
  --dart-define=STRIPE_BACKEND_URL=https://devhub-stripe-demo.web.app/api
```

Або додайте їх у відповідні конфігураційні файли CI/CD.

> `STRIPE_BACKEND_URL` повинен вказувати на REST endpoint, що повертає JSON `{ "sessionId": "..." }` у відповідь на POST `/subscriptions/create-checkout-session` з тілом `{ "priceId": "price_xxx" }`.

## Приклад бекенду (Node.js / Express)

```js
import express from 'express';
import Stripe from 'stripe';

const app = express();
const stripe = new Stripe(process.env.STRIPE_SECRET_KEY, {
  apiVersion: '2024-06-20',
});

app.use(express.json());

app.post('/subscriptions/create-checkout-session', async (req, res) => {
  try {
    const { priceId } = req.body;
    const session = await stripe.checkout.sessions.create({
      mode: 'subscription',
      line_items: [
        {
          price: priceId,
          quantity: 1,
        },
      ],
      success_url: 'https://your-app.example.com/subscriptions/success',
      cancel_url: 'https://your-app.example.com/subscriptions/cancel',
      payment_method_types: ['card'],
    });
    res.json({ sessionId: session.id });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Unable to create Stripe session' });
  }
});

app.listen(8080, () => console.log('Stripe backend ready on port 8080'));
```

## Використання на фронтенді

1. Відкрийте меню **Subscriptions** у сайдбарі DevHub.
2. Оберіть план і натисніть **«Оформити підписку»**.
3. У тестовому режимі використовуйте картку `4242 4242 4242 4242`, дату в майбутньому і будь-який CVC.

## Тестування

- Юніт-тести перевіряють створення сесій та обробку помилок.
- Віджети тестують відображення планів та виклик Stripe Checkout.
- Для end-to-end тестів можна задіяти [Stripe CLI](https://stripe.com/docs/stripe-cli) або тестове середовище Firebase Functions.

## Відлагодження

- Якщо кнопка підписки неактивна, переконайтесь, що `STRIPE_PUBLISHABLE_KEY` і `STRIPE_BACKEND_URL` передані в додаток.
- Перевірте вкладку **Network** у DevTools — запит до `/subscriptions/create-checkout-session` має повертати JSON з `sessionId`.
- Для локальної розробки можна використовувати `stripe listen` для проксування вебхуків.
