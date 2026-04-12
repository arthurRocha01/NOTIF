# TODO — Roadmap de Desenvolvimento

> Atualizado em 12/04/2026.  
> Edições são feitas **somente no frontend** (`frontend/`).  
> 145 testes passando na última sessão.

---

## ✅ Concluído

| Item | Descrição |
|---|---|
| Auth completo | Login, logout, restore de sessão via `TokenStorage` + `SharedPreferences` |
| `AlertModel` + `AssignmentModel` | Modelos mapeando `Notification` e `NotificationAssignment` do backend |
| `AlertService` | `GET /notifications`, `POST /notifications`, `GET /assignments`, `PATCH /assignments/{id}` |
| `AlertNotifier` | `loadNotifications`, `loadAssignments`, `createNotification`, `markAsViewed`, `acknowledge` |
| `isBlocked` | Calculado: qualquer assignment CRITICAL não ACKNOWLEDGED bloqueia |
| `AlertUserScreen` | Reescrita com dados reais; `markAsViewed` chamado automaticamente no carregamento |
| `AlertAdminScreen` | Aba "Notificações" + aba "Minhas notificações" para supervisor; loadNotifications + loadAssignments no initState |
| `AssignmentsBody` | Widget compartilhado de lista de assignments (employee + supervisor) |
| `dashboard_provider` | Reescrito: taxa de adesão por setor derivada de `notifications` + `assignments` reais |
| `DashboardScreen` | `loadNotifications()` + `loadAssignments()` chamados no `initState` |
| `errorMessage` no `AlertState` | `AlertNotifier` propaga erros; telas exibem SnackBar vermelho |
| Interceptação de 401 | `ApiClient.onUnauthorized` chama `authProvider.logout()` automaticamente |
| `authInitProvider` | Splash durante restore de sessão no startup |
| Base URL unificada | `ApiClient.baseUrl = 'http://localhost:3000'` — único ponto de configuração |
| `SectorModel` + `SectorService` + `sectorProvider` | `GET /sectors` com estado, loading e errorMessage |
| `CreateAlertModal` setores reais | Chips carregados do backend; envia `sector.id` (UUID); dropdown de `slaMinutes` |
| `AlertAdminScreen` filtro real | Filtro usa `sector.id` vs `alert.targetSectorId` — sem nomes hardcoded |
| `UserModel.sector` → nome legível | `AuthNotifier` resolve `sectorId → sectorName` via `SectorService` após login/restore |
| `UserModel` duplicado removido | `features/home/model/user_model.dart` deletado |
| `notificationTitle` + `notificationMessage` | Campos opcionais em `AssignmentModel`, parseados do JSON do backend |
| `_AssignmentCard` título real | Exibe `notificationTitle` com fallback `'Notificação'` |
| `AlertDetailsScreen` integrada | Recebe `AssignmentModel`; exibe título, mensagem, nível, prazo, status e botão de confirmação |
| `AccountScreen` setor e cargo | Setor e Cargo exibidos na seção Identificação via `authProvider` |

---

## 🔴 Crítico — Quebra a integração

### 1. Habilitar `PATCH /assignments/{id}` no backend

**Problema:** endpoint comentado no backend. `markAsViewed` e `acknowledge` falham silenciosamente.

**Consequências:**
- `isBlocked` nunca volta a `false` após confirmação
- Taxa de adesão no dashboard sempre 0%
- Status nos cards/tela de detalhes nunca atualiza

**O que fazer:** descomentar/implementar `PATCH /assignments/{id}` com `{ status: "VIEWED" | "ACKNOWLEDGED" }` e testar o ciclo completo.

---

### 2. Retornar `notificationTitle` e `notificationMessage` no `GET /assignments`

**Problema:** `AssignmentModel` já parseia esses campos, mas o backend não os retorna embutidos ainda. Cards exibem fallback `'Notificação'` e `AlertDetailsScreen` não exibe mensagem.

**O que fazer:** incluir `notificationTitle` e `notificationMessage` (da tabela `notifications`) na query do `GET /assignments`.

---

## 🟡 Médio — Funciona, mas incompleto

### 3. Trocar senha e Recuperar senha

**Arquivo:** `frontend/lib/features/profile/screen/account_screen.dart` (linhas 135 e 252)

**Problema:** modais existem e validam os campos, mas chamam `TODO` em vez da API.

**O que fazer (backend):** implementar `PATCH /users/{id}/password` e `POST /auth/password-reset`.  
**O que fazer (frontend):** chamar esses endpoints nos modais quando disponíveis.

---

### 4. Feed de posts — 100% mock

**Arquivo:** `frontend/lib/features/home/services/post_service.dart`

**Problema:** `PostService` usa 4 posts hardcoded. `toggleLike()` e `deletePost()` são métodos vazios. `PostModel` não tem `fromJson`/`toJson`.

**O que fazer (backend):** implementar `GET /posts`, `POST /posts`, `POST /posts/{id}/like`, `DELETE /posts/{id}`.  
**O que fazer (frontend):** reescrever `PostService` consumindo API real; adicionar `fromJson`/`toJson` ao `PostModel`.

---

### 5. Notices (Avisos) — feature não iniciada

**Arquivos:** `notice_service.dart` (vazio), tela de avisos inexistente.

**O que fazer:** definir endpoints com o backend, implementar a feature do zero.

---

## 🔵 Estrutural — Preparação para API futura

| Item | Arquivo | Situação |
|---|---|---|
| `fcmToken` | `core/model/user_model.dart` | Backend retorna o campo; `UserModel` não o armazena |
| Upload de avatar | `profile/data/profile_repository.dart` | Salva apenas em `SharedPreferences`; sem chamada de upload |
| `go_router` | `main.dart` | Incluso mas inativo — sem deep linking nem rotas nomeadas |
| `dashboard_service.dart` | `dashboard/` | Arquivo existe mas nunca é chamado; cálculo feito localmente no provider |

---

## Ordem de execução sugerida

```
── Fase 1: Backend urgente ──────────────────────────────────────
1. [BACKEND] Habilitar PATCH /assignments/{id}
2. [BACKEND] Retornar notificationTitle + notificationMessage no GET /assignments
3. Testar ciclo PENDING → VIEWED → ACKNOWLEDGED end-to-end

── Fase 2: Backend médio ────────────────────────────────────────
4. [BACKEND] PATCH /users/{id}/password + POST /auth/password-reset
5. [FRONTEND] Integrar modais de senha com a API
6. [BACKEND] Endpoints de posts (GET, POST, like, delete)
7. [FRONTEND] Reescrever PostService + PostModel com API real

── Fase 3: Novas features ───────────────────────────────────────
8. Notices (Avisos) — feature do zero (depende de backend)
9. Aba Histórico — reintroduzir (depende de endpoint dedicado)
10. Upload de avatar (depende de backend)
```
