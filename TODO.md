# TODO — Roadmap de Desenvolvimento

> Atualizado em 12/04/2026.  
> Edições são feitas **somente no frontend** (`frontend/`).  
> 141 testes passando na última sessão.

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
| `AlertAdminScreen` | `loadNotifications()` e `loadSectors()` chamados no `initState`; aba "Histórico" removida |
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
| `_AssignmentCard` tappable | Toque no card navega para `AlertDetailsScreen` |

---

## 🔴 Crítico — Quebra a integração

### 1. Confirmar/implementar PATCH `/assignments/{id}` no backend

**Arquivo de referência:** `.backend-architecture.md`

**Problema:** o endpoint de update de assignments está comentado no backend. O frontend já chama `PATCH /assignments/{id}` para `markAsViewed` e `acknowledge`, mas as transições de estado (`PENDING → VIEWED → ACKNOWLEDGED`) falham silenciosamente.

**Consequências:**
- `isBlocked` nunca volta a `false` após confirmação
- Taxa de adesão no dashboard sempre 0% (nenhum assignment chega a `ACKNOWLEDGED`)
- `_AssignmentCard` e `AlertDetailsScreen` exibem status obsoleto

**O que fazer:**
- Descomentar/implementar `PATCH /assignments/{id}` no backend com `{ status: "VIEWED" | "ACKNOWLEDGED" }`
- Testar o ciclo completo `PENDING → VIEWED → ACKNOWLEDGED` end-to-end
- Verificar se o backend pode retornar `notificationTitle` e `notificationMessage` embutidos no `GET /assignments`

---

## 🔵 Sem backend ainda — aguarda implementação

| Item | Situação |
|---|---|
| **`notificationTitle` / `notificationMessage` embutidos** | `AssignmentModel` já parseia os campos — backend precisa retorná-los no `GET /assignments` |
| **Aba "Histórico"** | Removida temporariamente; requer endpoint dedicado no backend |
| **Feed de posts** | `PostService` 100% mock. Sem endpoint no backend. |
| **Notices (Avisos)** | `notice_service.dart` e `notice_screen.dart` vazios. Feature não iniciada. |
| **`fcmToken`** | Backend retorna o campo; `UserModel` não o armazena. |
| **`go_router`** | Incluso mas inativo. Sem deep linking nem rotas nomeadas. |

---

## Ordem de execução sugerida

```
── Fase 1: Backend ──────────────────────────────────────────────
1. [BACKEND] Habilitar PATCH /assignments/{id}
2. [BACKEND] Retornar notificationTitle + notificationMessage no GET /assignments
3. Testar ciclo PENDING → VIEWED → ACKNOWLEDGED end-to-end

── Fase 2: Novas features ───────────────────────────────────────
4. Feed de posts com API real          ← depende de backend
5. Notices (Avisos) — feature do zero  ← depende de backend
6. Aba Histórico — reintroduzir        ← depende de endpoint dedicado
```
