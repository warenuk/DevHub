importScripts('https://www.gstatic.com/firebasejs/10.12.2/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.12.2/firebase-messaging-compat.js');

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
  const notification = payload.notification ?? {};
  const title = notification.title ?? 'DevHub notification';
  const options = {
    body: notification.body,
    icon: '/icons/Icon-192.png',
    data: payload.data,
    tag: payload.collapseKey,
  };
  self.registration.showNotification(title, options);
});
