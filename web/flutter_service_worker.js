'use strict';

import { getApp, getApps, initializeApp } from 'https://www.gstatic.com/firebasejs/12.2.1/firebase-app.js';
import { getMessaging, isSupported as isMessagingSupported, onBackgroundMessage } from 'https://www.gstatic.com/firebasejs/12.2.1/firebase-messaging.js';

const firebaseConfig = {
  apiKey: 'AIzaSyD4-jvZFtzLrYgnQztz1uDtKRI8huMdgO0',
  appId: '1:552495400925:web:18f821221564e152539834',
  messagingSenderId: '552495400925',
  projectId: 'devhub-48ed2',
  authDomain: 'devhub-48ed2.firebaseapp.com',
  storageBucket: 'devhub-48ed2.firebasestorage.app',
  measurementId: 'G-1NT8VC7HDH',
};

const ICON_PATH = '/icons/Icon-192.png';

async function broadcastMessage(message) {
  try {
    const clientList = await self.clients.matchAll({ type: 'window', includeUncontrolled: true });
    for (const client of clientList) {
      client.postMessage(message);
    }
  } catch (error) {
    console.error('Failed to broadcast message from service worker.', error);
  }
}

const messagingPromise = (async () => {
  try {
    if (!(await isMessagingSupported())) {
      console.warn('Firebase messaging is not supported in this browser.');
      return null;
    }
    const app = getApps().length ? getApp() : initializeApp(firebaseConfig);
    return getMessaging(app);
  } catch (error) {
    console.error('Failed to initialize Firebase messaging in service worker.', error);
    return null;
  }
})();

messagingPromise
  .then((messaging) => {
    if (!messaging) {
      return;
    }

    onBackgroundMessage(messaging, async (payload) => {
      const dataPayload = payload && payload.data ? payload.data : {};
      const notificationPayload = payload && payload.notification ? payload.notification : {};
      const title = notificationPayload.title || dataPayload.title || 'DevHub';
      const body = notificationPayload.body || dataPayload.body || '';
      const tag = notificationPayload.tag || dataPayload.tag || dataPayload.sha;

      const options = {
        body,
        icon: ICON_PATH,
        badge: ICON_PATH,
        data: dataPayload,
      };
      if (tag) {
        options.tag = tag;
      }

      try {
        await self.registration.showNotification(title, options);
        await broadcastMessage({
          type: 'devhub:sw:notification-shown',
          title,
          data: dataPayload,
          source: 'fcm-background',
        });
      } catch (error) {
        console.error('Failed to display background notification.', error);
      }
    });
  })
  .catch((error) => {
    console.error('Failed to register background message handler.', error);
  });

self.addEventListener('notificationclick', (event) => {
  event.notification.close();
  const data = event.notification && event.notification.data ? event.notification.data : {};
  const target = data.route ? data.route : '/commits';

  event.waitUntil((async () => {
    try {
      const clientList = await self.clients.matchAll({ type: 'window', includeUncontrolled: true });
      for (const client of clientList) {
        if ('focus' in client) {
          client.focus();
          try {
            client.postMessage({ type: 'devhub:navigate', route: target });
          } catch (postMessageError) {
            console.error('Failed to post navigation message to client.', postMessageError);
          }
          await broadcastMessage({
            type: 'devhub:sw:notification-click',
            route: target,
            source: 'notification-click',
          });
          return;
        }
      }
      if (self.clients.openWindow) {
        await broadcastMessage({
          type: 'devhub:sw:notification-click',
          route: target,
          source: 'notification-click',
        });
        return self.clients.openWindow(target);
      }
    } catch (error) {
      console.error('Failed to handle notification click.', error);
    }
    return undefined;
  })());
});

self.addEventListener('message', (event) => {
  const data = event.data;
  if (!data || typeof data !== 'object') {
    return;
  }
  if (data.type === 'devhub:test:emit-notification') {
    const title = data.title || 'DevHub test notification';
    const body = data.body || '';
    const payloadData = data.data || {};
    event.waitUntil((async () => {
      try {
        await self.registration.showNotification(title, {
          body,
          icon: ICON_PATH,
          badge: ICON_PATH,
          data: payloadData,
        });
        await broadcastMessage({
          type: 'devhub:sw:test-notification-shown',
          title,
          data: payloadData,
          source: 'test-message',
        });
      } catch (error) {
        console.error('Failed to emit test notification from message.', error);
      }
    })());
  }
});

const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = $$RESOURCES_MAP;
// The application shell files that are downloaded before a service worker can
// start.
const CORE = $$CORE_LIST;

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}

