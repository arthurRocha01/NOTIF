# Notif API

Backend do sistema **Notif** — plataforma de notificações corporativas com controle de leitura, confirmação e SLA por setor.

Construído com **NestJS**, **Prisma** e **PostgreSQL** (Supabase). Deploy serverless na **Vercel** com push notifications via **Firebase Cloud Messaging**.

---

## Tecnologias

- **NestJS 11** — framework HTTP com injeção de dependência
- **Prisma 6** — ORM com migrations e Prisma Studio
- **PostgreSQL** via Supabase (connection pooling com PgBouncer)
- **Passport JWT** — autenticação stateless
- **Firebase Admin SDK** — push notifications (FCM)
- **Swagger** — documentação interativa da API

---

## Arquitetura

Cada módulo segue **Clean Architecture** com quatro camadas:

```
modules/<nome>/
├── domain/           # Entidades, interfaces de repositório
├── application/      # Serviços de negócio
├── infrastructure/   # Repositórios Prisma, FCM, mappers
└── presentation/     # Controllers, DTOs, decorators
```

### Módulos

| Módulo | Responsabilidade |
|---|---|
| `auth` | Login, geração e validação de JWT |
| `users` | Gestão de usuários com papéis e setores |
| `sectors` | Unidades organizacionais (departamentos) |
| `notifications` | Criação e distribuição de notificações |
| `assignments` | Ciclo de vida da notificação por usuário |

---

## Banco de Dados

### Modelos principais

**User** — funcionário, supervisor ou admin, vinculado a um setor.

**Sector** — departamento da organização.

**Notification** — notificação criada por supervisor; pode ser global ou segmentada por setor, com nível de prioridade e SLA.

**NotificationAssignment** — vínculo entre usuário e notificação. Representa o estado de leitura de cada usuário.

### Estados de um assignment

```
PENDING ──view──> VIEWED ──acknowledge──> ACKNOWLEDGED
   └──(SLA expirado)──> OVERDUE
```

### Enums

```
UserRole:          EMPLOYEE | SUPERVISOR | ADMIN
NotificationLevel: LOW | MEDIUM | HIGH | CRITICAL
AssignmentStatus:  PENDING | VIEWED | ACKNOWLEDGED | OVERDUE
```

---

## Autenticação e Autorização

Três camadas de controle aplicadas globalmente via `APP_GUARD`:

1. **JwtAuthGuard** — valida Bearer token em todas as rotas (exceto `@Public()` e arquivos estáticos)
2. **RolesGuard** — restringe rotas pelo decorator `@Roles('SUPERVISOR', 'ADMIN')`
3. **CriticalBlockGuard** — bloqueia o acesso se o usuário tiver assignments CRITICAL não confirmados; bypassável com `@BypassBlock()`

---

## Rotas da API

Base path: `/api` · Swagger: `/api/swagger`

### Auth

| Método | Rota | Auth | Descrição |
|---|---|---|---|
| POST | `/auth/login` | Pública | Autenticar e obter token JWT |

### Users

| Método | Rota | Auth | Role | Descrição |
|---|---|---|---|---|
| GET | `/users` | JWT | SUPERVISOR, ADMIN | Listar todos os usuários |
| GET | `/users/:id` | JWT | — | Buscar usuário por ID |
| GET | `/users/by-email/:email` | JWT | — | Buscar usuário por e-mail |
| POST | `/users` | Pública | — | Cadastrar novo usuário |
| PATCH | `/users/:id` | JWT | — | Atualizar perfil |
| DELETE | `/users/:id` | JWT | ADMIN | Remover usuário |

### Sectors

| Método | Rota | Auth | Descrição |
|---|---|---|---|
| GET | `/sectors` | JWT | Listar setores |
| GET | `/sectors/:id` | JWT | Buscar setor por ID |
| POST | `/sectors` | Pública | Criar setor |
| PATCH | `/sectors/:id` | JWT | Atualizar setor |
| DELETE | `/sectors/:id` | JWT | Remover setor |

### Notifications

| Método | Rota | Auth | Role | Descrição |
|---|---|---|---|---|
| GET | `/notifications` | JWT | — | Listar notificações |
| GET | `/notifications/:id` | JWT | — | Detalhes de uma notificação |
| POST | `/notifications` | JWT | SUPERVISOR | Criar e distribuir notificação |
| PATCH | `/notifications/:id` | JWT | — | Atualizar notificação |
| DELETE | `/notifications/:id` | JWT | — | Remover notificação |

### Assignments

| Método | Rota | Auth | Role | Descrição |
|---|---|---|---|---|
| GET | `/assignments` | JWT | SUPERVISOR, ADMIN | Listar todos os assignments |
| GET | `/assignments/mine` | JWT | — | Assignments do usuário autenticado |
| GET | `/assignments/blocking` | JWT | — | Assignments CRITICAL bloqueantes |
| GET | `/assignments/:id` | JWT | — | Detalhes de um assignment |
| POST | `/assignments/sync` | JWT | — | Sincronizar entrega de notificações |
| POST | `/assignments/:id/view` | JWT | — | Marcar como visualizado |
| POST | `/assignments/:id/acknowledge` | JWT | — | Confirmar leitura |
| DELETE | `/assignments/:id` | JWT | — | Remover assignment |

---

## Variáveis de Ambiente

```env
# Conexão via PgBouncer (pooling)
DATABASE_URL="postgresql://user:pass@host:6543/db?pgbouncer=true&connection_limit=1"

# Conexão direta (migrations)
DIRECT_URL="postgresql://user:pass@host:5432/db"

# JWT
JWT_SECRET="..."
JWT_EXPIRES_IN="1d"

# Firebase Admin SDK
GOOGLE_APPLICATION_CREDENTIALS="./notif-72c72-firebase-adminsdk-fbsvc-75966c08f3.json"
```

> Em produção na Vercel, `DATABASE_URL` e `DIRECT_URL` são configuradas no painel do projeto.

---

## Scripts

```bash
# Desenvolvimento
npm run start:dev       # Servidor com hot reload
npm run start:debug     # Modo debug (porta 9229)

# Build
npm run build           # Compila TypeScript
npm run start:prod      # Executa build compilado

# Prisma
npm run prisma:generate # Gera Prisma Client
npm run prisma:migrate  # Executa migrations
npm run prisma:studio   # GUI do banco de dados
npm run prisma:seed     # Popula o banco com dados iniciais

# Testes
npm run test            # Testes unitários
npm run test:watch      # Modo watch
npm run test:cov        # Cobertura
npm run test:e2e        # Testes end-to-end

# Qualidade
npm run lint            # ESLint com auto-fix
npm run format          # Prettier
```

---

## Deploy

O backend é exportado como handler serverless para a Vercel:

```ts
// src/main.ts
export default async function handler(req, res) { ... }
```

O build é disparado automaticamente pelo `vercel-build`:

```bash
prisma generate && nest build
```

A instância do NestJS é cacheada entre invocações para reduzir cold starts.

---

## Push Notifications

O `FcmService` usa Firebase Admin SDK para enviar notificações via FCM:

- Notificações **CRITICAL** são enviadas individualmente com prioridade alta
- Demais níveis usam multicast por lote
- Tokens inválidos são removidos automaticamente do usuário

---

## Tarefas Agendadas

`OverdueCheckerService` roda a cada minuto via `@Cron` para verificar assignments cujo `dueAt` expirou e atualiza o status para `OVERDUE`.
