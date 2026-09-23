importScripts('https://www.gstatic.com/firebasejs/10.12.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.12.0/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: 'AIzaSyCPjYs7c-P_oHVSv1SWj4vsasGC-YK1Wo4',
  authDomain: 'notif-cb096.firebaseapp.com',
  projectId: 'notif-cb096',
  storageBucket: 'notif-cb096.firebasestorage.app',
  messagingSenderId: '296550981769',
  appId: '1:296550981769:web:ccb4b716e64f58c5e06658',
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
