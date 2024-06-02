importScripts('https://www.gstatic.com/firebasejs/9.0.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.0.0/firebase-messaging-compat.js');
firebase.initializeApp({
    apiKey: "AIzaSyDCKTAU1xUbl_J3Rbdv4hTuj9FrNjyBvpk",
    authDomain: "pubfix-2aa04.firebaseapp.com",
    projectId: "pubfix-2aa04",
    storageBucket: "pubfix-2aa04.appspot.com",
    messagingSenderId: "622298064039",
    appId: "1:622298064039:web:c015e985b61f4766666782",
    measurementId: "G-30KDFNYEND"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage(function(payload) {
    console.log('[firebase-messaging-sw.js] Received background message ', payload);
    const notificationTitle = payload.notification.title;
    const notificationOptions = {
      body: payload.notification.body,
      icon: '/web/favicon.png' // Replace with your app icon URL
    };

  return self.registration.showNotification(notificationTitle, notificationOptions);
});
