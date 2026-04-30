import 'dart:html' as html;

void showBrowserNotification(String title, String? body) {
  // Chrome 86+ bloqueia new Notification() quando há SW ativo em HTTPS (Vercel).
  // ServiceWorkerRegistration.showNotification() funciona em todos os contextos.
  final sw = html.window.navigator.serviceWorker;
  if (sw != null) {
    sw.ready.then((reg) {
      reg.showNotification(title, {'body': body ?? ''});
    }).catchError((_) {
      html.Notification(title, body: body);
    });
  } else {
    html.Notification(title, body: body);
  }
}

