# TODO — Roadmap de Desenvolvimento

> Atualizado em 10/04/2026.  
> Edições são feitas **somente no frontend** (`frontend/`).  
> 128 testes passando na última sessão.

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
| `AlertAdminScreen` | `loadNotifications()` e `loadSectors()` chamados no `initState` |
| `dashboard_provider` | Reescrito: taxa de adesão por setor derivada de `notifications` + `assignments` reais |
| `dashboard_screen` | Corrigido: removidas referências a métodos inexistentes |
| `errorMessage` no `AlertState` | `AlertNotifier` propaga erros; telas exibem SnackBar vermelho |
| Interceptação de 401 | `ApiClient.onUnauthorized` chama `authProvider.logout()` automaticamente |
| `authInitProvider` | Splash durante restore de sessão no startup |
| Base URL unificada | `ApiClient.baseUrl = 'http://localhost:3000'` — único ponto de configuração |
| `SectorModel` + `SectorService` + `sectorProvider` | `GET /sectors` com estado, loading e errorMessage |
| `CreateAlertModal` setores reais | Chips carregados do backend; envia `sector.id` (UUID); dropdown de `slaMinutes` |
| `AlertAdminScreen` filtro real | Filtro usa `sector.id` vs `alert.targetSectorId` — sem nomes hardcoded |
| `UserModel.sector` → nome legível | `AuthNotifier` resolve `sectorId → sectorName` via `SectorService` após login/restore |

---

## 🔴 Crítico — Quebra a integração

### 1. Confirmar/implementar PATCH `/assignments/{id}` no backend

**Arquivo de referência:** `.backend-architecture.md`

**Problema:** a arquitetura registra que o endpoint de update de assignments está comentado no backend. O frontend já chama `PATCH /assignments/{id}` para `markAsViewed` e `acknowledge`, mas as transições de estado (`PENDING → VIEWED → ACKNOWLEDGED`) falham silenciosamente.

**Consequências:**
- `isBlocked` nunca volta a `false` após confirmação
- Taxa de adesão no dashboard sempre 0% (nenhum assignment chega a `ACKNOWLEDGED`)
- `_AssignmentCard` exibe status obsoleto

**O que fazer:**
- Descomentar/implementar `PATCH /assignments/{id}` no backend com `{ status: "VIEWED" | "ACKNOWLEDGED" }`
- Testar o ciclo completo `PENDING → VIEWED → ACKNOWLEDGED` end-to-end

---

### 2. `_AssignmentCard` exibe UUID no lugar do título da notificação

**Arquivo:** `frontend/lib/features/alerts/screen/alerts_user_screen.dart`

**Problema:** `_AssignmentCard` usa `assignment.notificationId` como título, exibindo um UUID bruto. O employee não consegue identificar de qual notificação se trata.

**O que fazer:**
- Cruzar `assignment.notificationId` com `state.notifications` para exibir o título correto
- Alternativa: verificar se `GET /assignments` pode retornar `notificationTitle` embutido (economiza o cruzamento)
- Nota: employees não têm acesso a `GET /notifications` — se optar pelo cruzamento, garantir que as notifications estejam disponíveis no estado

---

### 3. Dashboard não carrega assignments para supervisores

**Arquivo:** `frontend/lib/features/dashboard/screens/dashboard_screen.dart`

**Problema:** `dashboardProvider` deriva taxa de adesão cruzando `notifications` com `assignments`. O dashboard chama `loadNotifications()`, mas assignments só são carregados na `AlertUserScreen` (employee). Supervisor que abre o dashboard direto vê taxa sempre vazia.

**O que fazer:**
- Verificar se `GET /assignments` retorna todos os assignments quando chamado por supervisor
- Se sim: chamar `loadAssignments()` no `initState` do `DashboardScreen`
- Se não: avaliar endpoint dedicado no backend

---

## 🟡 Dados / UX

### 4. Aba "Histórico" no `AlertAdminScreen` sempre vazia

**Arquivo:** `frontend/lib/features/alerts/screen/alerts_admin_screen.dart:101`

**Problema:** `_buildListContent(const [], false, sectorState, isHistory: true)` — hardcoded como lista vazia.

**O que fazer:** definir com base nos dados disponíveis (ex: notificações com `createdAt` anterior a X dias) ou **remover a aba** temporariamente até existir endpoint dedicado.

---

### 5. Tela de detalhes da notificação (`alert_details_screen.dart`) — estática

**Arquivo:** `frontend/lib/features/alerts/screen/alert_details_screen.dart`

**Problema:** widget estático antigo com dados hardcoded, não integrado ao fluxo real.

**O que fazer:** reescrever recebendo `AssignmentModel` como parâmetro; navegar para ela ao tocar em `_AssignmentCard`; exibir título, mensagem, nível, prazo, status e botão de confirmação.

---

### 6. `UserModel` duplicado

**Arquivos:**
- `frontend/lib/core/model/user_model.dart` ← ativo
- `frontend/lib/features/home/model/user_model.dart` ← obsoleto

**O que fazer:** verificar imports; deletar o duplicado se não for usado.

---

## 🔵 Sem backend ainda — aguarda implementação

| Item | Situação |
|---|---|
| **Feed de posts** | `PostService` 100% mock. Sem endpoint no backend. |
| **Notices (Avisos)** | `notice_service.dart` e `notice_screen.dart` vazios. Feature não iniciada. |
| **`fcmToken`** | Backend retorna o campo; `UserModel` não o armazena. |
| **`go_router`** | Incluso mas inativo. Sem deep linking nem rotas nomeadas. |

---

## Ordem de execução sugerida

```
── Fase 1: Dados corretos ────────────────────────────────────────
1. [BACKEND] Habilitar PATCH /assignments/{id}     ← pré-req para 2 e 3
2. Título real no _AssignmentCard                  ← depende de 1 (ou embedding no GET /assignments)
3. loadAssignments no DashboardScreen              ← depende de 1

── Fase 2: UX e limpeza ─────────────────────────────────────────
4. Aba Histórico: definir ou remover               ← independente
5. AlertDetailsScreen integrada                    ← independente
6. Remover UserModel duplicado                     ← independente (5 min)

── Fase 3: Novas features ───────────────────────────────────────
7. Feed de posts com API real                      ← depende de backend
8. Notices (Avisos) — feature do zero              ← depende de backend
```
