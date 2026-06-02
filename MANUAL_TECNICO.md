# Manual Técnico — NOTIF

## Visão Geral do Sistema

O **NOTIF** é uma plataforma web de notificações corporativas com rastreamento de conformidade (SLA). A arquitetura segue um modelo monorepo com backend e frontend separados, ambos implantados na Vercel.

| Camada | Tecnologia |
|---|---|
| Backend | NestJS 11 + TypeScript |
| Frontend | Flutter Web (Dart) |
| Banco de dados | PostgreSQL via Supabase |
| ORM | Prisma 6 |
| Autenticação | JWT (Passport.js) |
| Push Notifications | Firebase Cloud Messaging (FCM) |
| Gerenciamento de estado | Riverpod 2 |
| Deploy | Vercel (serverless + SPA estática) |

---

## Estrutura do Repositório

```
NOTIF/
├── apps/
│   ├── api/                  # Backend NestJS
│   └── web/                  # Frontend Flutter Web
├── vercel.json               # Roteamento Vercel (API + SPA)
├── package.json              # Workspace root
├── MANUAL_DO_USUARIO.md
└── MANUAL_TECNICO.md
```

---

## Backend (`apps/api`)

### Stack e dependências principais

| Pacote | Versão | Uso |
|---|---|---|
| `@nestjs/core` | 11 | Framework principal |
| `@nestjs/passport` + `passport-jwt` | — | Autenticação JWT |
| `@prisma/client` | 6 | ORM / acesso ao banco |
| `firebase-admin` | — | Envio de push via FCM |
| `bcrypt` | — | Hash de senhas |
| `@nestjs/swagger` | — | Documentação da API |
| `@nestjs/schedule` | — | Cron job (overdue checker) |

### Estrutura de diretórios

```
apps/api/src/
├── main.ts                        # Entry point (Vercel serverless + local)
├── app.module.ts                  # Módulo raiz
├── modules/
│   ├── auth/                      # Login e JWT
│   ├── users/                     # CRUD de usuários
│   ├── sectors/                   # CRUD de setores
│   ├── notifications/             # Criação e distribuição de notificações
│   ├── assignments/               # Ciclo de vida por usuário
│   └── dashboard/                 # Métricas e KPIs
└── prisma/
    ├── schema.prisma              # Schema do banco
    ├── migrations/                # Histórico de migrações
    └── seed.ts                    # Dados de teste
```

Cada módulo segue a arquitetura em camadas:

```
modules/<feature>/
├── presentation/   # Controller (rotas HTTP)
├── application/    # Service (regras de negócio)
├── infrastructure/ # Repository (Prisma), Guards, Strategies
└── dto/            # Data Transfer Objects (validação de entrada/saída)
```

### Schema do banco de dados

```prisma
model User {
  id           String   @id @default(uuid())
  name         String
  email        String   @unique
  passwordHash String
  role         Role     @default(EMPLOYEE)
  fcmToken     String?
  sectorId     String?
  sector       Sector?  @relation(fields: [sectorId], references: [id])
  assignments  NotificationAssignment[]
  createdNotifications Notification[]
  createdAt    DateTime @default(now())
  updatedAt    DateTime @updatedAt
}

model Sector {
  id            String   @id @default(uuid())
  name          String
  users         User[]
  notifications Notification[]
  createdAt     DateTime @default(now())
  updatedAt     DateTime @updatedAt
}

model Notification {
  id                    String   @id @default(uuid())
  title                 String
  message               String
  level                 NotificationLevel
  slaMinutes            Int
  requiresAcknowledgment Boolean @default(true)
  sectorId              String?
  sector                Sector?  @relation(fields: [sectorId], references: [id])
  authorId              String
  author                User     @relation(fields: [authorId], references: [id])
  assignments           NotificationAssignment[]
  createdAt             DateTime @default(now())
  updatedAt             DateTime @updatedAt
}

model NotificationAssignment {
  id             String           @id @default(uuid())
  userId         String
  notificationId String
  status         AssignmentStatus @default(PENDING)
  dueAt          DateTime
  deliveredAt    DateTime?
  viewedAt       DateTime?
  acknowledgedAt DateTime?
  deniedAt       DateTime?
  user           User         @relation(fields: [userId], references: [id])
  notification   Notification @relation(fields: [notificationId], references: [id])
  createdAt      DateTime @default(now())
  updatedAt      DateTime @updatedAt

  @@unique([userId, notificationId])
  @@index([userId])
  @@index([notificationId])
  @@index([status])
  @@index([dueAt])
}

enum Role { EMPLOYEE SUPERVISOR ADMIN }
enum NotificationLevel { LOW MEDIUM HIGH CRITICAL }
enum AssignmentStatus { PENDING VIEWED ACKNOWLEDGED OVERDUE DENIED }
```

### Autenticação e autorização

**Login** — `POST /api/auth/login`
1. Recebe `{ email, password }`.
2. Busca o usuário pelo e-mail.
3. Compara a senha com `bcrypt.compare`.
4. Gera JWT com payload `{ userId, email, role, sector }` e expiração configurável.
5. Retorna o token e os dados do usuário.

**Guards aplicados globalmente:**

| Guard | Função |
|---|---|
| `JwtAuthGuard` | Valida assinatura e expiração do JWT em todas as rotas protegidas |
| `RolesGuard` | Verifica se o `role` do usuário está na lista do decorator `@Roles()` |
| `CriticalBlockGuard` | Bloqueia qualquer requisição de usuário com notificação CRITICAL não confirmada; pode ser bypassado com `@BypassBlock()` |

### Endpoints da API

#### Autenticação
| Método | Rota | Auth | Descrição |
|---|---|---|---|
| POST | `/api/auth/login` | Público | Login com e-mail e senha |

#### Usuários
| Método | Rota | Auth | Role mínimo | Descrição |
|---|---|---|---|---|
| GET | `/api/users` | JWT | SUPERVISOR | Listar todos os usuários |
| GET | `/api/users/:id` | JWT | — | Buscar usuário por ID |
| GET | `/api/users/by-email/:email` | JWT | — | Buscar usuário por e-mail |
| POST | `/api/users` | Público | — | Criar usuário |
| PATCH | `/api/users/:id` | JWT | — | Atualizar usuário |
| DELETE | `/api/users/:id` | JWT | ADMIN | Excluir usuário |

#### Setores
| Método | Rota | Auth | Descrição |
|---|---|---|---|
| GET | `/api/sectors` | JWT | Listar setores |
| POST | `/api/sectors` | Público | Criar setor |
| PATCH | `/api/sectors/:id` | JWT | Atualizar setor |
| DELETE | `/api/sectors/:id` | JWT | Excluir setor |

#### Notificações
| Método | Rota | Auth | Role mínimo | Descrição |
|---|---|---|---|---|
| GET | `/api/notifications` | JWT | — | Listar notificações (filtrado por role) |
| GET | `/api/notifications/:id` | JWT | — | Buscar notificação por ID |
| POST | `/api/notifications` | JWT | SUPERVISOR | Criar notificação e distribuir assignments |
| PATCH | `/api/notifications/:id` | JWT | — | Atualizar notificação |
| DELETE | `/api/notifications/:id` | JWT | — | Excluir notificação |

#### Assignments
| Método | Rota | Auth | Role mínimo | Descrição |
|---|---|---|---|---|
| GET | `/api/assignments` | JWT | SUPERVISOR | Listar todos os assignments |
| GET | `/api/assignments/mine` | JWT | — | Assignments do usuário logado |
| GET | `/api/assignments/blocking` | JWT | — | Assignments CRITICAL não confirmados |
| GET | `/api/assignments/inbox-summary` | JWT | — | Contagem por status |
| GET | `/api/assignments/:id` | JWT | — | Buscar assignment por ID |
| POST | `/api/assignments/sync` | JWT | — | Sincronizar entrega FCM |
| POST | `/api/assignments/:id/view` | JWT | — | Marcar como VIEWED |
| POST | `/api/assignments/:id/acknowledge` | JWT | — | Marcar como ACKNOWLEDGED |
| POST | `/api/assignments/:id/deny` | JWT | — | Marcar como DENIED |
| DELETE | `/api/assignments/:id` | JWT | — | Excluir assignment |

#### Dashboard
| Método | Rota | Auth | Role mínimo | Descrição |
|---|---|---|---|---|
| GET | `/api/dashboard/summary` | JWT | SUPERVISOR | KPIs e métricas por setor/período |

### Ciclo de vida de uma notificação

```
Supervisor cria notificação
        │
        ▼
Backend gera NotificationAssignment por usuário
  status = PENDING
  dueAt  = now + slaMinutes
        │
        ├─── FCM envia push para dispositivos
        │          │
        │          ▼
        │    deliveredAt = now  (via /assignments/sync)
        │
        ▼
Usuário abre a notificação
  status = VIEWED
  viewedAt = now
        │
        ├─── Confirma → status = ACKNOWLEDGED, acknowledgedAt = now
        ├─── Nega    → status = DENIED,        deniedAt = now
        │
        └─── SLA vence (cron a cada 1 min)
               status = OVERDUE  (se != ACKNOWLEDGED)
```

### Cron job — Overdue Checker

`OverdueCheckerService` executa a cada minuto:

```typescript
@Cron(CronExpression.EVERY_MINUTE)
async checkOverdue() {
  await this.prisma.notificationAssignment.updateMany({
    where: {
      dueAt: { lt: new Date() },
      status: { notIn: ['ACKNOWLEDGED', 'DENIED', 'OVERDUE'] },
    },
    data: { status: 'OVERDUE' },
  });
}
```

### Push Notifications (FCM)

- **Notificação CRITICAL**: envio individual com prioridade alta.
- **Outros níveis**: envio em lote (`sendEachForMulticast`).
- O token FCM de cada usuário é salvo no campo `fcmToken` e atualizado automaticamente pelo frontend quando o Firebase renova o token.

### Documentação interativa

Disponível em `/api/swagger` (Swagger UI). Gerada automaticamente pelos decorators `@ApiTags`, `@ApiOperation`, `@ApiResponse` nos controllers.

---

## Frontend (`apps/web`)

### Stack e dependências principais

| Pacote | Versão | Uso |
|---|---|---|
| `flutter_riverpod` | 2.x | Gerenciamento de estado |
| `firebase_messaging` | 15.x | Push notifications (FCM) |
| `flutter_local_notifications` | 18.x | Notificações locais e banners |
| `go_router` | 17.x | Roteamento declarativo |
| `fl_chart` | — | Gráficos do dashboard |
| `google_fonts` | 6.x | Tipografia |
| `shared_preferences` | — | Persistência do token JWT |
| `audioplayers` | 6.x | Alerta sonoro para notificações críticas |

### Estrutura de diretórios

```
apps/web/lib/
├── main.dart                        # Entry point + MaterialApp + Riverpod
├── core/
│   ├── api/api_client.dart          # HTTP client (injeção de JWT, retry, timeout 20s)
│   ├── model/user_model.dart        # UserModel + UserRole enum
│   ├── notifications/               # Inicialização FCM + local notifications
│   ├── storage/token_storage.dart   # SharedPreferences (persistência de sessão)
│   ├── theme/app_theme.dart         # Cores, espaçamentos, tipografia
│   └── utils/date_formatter.dart    # Formatação de datas
├── features/
│   ├── login/                       # Tela e provider de autenticação
│   ├── alerts/                      # Tela de alertas, bloqueio crítico, detalhes
│   ├── dashboard/                   # KPIs, gráficos, filtros
│   ├── home/                        # Hub principal com tabs
│   ├── admin/                       # Painel admin (usuários e setores)
│   ├── profile/                     # Perfil do usuário
│   ├── sectors/                     # Provider e service de setores
│   └── splash/                      # Splash screen (restauração de sessão)
└── shared/
    ├── layout/                      # Drawer de navegação, layout responsivo
    └── widgets/                     # Widgets reutilizáveis (AppBar, botões)
```

### Gerenciamento de estado (Riverpod)

Todos os estados são gerenciados por `StateNotifier` com estado imutável (`copyWith`).

| Provider | Tipo | Responsabilidade |
|---|---|---|
| `authProvider` | `StateNotifier` | Login, logout, restauração de sessão, usuário atual |
| `alertProvider` | `StateNotifier` | Assignments, bloqueio crítico, acknowledge, deny, polling |
| `sectorProvider` | `StateNotifier` | Lista de setores |
| `dashboardProvider` | `Provider` (computado) | KPIs derivados do `alertProvider` + filtros |
| `dashboardFilterProvider` | `StateNotifier` | Período (7d/30d/all) e setor selecionado |
| `adminUserProvider` | `StateNotifier` | CRUD de usuários (painel admin) |
| `adminSectorProvider` | `StateNotifier` | CRUD de setores (painel admin) |
| `profileProvider` | `StateNotifier` | Dados de perfil e avatar |

### Roteamento

Gerenciado por `go_router` com redirecionamento baseado no estado de autenticação:

```
/                   → SplashScreen (verifica sessão)
/login              → LoginScreen
/home               → HomeScreen (tabs: Feed / Dashboard / Alertas)
/admin              → AdminPanelScreen (somente ADMIN)
/alerts/:id         → AlertDetailsScreen
/critical           → CriticalBlockScreen (bloqueio automático)
```

### Fluxo de autenticação

```
App inicia
    │
    ▼
SplashScreen lê token do SharedPreferences
    │
    ├── Token válido → restaura sessão → HomeScreen
    └── Sem token / expirado → LoginScreen
              │
              ▼
        POST /api/auth/login
              │
              ├── 200 OK → salva token + user → HomeScreen
              └── 401    → exibe erro
```

### Tratamento de notificações push (FCM)

1. `NotificationService.init()` é chamado no `main.dart`.
2. Solicita permissão ao usuário no primeiro acesso.
3. Obtém o FCM token e sincroniza com o backend via `PATCH /api/users/:id`.
4. Escuta três canais:
   - `onMessage` — app em foreground → exibe banner overlay.
   - `onMessageOpenedApp` — app em background, usuário tocou na notificação.
   - `getInitialMessage` — app fechado, aberto pela notificação.
5. Notificações CRITICAL disparam `CriticalBlockScreen` automaticamente.
6. Alerta sonoro reproduzido via `audioplayers` (`assets/sounds/notifSound.mp3`).

### Bloqueio por notificação crítica

```
alertProvider.checkBlocking()  (chamado ao abrir o app e a cada 30s)
    │
    ├── GET /api/assignments/blocking
    │
    └── Se retornar assignments CRITICAL não confirmados
              │
              ▼
        go_router redireciona para /critical
              │
              ▼
        CriticalBlockScreen (modal fullscreen, não dispensável)
              │
              ▼
        Usuário toca "Estou ciente"
              │
              ▼
        POST /api/assignments/:id/acknowledge
              │
              ▼
        alertProvider atualiza estado → app desbloqueado
```

### Polling

O frontend consulta o backend periodicamente para manter os dados atualizados:

| Endpoint | Intervalo | Finalidade |
|---|---|---|
| `GET /assignments/mine` | 30 segundos | Atualizar lista de alertas |
| `GET /assignments/blocking` | 30 segundos | Verificar bloqueio crítico |

### HTTP Client (`api_client.dart`)

- Injeta o header `Authorization: Bearer <token>` em todas as requisições.
- Timeout de 20 segundos por requisição.
- Em caso de resposta `401`, chama `authProvider.logout()` e redireciona para o login.

### Tema visual

Definido em `core/theme/app_theme.dart`:

| Elemento | Valor |
|---|---|
| Fonte principal | Google Fonts (Poppins) |
| Cor primária | Azul corporativo |
| LOW | Verde |
| MEDIUM | Âmbar |
| HIGH | Laranja |
| CRITICAL | Vermelho |

---

## Implantação (Vercel)

### Arquivo `vercel.json`

```json
{
  "routes": [
    { "src": "/api/(.*)", "dest": "apps/api/src/main.ts" },
    { "src": "/assets/(.*)", "dest": "apps/web/build/web/assets/$1" },
    { "src": "/canvaskit/(.*)", "dest": "apps/web/build/web/canvaskit/$1" },
    { "src": "/icons/(.*)", "dest": "apps/web/build/web/icons/$1" },
    { "src": "/(.*\\.(js|wasm|json|png|css))", "dest": "apps/web/build/web/$1" },
    { "src": "/(.*)", "dest": "apps/web/build/web/index.html" }
  ]
}
```

- Requisições para `/api/*` são roteadas para a função serverless NestJS.
- Todo o restante serve os arquivos estáticos do build Flutter ou retorna o `index.html` (SPA fallback).

### Deploy automático

Qualquer push para a branch `main` dispara um deploy automático na Vercel.

### Build do frontend

```bash
cd apps/web
flutter build web
```

O artefato gerado em `apps/web/build/web/` deve ser commitado junto com o código-fonte para ser servido pela Vercel.

### Variáveis de ambiente (backend)

| Variável | Descrição |
|---|---|
| `DATABASE_URL` | URL de conexão PostgreSQL via PgBouncer (porta 6543) |
| `DIRECT_URL` | URL direta PostgreSQL para migrações Prisma (porta 5432) |
| `JWT_SECRET` | Chave secreta para assinar tokens JWT |
| `JWT_EXPIRES_IN` | Tempo de expiração do token (ex: `7d`) |
| `FIREBASE_PROJECT_ID` | ID do projeto Firebase |
| `FIREBASE_CLIENT_EMAIL` | E-mail da conta de serviço Firebase |
| `FIREBASE_PRIVATE_KEY` | Chave privada da conta de serviço Firebase |

---

## Banco de Dados

### Conexão

| Uso | URL | Porta |
|---|---|---|
| Aplicação (runtime) | `DATABASE_URL` via PgBouncer | 6543 |
| Migrações Prisma | `DIRECT_URL` direto ao Supabase | 5432 |

O PgBouncer é necessário em ambiente serverless para evitar esgotamento de conexões.

### Comandos Prisma

```bash
# Gerar o Prisma Client após alterar o schema
npx prisma generate

# Criar e aplicar nova migração
npx prisma migrate dev --name <nome-da-migracao>

# Aplicar migrações em produção
npx prisma migrate deploy

# Popular banco com dados de teste
npx prisma db seed

# Abrir o Prisma Studio (interface visual do banco)
npx prisma studio
```

---

## Desenvolvimento Local

### Pré-requisitos

- Node.js 18+
- Flutter SDK 3.x
- PostgreSQL (ou acesso ao Supabase)
- Conta Firebase com projeto configurado

### Backend

```bash
cd apps/api
npm install
cp .env.example .env   # preencher variáveis de ambiente
npx prisma migrate dev
npm run start:dev      # inicia na porta 5050
```

### Frontend

```bash
cd apps/web
flutter pub get
flutter run -d chrome  # aponta para http://localhost:5050/api
```

### Testes

```bash
# Backend
cd apps/api
npm run test        # testes unitários
npm run test:e2e    # testes end-to-end

# Frontend
cd apps/web
flutter test
flutter test test/features/<feature>/
```

---

## Diagrama de Arquitetura

```
┌─────────────────────────────────────────────┐
│                  Vercel                      │
│                                              │
│  ┌──────────────┐     ┌──────────────────┐  │
│  │  Flutter Web  │     │   NestJS API     │  │
│  │  (SPA estática│     │  (Serverless Fn) │  │
│  │  /build/web) │     │  /api/*          │  │
│  └──────┬───────┘     └────────┬─────────┘  │
│         │                      │             │
└─────────┼──────────────────────┼─────────────┘
          │                      │
          │ HTTP (JWT)            │ Prisma (PgBouncer)
          │                      │
   ┌──────▼──────┐      ┌────────▼────────┐
   │   Navegador  │      │   Supabase      │
   │   do usuário │      │   PostgreSQL    │
   └─────────────┘      └─────────────────┘
          │                      
          │ FCM Push              
   ┌──────▼──────┐      ┌─────────────────┐
   │  Firebase   │◄─────│  Firebase Admin │
   │  Cloud Msg  │      │  SDK (backend)  │
   └─────────────┘      └─────────────────┘
```

---

## Decisões de Design

### Por que Flutter Web?
Permite compartilhar código com uma eventual versão mobile (iOS/Android) sem reescrever a UI. O build gera um SPA que é servido diretamente pela Vercel sem necessidade de servidor Node.js dedicado para o frontend.

### Por que NestJS serverless?
A carga da aplicação é de uso interno corporativo, com picos pontuais. O modelo serverless na Vercel elimina custo de servidor ocioso e escala automaticamente.

### Por que o build do Flutter é commitado?
A Vercel não executa `flutter build web` durante o CI/CD por falta de suporte nativo ao Flutter SDK. O artefato compilado é versionado junto com o código e servido como arquivos estáticos.

### Por que PgBouncer?
Funções serverless criam novas conexões ao banco a cada invocação. O PgBouncer atua como pool de conexões, evitando que o limite de conexões do PostgreSQL seja atingido.

### Por que Riverpod e não BLoC ou Provider?
Riverpod elimina a necessidade de `BuildContext` para acessar estado, facilita estado computado (providers derivados) e tem melhor suporte a operações assíncronas com `AsyncValue`.
