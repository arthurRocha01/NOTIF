import http from 'k6/http';
import { check, sleep, group } from 'k6';
import { Rate, Counter } from 'k6/metrics';

const authFailure = new Rate('auth_failures');
const notifCreated = new Counter('notifications_created');

const BASE = 'http://localhost:5050/api';

const USERS = [
  { email: 'admin.dev@notif.com', role: 'ADMIN', password: 'password123' },
  { email: 'supervisor.dev@notif.com', role: 'SUPERVISOR', password: 'password123' },
  { email: 'employee.dev@notif.com', role: 'EMPLOYEE', password: 'password123' },
];

export const options = {
  stages: [
    { duration: '20s', target: 10 },
    { duration: '30s', target: 10 },
    { duration: '10s', target: 0 },
  ],
  thresholds: {
    http_req_duration: ['p(95)<2000'],
    http_req_failed: ['rate<0.05'],
    auth_failures: ['rate<0.1'],
  },
};

function login(email, password) {
  const res = http.post(`${BASE}/auth/login`, JSON.stringify({ email, password }), {
    headers: { 'Content-Type': 'application/json' },
  });
  const ok = check(res, {
    'login 201': (r) => r.status === 201,
    'login tem token': (r) => JSON.parse(r.body).access_token !== undefined,
  });
  authFailure.add(!ok);
  return ok ? JSON.parse(res.body).access_token : null;
}

function authHeaders(token) {
  return {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${token}`,
  };
}

export function setup() {
  const tokens = {};
  for (const u of USERS) {
    const t = login(u.email, u.password);
    if (t) tokens[u.role] = t;
  }
  const sectorRes = http.post(`${BASE}/sectors`, JSON.stringify({ name: 'K6 Test Sector' }), {
    headers: { 'Content-Type': 'application/json' },
  });
  const sectorId = sectorRes.status === 201
    ? JSON.parse(sectorRes.body).id
    : null;

  return { tokens, sectorId };
}

export default function (data) {
  const { tokens, sectorId } = data;

  group('01 - Rotas publicas e health', () => {
    const res = http.get(`${BASE.replace('/api', '')}/`);
    check(res, { 'health ok': (r) => r.status === 200 });
  });

  const role = __VU % 3 === 0 ? 'SUPERVISOR' : __VU % 3 === 1 ? 'ADMIN' : 'EMPLOYEE';
  const token = tokens[role];
  if (!token) {
    console.error(`Sem token para role ${role}`);
    return;
  }

  group('02 - Perfil e usuarios', () => {
    const p = http.get(`${BASE}/users/profile`, { headers: authHeaders(token) });
    check(p, { 'profile 200': (r) => r.status === 200 });
    const userId = JSON.parse(p.body).id;

    const u = http.get(`${BASE}/users/${userId}`, { headers: authHeaders(token) });
    check(u, { 'user by id 200': (r) => r.status === 200 });

    if (role === 'SUPERVISOR' || role === 'ADMIN') {
      const list = http.get(`${BASE}/users`, { headers: authHeaders(token) });
      check(list, { 'list users 200': (r) => r.status === 200 });
    }
  });

  group('03 - Setores', () => {
    const list = http.get(`${BASE}/sectors`, { headers: authHeaders(token) });
    check(list, { 'sectors list 200': (r) => r.status === 200 });

    if (sectorId) {
      const byId = http.get(`${BASE}/sectors/${sectorId}`, { headers: authHeaders(token) });
      check(byId, { 'sector by id 200': (r) => r.status === 200 });
    }
  });

  group('04 - Notificacoes', () => {
    const list = http.get(`${BASE}/notifications`, { headers: authHeaders(token) });
    check(list, { 'notifications list 200': (r) => r.status === 200 });

    if (role === 'SUPERVISOR' && sectorId) {
      const n = http.post(`${BASE}/notifications`, JSON.stringify({
        title: 'K6 Test Notification',
        message: 'Notificacao gerada durante teste de carga do k6 para medir performance',
        level: 'MEDIUM',
        slaMinutes: 120,
        sectorId: sectorId,
      }), { headers: authHeaders(token) });
      const ok = check(n, { 'create notif 201': (r) => r.status === 201 });
      if (ok) notifCreated.add(1);
    }
  });

  group('05 - Assignments', () => {
    const mine = http.get(`${BASE}/assignments/mine`, { headers: authHeaders(token) });
    check(mine, { 'mine 200': (r) => r.status === 200 });

    const all = http.get(`${BASE}/assignments`, { headers: authHeaders(token) });
    check(all, { 'all assignments 200': (r) => r.status === 200 });

    const blocking = http.get(`${BASE}/assignments/blocking`, { headers: authHeaders(token) });
    check(blocking, { 'blocking 200': (r) => r.status === 200 });

    const sync = http.post(`${BASE}/assignments/sync`, null, { headers: authHeaders(token) });
    check(sync, { 'sync 201': (r) => r.status === 201 });

    const inbox = http.get(`${BASE}/assignments/inbox-summary`, { headers: authHeaders(token) });
    check(inbox, { 'inbox summary 200': (r) => r.status === 200 });
  });

  group('06 - Dashboard', () => {
    const d = http.get(`${BASE}/dashboard/summary`, { headers: authHeaders(token) });
    check(d, { 'dashboard 200': (r) => r.status === 200 });
  });

  sleep(1);
}

export function teardown(data) {
  console.log('Teste de carga concluido');
}
