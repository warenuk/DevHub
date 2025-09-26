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

function buildActionsFromPayload(payload) {
  const actions = [];
  try {
    // Prefer actions declared in the WebPush notification object
    if (payload && payload.notification && Array.isArray(payload.notification.actions)) {
      for (const a of payload.notification.actions) {
        if (a && a.action && a.title) {
          actions.push({ action: a.action, title: a.title, icon: a.icon });
        }
      }
    }
    // Or accept JSON-encoded actions in data.actions
    const raw = payload?.data?.actions;
    if (raw) {
      const parsed = JSON.parse(raw);
      if (Array.isArray(parsed)) {
        for (const a of parsed) {
          if (a && a.action && a.title) {
            actions.push({ action: a.action, title: a.title, icon: a.icon });
          }
        }
      }
    }
  } catch (e) {
    // ignore malformed actions
  }
  return actions;
}

function extractClickTarget(payload) {
  // Prefer explicit link fields from data or notification
  return payload?.data?.link || payload?.data?.url || payload?.notification?.click_action || null;
}

messaging.onBackgroundMessage((payload) => {
  const notification = payload.notification ?? {};
  const title = notification.title ?? 'DevHub notification';
  const actions = buildActionsFromPayload(payload);
  const link = extractClickTarget(payload);
  const options = {
    body: notification.body,
    icon: '/icons/Icon-192.png',
    data: Object.assign({}, payload.data || {}, { link }),
    tag: payload.collapseKey,
    actions,
  };
  self.registration.showNotification(title, options);
});

self.addEventListener('notificationclick', function(event) {
  const action = event.action;
  const data = event.notification?.data || {};
  const target = data.link || '/';
  event.notification.close();

  event.waitUntil((async () => {
    const allClients = await clients.matchAll({ type: 'window', includeUncontrolled: true });
    // Focus an existing tab if we can
    for (const client of allClients) {
      try {
        const url = new URL(client.url);
        if (target && url && url.href.includes(new URL(target, self.location.origin).pathname)) {
          await client.focus();
          client.postMessage({ type: 'notification_action', action, data });
          return;
        }
      } catch (_) {
        // ignore
      }
    }
    // Otherwise open a new tab
    const newClient = await clients.openWindow(target);
    if (newClient) {
      newClient.postMessage({ type: 'notification_action', action, data });
    }
  })());
});
