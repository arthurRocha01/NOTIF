# TODO — Roadmap de Desenvolvimento

> Atualizado em 14/04/2026.  
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
| `AlertAdminScreen` | Aba "Notificações" + aba "Minhas notificações" para supervisor |
| `AssignmentsBody` | Widget compartilhado de lista de assignments (employee + supervisor) |
| `dashboard_provider` | Taxa de adesão por setor derivada de `notifications` + `assignments` reais |
| `DashboardScreen` | `loadNotifications()` + `loadAssignments()` chamados no `initState` |
| `errorMessage` no `AlertState` | `AlertNotifier` propaga erros; telas exibem SnackBar vermelho |
| Interceptação de 401 | `ApiClient.onUnauthorized` chama `authProvider.logout()` automaticamente |
| `authInitProvider` | Splash durante restore de sessão no startup |
| Base URL unificada | `ApiClient.baseUrl = 'http://localhost:3000'` — único ponto de configuração |
| `SectorModel` + `SectorService` + `sectorProvider` | `GET /sectors` com estado, loading e errorMessage |
| `CreateAlertModal` setores reais | Chips carregados do backend; envia `sector.id` (UUID) |
| `AlertAdminScreen` filtro real | Filtro usa `sector.id` vs `alert.targetSectorId` |
| `UserModel.sector` → nome legível | `AuthNotifier` resolve `sectorId → sectorName` via `SectorService` |
| `UserModel` duplicado removido | `features/home/model/user_model.dart` deletado |
| `notificationTitle` + `notificationMessage` | Campos opcionais em `AssignmentModel`, parseados do JSON |
| `AlertDetailsScreen` integrada | Recebe `AssignmentModel`; exibe título, mensagem, nível, prazo, status e botão |
| `AccountScreen` setor e cargo | Setor e Cargo exibidos na seção Identificação via `authProvider` |
| `CustomNavbar` | Barra de navegação moderna com pill effect, animações e badge — substitui `HomeBottomNav` |
| Double AppBar corrigido — Dashboard | `AppBar` interno removido do `DashboardScreen`; botão refresh movido para o body |
| Double header corrigido — AlertAdmin | `NestedScrollView` + `SliverAppBar` substituídos por `Column` + `TabBar` fixo |
| Trocar senha via `PATCH /users/:id` | Validação local (mín. 6 chars, senhas coincidem) + chamada real ao backend; loading e erro exibidos |
| Badge da navbar → `alertProvider` | `notificationCount` usa assignments pendentes reais do `alertProvider` |
| Base URL → produção | `ApiClient.baseUrl` aponta para `https://notifta.vercel.app` |

---

## 🔴 Crítico — Quebra a integração (depende de backend)

### 1. [FRONTEND] Atualizar `AlertService` para novos endpoints de interaction

**Contexto:** o backend não usa mais `PATCH /assignments/{id}`. Os novos endpoints são:

| Ação | Endpoint |
|---|---|
| Visualizar | `POST /assignments/:id/view` |
| Confirmar ciência | `POST /assignments/:id/acknowledge` |
| Sincronizar entrega | `POST /assignments/sync/:userId` |

**Consequências enquanto não atualizado:**
- `markAsViewed` e `acknowledge` continuam falhando silenciosamente (chamam endpoint errado)
- `isBlocked` nunca volta a `false` após confirmação
- Taxa de adesão no dashboard sempre 0%

**O que fazer:**
- `AlertService.markAsViewed(id)` → `POST /assignments/$id/view`
- `AlertService.acknowledge(id)` → `POST /assignments/$id/acknowledge`
- Adicionar `AlertService.syncDeliveries(userId)` → `POST /assignments/sync/$userId`
- Chamar `syncDeliveries` no login e restore de sessão (`AuthNotifier`)

---

### 2. [BACKEND] Retornar `notificationTitle` e `notificationMessage` no `GET /assignments`

**Problema:** `AssignmentModel` já parseia esses campos, mas o backend não os retorna embutidos. Cards exibem fallback `'Notificação'` e `AlertDetailsScreen` não exibe mensagem.

**O que fazer:** incluir `notificationTitle` e `notificationMessage` na query do `GET /assignments`.

---

## 🟡 Importante — Sprint nova (features solicitadas)

### 3. [FRONTEND + BACKEND] Sistema de notificações push de alertas (FCM)

**Contexto:** `fcmToken` já existe na tabela `users` e é retornado no `GET /users/by-email/:email`, mas nenhuma das duas pontas implementou envio ou recebimento de push. Quando um supervisor cria um alerta, os funcionários não recebem notificação no dispositivo.

**O que está faltando:**

*Backend:*
- Integrar `firebase-admin` ao NestJS
- Disparar push via FCM ao criar `NotificationAssignment`
- Disparar lembrete ao mudar para `OVERDUE`
- `PATCH /users/fcm-token` — atualizar token do dispositivo (muda com reinstalação)

*Frontend:*
- Adicionar `firebase_core` + `firebase_messaging` ao `pubspec.yaml`
- Solicitar permissão de notificação no primeiro login
- Registrar `fcmToken` e enviá-lo ao backend após login e restore de sessão
- `UserModel` passar a armazenar `fcmToken`
- Handler foreground (`onMessage`) → atualizar `alertProvider`
- Handler background/terminated (`onBackgroundMessage`) → deeplink para `AlertUserScreen`

**Fluxo completo esperado:**
```
Supervisor cria alerta
  → Backend cria NotificationAssignment(status: PENDING)
  → Backend dispara FCM para fcmToken do(s) funcionário(s)
  → Dispositivo recebe push → badge atualiza
  → Funcionário toca na notificação → abre AlertUserScreen
```

**Dependências:** requer `go_router` ativo para o deeplink funcionar.

---

### 4. [FRONTEND + BACKEND] Supervisor vê TODOS os assignments em "Minhas Notificações"

**Contexto atual:** `GET /assignments` retorna apenas os assignments do usuário autenticado. O supervisor vê somente as notificações atribuídas a ele — não as dos outros funcionários.

**Comportamento desejado:** supervisor visualiza assignments de todos os setores na aba "Minhas notificações".

**O que fazer (backend):** `GET /assignments` retornar todos quando `role == ADMIN`, ou criar `GET /assignments/all`.

**O que fazer (frontend):**
- `AlertNotifier.loadAssignments()` — chamar endpoint correto por role
- `AssignmentsBody` — tornar subtítulo dinâmico: `isSupervisor ? 'Visão geral de todos os setores.' : 'Acompanhe os avisos do seu setor.'`
- Considerar filtro por setor na aba "Minhas notificações" para o supervisor

---

### 5. [FRONTEND + BACKEND] Espaço de perfil social minimalista

**Comportamento desejado:**
- Contador de seguidores/seguindo e posts logo abaixo do avatar
- Quem curtiu: avatares empilhados (stack de até 3) + "e mais N" no `PostCard`
- Aba "Minhas publicações" na `ProfileScreen` — grid 3 colunas, somente leitura

**O que fazer (backend):** `GET /users/{id}/stats`, `GET /posts/{id}/likes`, `GET /users/{id}/posts`

**O que fazer (frontend):** `_StatsRow` na `ProfileScreen`; `_LikesAvatars` no `PostCard`; grid de posts do usuário

---

## 🟡 Médio — Funciona, mas incompleto

### 6. Feed de posts — 100% mock

`PostService` usa 4 posts hardcoded. `toggleLike()`, `deletePost()`, comentários e compartilhar não têm implementação real.

**Backend:** `GET /posts`, `POST /posts`, `POST /posts/{id}/like`, `DELETE /posts/{id}`, `POST /posts/{id}/comments`  
**Frontend:** reescrever `PostService`; adicionar `fromJson`/`toJson` ao `PostModel`

---

### 7. Notices (Avisos) — feature não iniciada

`notice_service.dart` vazio, `notice_model.dart` esqueleto, sem tela. Depende de definição de endpoints com o backend.

---

### 8. Botão "Seguir" sem comportamento

`onFollowToggle` em `feed_content.dart` apenas executa `debugPrint`. Depende de endpoint de follow/unfollow no backend.

---

## 🔵 Débito técnico

### 9. `HomeAppBar` no módulo errado

`features/profile/widgets/home_app_bar.dart` — AppBar do `HomeScreen` está no módulo de profile. Mover para `shared/widgets/` ou `features/home/widgets/`.

---

### 10. Widgets duplicados entre `ProfileScreen` e `AccountScreen`

`_SectionHeader`, `_InfoCard`, `_InfoRow` definidos em ambos os arquivos. Extrair para `features/profile/widgets/profile_widgets.dart`.

---

### 11. Mapeamento de índices da navbar duplicado

`_onNavTap` em `home_screen.dart` e `_currentNavIndex` em `home_bottom_nav.dart` duplicam a mesma lógica. Centralizar em um único lugar.

---

### 12. Cores hardcoded fora de `AppColors`

`Color(0xFF0F172A)`, `Color(0xFF3B82F6)`, `Color(0xFF1E293B)` aparecem inline em múltiplos arquivos. Mapear em `AppColors` e substituir.

---

### 13. `_markPendingAsViewed` duplicado

Mesma implementação em `AlertAdminScreen` e `AlertUserScreen`. Mover para `AlertNotifier.markAllPendingAsViewed()`.

---

### 14. `FeedSkeleton` disponível mas não usado

`feed_content.dart` exibe `CircularProgressIndicator` no loading. Substituir pelo `FeedSkeleton` existente.

---

### 15. `AttentionCard` com botão "Em breve" ativo

Botão "Notificar" no `DashboardScreen` dispara SnackBar "em breve" mas está habilitado. Desabilitar com `onPressed: null`.

---

## 🔵 Estrutural — Preparação para API futura

| Item | Arquivo | Situação |
|---|---|---|
| `fcmToken` + FCM push | `core/model/user_model.dart` + `notification_service.dart` | Sistema completo pendente — ver item #3 |
| Upload de avatar | `profile/data/profile_repository.dart` | Salva apenas em `SharedPreferences`; sem endpoint de upload |
| `go_router` | `main.dart` | Incluso mas inativo — necessário para deeplink do FCM |
| `dashboard_service.dart` | `dashboard/services/` | Existe mas nunca é chamado; cálculo feito localmente |

---

## Heurísticas de Nielsen — Violações ativas

| # | Heurística | Violação | Item |
|---|---|---|---|
| H4 | Consistência e padrões | Cores hardcoded; widgets duplicados; AppBar no módulo errado | #9–#12 |
| H5 | Prevenção de erros | "Comentar" não salva; "Seguir" sem efeito | #6, #8 |
| H6 | Reconhecimento | Subtítulo "avisos do seu setor" incorreto para supervisor | #4 |
| H8 | Design minimalista | Botão "Notificar" ativo com SnackBar "em breve" | #15 |

---

## Ordem de execução sugerida

```
── Fase 1: Correções críticas ✅ CONCLUÍDA ───────────────────────
✅ Corrigir falsa confirmação de senha
✅ Remover double AppBar do Dashboard
✅ Remover double header do AlertAdminScreen
✅ Corrigir badge da navbar para usar alertProvider

── Fase 2: Frontend urgente ──────────────────────────────────────
1. [FRONTEND] Atualizar AlertService: POST view/acknowledge/sync (#1)
2. Testar ciclo PENDING → VIEWED → ACKNOWLEDGED end-to-end
3. [BACKEND] Retornar notificationTitle + notificationMessage no GET /assignments (#2)

── Fase 3: Sprint nova — features ────────────────────────────────
4. [BACKEND] Integrar Firebase Admin + FCM ao criar assignment (#3)
5. [BACKEND] PATCH /users/fcm-token (#3)
6. [FRONTEND] firebase_messaging; registrar token; handlers (#3)
7. [BACKEND] GET /assignments retornar todos para ADMIN (#4)
8. [FRONTEND] Supervisor ver todos assignments; subtítulo dinâmico (#4)
9. [BACKEND] GET /users/{id}/stats, GET /users/{id}/posts, GET /posts/{id}/likes (#5)
10. [FRONTEND] ProfileScreen com stats sociais minimalistas (#5)

── Fase 4: Backend médio ─────────────────────────────────────────
11. [BACKEND] PATCH /users/{id}/password + POST /auth/password-reset
12. [FRONTEND] Integrar modais de senha com a API
13. [BACKEND] Endpoints de posts (GET, POST, like, delete, comments) (#6)
14. [FRONTEND] Reescrever PostService + PostModel com API real (#6)

── Fase 5: Débito técnico ────────────────────────────────────────
15. Mover HomeAppBar para shared/ (#9)
16. Extrair widgets duplicados de Profile (#10)
17. Centralizar mapeamento de índices da navbar (#11)
18. Substituir cores hardcoded por AppColors (#12)
19. Consolidar _markPendingAsViewed no notifier (#13)
20. Usar FeedSkeleton no loading (#14)
21. Desabilitar botão "Notificar" no AttentionCard (#15)

── Fase 6: Novas features ────────────────────────────────────────
22. Notices (Avisos) — feature do zero (#7)
23. Follow/Unfollow real (#8)
24. Upload de avatar
```
