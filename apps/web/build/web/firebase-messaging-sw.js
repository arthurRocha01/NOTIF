importScripts('https://www.gstatic.com/firebasejs/10.12.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.12.0/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: 'AIzaSyCkWV-0nFVZR3J3zMxwBnzVab3WWB-FLZU',
  authDomain: 'notif-72c72.firebaseapp.com',
  projectId: 'notif-72c72',
  storageBucket: 'notif-72c72.firebasestorage.app',
  messagingSenderId: '25867044109',
  appId: '1:25867044109:web:ac4f52a0a6f1587fd89c44',
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage(function (payload) {
  const title = payload.data?.title || payload.notification?.title || 'Nova notificação';
  const options = {
    body: payload.data?.message || payload.notification?.body,
    icon: '/icons/Icon-192.png',
  };
  return self.registration.showNotification(title, options);
});
