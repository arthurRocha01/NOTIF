import 'package:notif_app/core/api/api_client.dart';
import 'package:notif_app/features/alerts/services/alert_service.dart';
import 'package:notif_app/features/login/services/auth_service.dart';

const kSupervisorEmail = 'supervisor.dev@notif.com';
const kEmployeeEmail   = 'employee.dev@notif.com';
const kEmployeeOpsEmail = 'employee.ops@notif.com';
const kAdminEmail      = 'admin.dev@notif.com';
const kPassword        = 'password123';
const kFakeToken       = 'fcm-invalido-push-test';

Future<String> loginAs(AuthService auth, String email) async {
  final token = await auth.login(email, kPassword);
  ApiClient.setToken(token);
  return token;
}

Future<void> clearBlocking(AlertService alerts) async {
  for (final a in await alerts.getBlockingAssignments()) {
    await alerts.acknowledge(a.id);
  }
}

Future<String> loginAsSupervisor(AuthService auth) =>
    loginAs(auth, kSupervisorEmail);

Future<String> loginAsEmployee(AuthService auth) =>
    loginAs(auth, kEmployeeEmail);
