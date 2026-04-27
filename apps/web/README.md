# Notif Web

Frontend do sistema **Notif** — aplicativo Flutter Web para gestão e recebimento de notificações corporativas com controle de leitura, confirmação e SLA.

Construído com **Flutter**, **Riverpod** e **Firebase Cloud Messaging**. Deploy estático na **Vercel**.

---

## Tecnologias

- **Flutter** — framework multiplataforma (web)
- **Flutter Riverpod 2** — gerenciamento de estado reativo
- **Firebase Messaging** — push notifications via FCM
- **fl_chart** — gráficos de barra e rosca
- **Google Fonts / Lucide Icons** — tipografia e ícones
- **SharedPreferences** — persistência local de sessão

---

## Estrutura

```
lib/
├── core/
│   ├── api/            # ApiClient com retry e injeção de token
│   ├── model/          # UserModel e enums de papel
│   ├── notifications/  # Integração FCM + notificações locais
│   ├── storage/        # TokenStorage (SharedPreferences)
│   ├── theme/          # AppTheme, cores, espaçamentos, raios
│   └── utils/          # Formatadores de data
├── features/
│   ├── admin/          # Painel administrativo
│   ├── alerts/         # Notificações e assignments
│   ├── dashboard/      # Métricas e KPIs
│   ├── home/           # Feed de posts
│   ├── login/          # Autenticação e sessão
│   ├── profile/        # Perfil do usuário
│   └── sectors/        # Setores organizacionais
└── shared/             # Widgets reutilizáveis
```

---

## Features

### Login
Autenticação por e-mail e senha com persistência de sessão via SharedPreferences. Na inicialização, a sessão é restaurada automaticamente se o token armazenado for válido.

### Alerts
Núcleo do sistema. Exibe as notificações do usuário com suporte a:
- Níveis de urgência: **LOW**, **MEDIUM**, **HIGH**, **CRITICAL**
- Estados de assignment: **PENDING** → **VIEWED** → **ACKNOWLEDGED** / **OVERDUE**
- Notificações CRITICAL disparam overlay em tela cheia com alerta sonoro e bloqueiam o app até confirmação
- Banners in-app para notificações recebidas em tempo real

### Dashboard
Painel analítico exclusivo para supervisores e admins:
- KPIs: total de assignments, confirmados, pendentes e críticos
- Gráfico de barras com taxa de adesão por setor
- Gráfico de rosca com detalhamento do setor selecionado
- Filtros por período (7 dias, 30 dias, todos) e por setor
- Destaque do setor com maior taxa de adesão

### Home (Feed)
Feed de posts publicados pelos supervisores. Suporta criação, curtidas e exclusão.

### Admin
Painel exclusivo para admins com gestão completa de usuários e setores.

### Profile
Visualização e edição do perfil do usuário autenticado.

---

## Navegação

A rota inicial é determinada pelo estado de autenticação e papel do usuário:

```
App
├── LoginScreen          (não autenticado)
├── AdminPanelScreen     (role: admin)
└── HomeScreen           (role: employee / supervisor)
     ├── Feed            (aba 0)
     ├── Dashboard        (aba 1 — supervisor/admin)
     └── Alerts           (aba 2)
```

---

## Gerenciamento de Estado

Todos os providers usam **Riverpod StateNotifier** com estados imutáveis e `copyWith()`.

| Provider | Tipo | Responsabilidade |
|---|---|---|
| `authProvider` | StateNotifier | Sessão, login, logout |
| `alertProvider` | StateNotifier | Notificações, assignments, bloqueio crítico |
| `sectorProvider` | StateNotifier | Lista de setores |
| `dashboardProvider` | Provider | Métricas calculadas a partir do alertProvider |
| `dashboardFilterProvider` | StateNotifier | Filtros de período e setor |
| `profileProvider` | StateNotifier | Avatar e nome de exibição |
| `adminUserProvider` | StateNotifier | Gestão de usuários (admin) |
| `adminSectorProvider` | StateNotifier | Gestão de setores (admin) |

---

## Autenticação

1. Usuário faz login → POST `/auth/login` → token JWT retornado
2. Token salvo em SharedPreferences e injetado em todas as requisições via `ApiClient`
3. Dados do usuário buscados por e-mail → GET `/users/by-email/{email}`
4. Token FCM sincronizado silenciosamente com o backend
5. Respostas 401 disparam logout automático via callback `ApiClient.onUnauthorized`

---

## API Client

`lib/core/api/api_client.dart` centraliza todas as requisições HTTP:

- URL base: `${Uri.base.origin}/api` (web) · `http://localhost:5050/api` (local)
- Token JWT injetado automaticamente no header `Authorization: Bearer`
- Header `Cache-Control: no-cache` para evitar respostas cacheadas
- Retry automático em erros 5xx com backoff exponencial: 800ms → 2s → 4s
- Timeout de 20 segundos por requisição

---

## Push Notifications

Integração com **Firebase Cloud Messaging**:

- Solicitação de permissão na inicialização
- Token FCM sincronizado com o backend para entrega direcionada
- Notificações em foreground exibem banner in-app
- Notificações CRITICAL ativam overlay bloqueante com alerta sonoro (`assets/sounds/notice.notif.wav`)
- Atualização automática do token quando o Firebase o renova

---

## Tema

Paleta baseada em azul corporativo:

| Token | Valor | Uso |
|---|---|---|
| Primary | `#1A2340` | Fundo de headers, drawer |
| Accent | `#4A6CF7` | Ações, botões, indicadores ativos |
| LOW | Verde | Notificações de baixa urgência |
| MEDIUM | Âmbar | Notificações de média urgência |
| HIGH | Laranja | Notificações de alta urgência |
| CRITICAL | Vermelho | Notificações críticas |

Tipografia: **Inter** (Google Fonts). Escala de espaçamento em base 4px (xs=4 → huge=48).

---

## Testes

Testes de integração em `test/features/`, organizados por feature:

```
test/features/
├── alerts/       # Ciclo de vida, bloqueio, overdue, push delivery, conflitos
├── login/        # Auth service, FCM token
├── admin/        # Gestão de usuários e setores
├── sectors/      # Sector service
├── dashboard/    # Métricas e filtros
└── notifications/ # Canal de notificações
```

Executar todos os testes de uma feature:

```bash
flutter test test/features/<feature>/
```

Executar todos:

```bash
flutter test
```

---

## Build e Deploy

O frontend é compilado como aplicação web estática e servido pela Vercel via `@vercel/static`.

```bash
flutter build web --release
```

O artefato gerado em `build/web/` é incluído no repositório e referenciado pelo `vercel.json` na raiz do monorepo.
