# TODO — Roadmap de Desenvolvimento

> Atualizado em 10/04/2026.  
> Edições são feitas **somente no frontend** (`frontend/`).  
> 115 testes passando na última sessão.

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
| `AlertAdminScreen` | `loadNotifications()` chamado no `initState` via `addPostFrameCallback` |
| `dashboard_provider` | Reescrito: taxa de adesão por setor derivada de `notifications` + `assignments` reais |
| `dashboard_screen` | Corrigido: removidas referências a métodos inexistentes |
| `errorMessage` no `AlertState` | `AlertNotifier` propaga `AlertServiceException` e `ApiException`; telas exibem SnackBar |
| Interceptação de 401 | `ApiClient.onUnauthorized` chama `authProvider.logout()` automaticamente |
| `authInitProvider` | Splash durante restore de sessão no startup |
| Base URL unificada | `ApiClient.baseUrl = 'http://localhost:3000'` — único ponto de configuração |

---

## 🔴 Crítico — Quebra a integração

### 1. Confirmar/implementar PATCH `/assignments/{id}` no backend

**Arquivo de referência:** `.backend-architecture.md`

**Problema:** a arquitetura registra que o endpoint de update de assignments está comentado no backend. O frontend já chama `PATCH /assignments/{id}` para `markAsViewed` e `acknowledge`, mas as transições de estado (`PENDING → VIEWED → ACKNOWLEDGED`) podem estar falhando silenciosamente.

**O que fazer:**
- Descomentar/implementar `PATCH /assignments/{id}` no backend com `{ action: "view" | "acknowledge" }`
- Testar o ciclo completo `PENDING → VIEWED → ACKNOWLEDGED` end-to-end
- Verificar que `isBlocked` reflete o estado real do backend após confirmação

---

### 2. `_AssignmentCard` exibe UUID no lugar do título da notificação

**Arquivo:** `frontend/lib/features/alerts/screen/alerts_user_screen.dart`

**Problema:** `_AssignmentCard` usa `assignment.notificationId` como título, exibindo um UUID bruto para o usuário. `AssignmentModel` não carrega o título da notification.

**O que fazer:**
- Opção A: `AlertService.getMyAssignments` retorna assignments com `notificationTitle` embutido (se o backend suportar)
- Opção B: cruzar `assignment.notificationId` com a lista `state.notifications` no widget para exibir o título correto
- Testar que o título aparece corretamente mesmo quando a lista de notifications está vazia (employee não acessa `/notifications`)

---

### 3. Dashboard não carrega assignments para supervisores

**Arquivo:** `frontend/lib/features/dashboard/screens/dashboard_screen.dart`

**Problema:** `dashboardProvider` deriva taxa de adesão por setor cruzando `notifications` com `assignments`. O dashboard chama apenas `loadNotifications()`, mas assignments só são carregados na `AlertUserScreen` (tela do employee). Um supervisor que abre o dashboard direto vê taxa vazia.

**O que fazer:**
- Verificar se `GET /assignments` retorna todos os assignments (todos os usuários) quando chamado por um supervisor
- Se sim: chamar `loadAssignments()` também no `initState` ou refresh do `DashboardScreen`
- Se não: avaliar se o backend precisa de um endpoint `GET /assignments?all=true` para supervisores

---

## 🟡 Dados incorretos / hardcoded

### 4. Setores hardcoded → buscar via `GET /sectors`

**Arquivos:**
- `frontend/lib/features/alerts/modals/create_alert_modal.dart` — `_availableSectors` lista nomes (`TI`, `Operações`...) mas o backend espera UUIDs como `sectorId`
- `frontend/lib/features/alerts/screen/alerts_admin_screen.dart` — `_sectors` lista nomes hardcoded para o filtro

**O que fazer:**
- Criar `SectorService.getSectors(token)` → `GET /sectors` retorna `[{ id, name }]`
- Criar `sectorProvider` (FutureProvider ou StateNotifierProvider) carregando a lista uma vez
- `CreateAlertModal`: substituir chips por dados do provider; enviar `sectorId` (UUID real)
- `AlertAdminScreen`: substituir filter chips pelo nome, mantendo o UUID para comparação com `alert.targetSectorId`

---

### 5. `slaMinutes` hardcoded no `CreateAlertModal`

**Arquivo:** `frontend/lib/features/alerts/modals/create_alert_modal.dart:69`

**Problema:** `slaMinutes: _level == AlertLevel.critical ? 30 : 60` — supervisor não tem controle sobre o SLA.

**O que fazer:** adicionar dropdown de SLA no formulário com opções predefinidas: `15 / 30 / 60 / 120 / 240 min`. Valor padrão sugerido por nível (critical=30, demais=60). Passar o valor selecionado no `createNotification`.

---

### 6. `UserModel.sector` guarda e exibe UUID bruto

**Arquivo:** `frontend/lib/features/login/services/auth_service.dart`

**Problema:** `sector: data['sectorId']` armazena o UUID do setor. Qualquer tela que exiba `user.sector` mostra um UUID ilegível.

**O que fazer:**
- Após autenticação, buscar `GET /sectors` e resolver `sectorId → sectorName`
- Ou verificar se o backend pode retornar `sectorName` diretamente em `GET /users/by-email/{email}`
- Dependência natural do item 4 (SectorService já criado)

---

### 7. Aba "Histórico" no `AlertAdminScreen` sempre vazia

**Arquivo:** `frontend/lib/features/alerts/screen/alerts_admin_screen.dart:87`

**Problema:** `_buildListContent(const [], false, isHistory: true)` — hardcoded como lista vazia.

**O que fazer:**
- Definir o que "histórico" significa com os dados disponíveis. Sugestão: notificações com `createdAt` anterior a X dias, ou assignments com status `OVERDUE / ACKNOWLEDGED`
- Ou **remover a aba** temporariamente até que exista endpoint dedicado (`GET /notifications?status=archived` ou similar)

---

## 🟠 Melhorias de UX

### 8. Tela de detalhes da notificação (`alert_details_screen.dart`) — estática e não integrada

**Arquivo:** `frontend/lib/features/alerts/screen/alert_details_screen.dart`

**Problema:** a tela é um widget estático antigo, com dados hardcoded (não usa `AlertModel`/`AssignmentModel`). Não está conectada ao fluxo real.

**O que fazer:**
- Reescrever `AlertDetailsScreen` recebendo um `AssignmentModel` (ou `AlertModel`) como parâmetro
- Navegar para ela ao tocar em um `_AssignmentCard` ou `MonitoringAlertCard`
- Exibir: título, mensagem, nível, prazo, status, botão de confirmação se aplicável

---

### 9. Duplicata de `UserModel`

**Arquivos:**
- `frontend/lib/core/model/user_model.dart` ← modelo ativo (usado pelo auth)
- `frontend/lib/features/home/model/user_model.dart` ← duplicata (provavelmente obsoleta)

**O que fazer:** verificar se `features/home/model/user_model.dart` é usado em algum import; se não, deletar e ajustar imports que porventura apontem para ele.

---

## 🔵 Sem backend ainda — aguarda implementação

| Item | Situação |
|---|---|
| **Feed de posts** | `PostService` é 100% mock. Sem endpoint no backend. Criar `POST /posts`, `GET /posts`, `POST /posts/{id}/like` |
| **Notices (Avisos)** | `notice_service.dart` e `notice_screen.dart` estão vazios. Feature não iniciada |
| **`fcmToken`** | Backend retorna o campo; `UserModel` não o armazena. Push notifications não implementadas |
| **`go_router`** | Incluso mas inativo. Sem deep linking nem rotas nomeadas |

---

## Ordem de execução sugerida

```
── Fase 1: Dados corretos ────────────────────────────────────────
1. Confirmar PATCH /assignments com backend        [pré-req para 2 e 3]
2. Exibir título real no AssignmentCard            [depende de 1]
3. Carregar assignments no DashboardScreen         [depende de 1]

── Fase 2: Remover hardcoded ────────────────────────────────────
4. SectorService + sectorProvider (GET /sectors)   [pré-req para 5 e 6]
5. Setores reais no CreateAlertModal               [depende de 4]
6. slaMinutes como campo do formulário             [independente]
7. UserModel.sector → nome legível                 [depende de 4]

── Fase 3: UX e limpeza ─────────────────────────────────────────
8. Aba Histórico: definir ou remover               [independente]
9. AlertDetailsScreen integrada                    [independente]
10. Remover UserModel duplicado                    [independente]

── Fase 4: Novas features ───────────────────────────────────────
11. Feed de posts com API real                     [depende de backend]
12. Notices (Avisos) — feature do zero             [depende de backend]
```
