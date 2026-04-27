# Notif

Plataforma corporativa de notificações com controle de leitura, confirmação e SLA por setor.

Supervisores criam notificações segmentadas por setor ou globais. Funcionários recebem, visualizam e confirmam. O sistema rastreia o ciclo de vida de cada notificação por usuário e expõe métricas em tempo real para gestores.

---

## Monorepo

```
apps/
├── api/    # Backend — NestJS + Prisma + PostgreSQL
└── web/    # Frontend — Flutter Web
vercel.json # Configuração de deploy
```

Cada app tem seu próprio README com documentação detalhada:

- [`apps/api/README.md`](apps/api/README.md) — arquitetura, rotas, scripts e deploy do backend
- [`apps/web/README.md`](apps/web/README.md) — features, estado, navegação e build do frontend

---

## Funcionalidades

- Criação de notificações com níveis de urgência: LOW, MEDIUM, HIGH, CRITICAL
- Segmentação por setor ou distribuição global
- SLA configurável por notificação com marcação automática de OVERDUE
- Notificações CRITICAL bloqueiam o app até confirmação, com alerta sonoro
- Push notifications via Firebase Cloud Messaging
- Dashboard com KPIs, taxa de adesão por setor e filtros de período
- Controle de acesso por papel: EMPLOYEE, SUPERVISOR, ADMIN

---

## Arquitetura

```
┌─────────────────────────────┐
│         Flutter Web         │  apps/web
│  Riverpod · FCM · fl_chart  │
└────────────┬────────────────┘
             │ HTTPS /api/*
┌────────────▼────────────────┐
│         NestJS API          │  apps/api
│  Prisma · JWT · Firebase    │
└────────────┬────────────────┘
             │
┌────────────▼────────────────┐
│    PostgreSQL (Supabase)     │
│    PgBouncer connection pool │
└─────────────────────────────┘
```

O frontend e o backend são servidos pelo mesmo domínio na Vercel. Requisições para `/api/*` são roteadas para a função serverless NestJS; todo o restante serve o bundle estático Flutter.

---

## Deploy

O projeto é deployado como monorepo na **Vercel**:

| App | Tipo | Rota |
|---|---|---|
| `apps/api` | Serverless function (`@vercel/node`) | `/api/*` |
| `apps/web/build/web` | Estático (`@vercel/static`) | `/*` |

Push para a branch `main` dispara deploy automático.

---

## Desenvolvimento local

### Backend

```bash
cd apps/api
npm install
npm run start:dev      # porta 5050
```

### Frontend

```bash
cd apps/web
flutter pub get
flutter run -d chrome
```

O frontend em desenvolvimento aponta para `http://localhost:5050/api`.

---

## Tecnologias

**Backend:** NestJS · Prisma · PostgreSQL · Passport JWT · Firebase Admin SDK · Swagger

**Frontend:** Flutter · Riverpod · Firebase Messaging · fl_chart · Google Fonts · SharedPreferences
