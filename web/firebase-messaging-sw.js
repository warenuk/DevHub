importScripts('https://www.gstatic.com/firebasejs/12.2.1/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/12.2.1/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: 'AIzaSyD4-jvZFtzLrYgnQztz1uDtKRI8huMdgO0',
  appId: '1:552495400925:web:18f821221564e152539834',
  messagingSenderId: '552495400925',
  projectId: 'devhub-48ed2',
  authDomain: 'devhub-48ed2.firebaseapp.com',
  storageBucket: 'devhub-48ed2.firebasestorage.app',
  measurementId: 'G-1NT8VC7HDH',
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  const notification = payload.notification || {};
  const title = notification.title || 'DevHub';
  const options = {
    body: notification.body,
    icon: '/icons/Icon-192.png',
    badge: '/icons/Icon-192.png',
    data: payload.data || {},
  };

  self.registration.showNotification(title, options);
});

self.addEventListener('message', (event) => {
  const data = event.data;
  if (!data || data.type !== 'devhub:schedule-test-notification') {
    return;
  }

  const title = data.title || 'DevHub';
  const body = data.body || '';
  const delayMs = Number(data.delayMs || 0);
  const payload = data.data || {};
  const port = event.ports && event.ports[0];

  const options = {
    body: body,
    icon: '/icons/Icon-192.png',
    badge: '/icons/Icon-192.png',
    data: payload,
    vibrate: [100, 50, 100],
  };

  const schedulePromise = new Promise((resolve, reject) => {
    setTimeout(() => {
      self.registration.showNotification(title, options).then(resolve).catch(reject);
    }, delayMs);
  });

  event.waitUntil(
    schedulePromise
      .then(() => {
        if (port) {
          port.postMessage('devhub:test-notification:delivered');
        }
      })
      .catch((error) => {
        if (port) {
          const message = error && error.message ? error.message : String(error);
          port.postMessage(`devhub:test-notification:error:${message}`);
        }
      }),
  );
});

self.addEventListener('notificationclick', (event) => {
  event.notification.close();
  const target = event.notification.data && event.notification.data.route
    ? event.notification.data.route
    : '/commits';

  event.waitUntil(
    clients
      .matchAll({ type: 'window', includeUncontrolled: true })
      .then((clientList) => {
        for (const client of clientList) {
          if ('focus' in client) {
            client.focus();
            client.postMessage({ type: 'devhub:navigate', route: target });
            return;
          }
        }
        if (clients.openWindow) {
          return clients.openWindow(target);
        }
        return undefined;
      })
  );
});
