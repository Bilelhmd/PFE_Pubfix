class FirebaseNotification {
  /* final firebaseMessaging = FirebaseMessaging.instance;

  Future<void> handleBackgroundMessage(RemoteMessage message) async {
    print('Titre : ${message.notification?.title}');
    print('Body : ${message.notification?.body}');
    print('Payload : ${message.data}');
  }

  Future<void> initNotifications() async {
    await firebaseMessaging.requestPermission();
    final FCMToken = await firebaseMessaging.getToken();
    print('Tocken : $FCMToken');
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  }*/
}
