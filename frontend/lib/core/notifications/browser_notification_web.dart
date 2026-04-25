import 'dart:html' as html;

void showBrowserNotification(String title, String? body) {
  html.Notification(title, body: body);
}
