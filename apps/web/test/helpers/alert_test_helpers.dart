import 'package:notif_app/core/api/api_client.dart';
import 'package:notif_app/core/model/user_model.dart';
import 'package:notif_app/features/alerts/services/alert_service.dart';
import 'package:notif_app/features/login/services/auth_service.dart';

const kSupervisorEmail = 'supervisor.dev@notif.com';
const kEmployeeEmail   = 'employee.dev@notif.com';
const kEmployeeOpsEmail = 'employee.ops@notif.com';
const kAdminEmail      = 'admin.dev@notif.com';
const kPassword        = 'password123';
const kFakeToken       = 'eXlMg8Fake:APA91bHPRgkFnXDfcMV0FakeTokenForTestingPurposesOnlyDoNotUseInProduction1234567890abcdef1234567890ABCDEF';

Future<String> loginAs(AuthService auth, String email) async {
  final token = await auth.login(email, kPassword);
  ApiClient.setToken(token);
  return token;
}

/// Faz login e retorna o perfil completo do usuário.
Future<UserModel> loginAndGetProfile(AuthService auth, String email) async {
  await loginAs(auth, email);
  return auth.fetchProfile();
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
