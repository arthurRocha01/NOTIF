# TODO — Próximas Etapas de Integração

> Gerado em 10/04/2026. Baseado na análise de integração frontend ↔ backend.  
> Edições são feitas **somente no frontend** (`frontend/`).

---

## 🔴 Crítico — Quebra a integração

### 1. Reescrever `dashboard_provider.dart`

**Arquivo:** `frontend/lib/features/dashboard/providers/dashboard_provider.dart`

**Problema:** referencia campos que não existem mais após a integração dos alertas.
```dart
alertState.activeAlerts  // ❌ não existe → alertState.notifications
alertState.history       // ❌ não existe → alertState.assignments
alert.sectors            // ❌ não existe → alert.targetSectorId
alert.readRate           // ❌ não existe (removido)
```

**O que fazer:** reescrever o provider para derivar `DashboardData` a partir de
`state.notifications` e `state.assignments` (dados reais). Definir o que o
dashboard deve exibir com base nos dados disponíveis:
- Notificações por nível (`LOW / MEDIUM / HIGH / CRITICAL`)
- Assignments por status (`PENDING / VIEWED / ACKNOWLEDGED / OVERDUE`)
- Taxa de adesão por setor (assignments acknowledged / total por setor)

---

### 2. Confirmar/corrigir PATCH `/assignments/{id}` no backend

**Arquivo de referência:** `.backend-architecture.md`

**Problema:** o backend lista `/assignments` como `GET/POST/DELETE` (sem update), e
cita que o endpoint de update está comentado. O frontend chama
`PATCH /assignments/{id}` para `markAsViewed` e `acknowledge` — essas ações falham
silenciosamente.

**O que fazer:**
- Verificar se o backend precisa descomentar/implementar `PATCH /assignments/{id}`
- Ou ajustar o frontend para usar a rota correta (se houver alternativa)
- Após confirmação, testar `markAsViewed` e `acknowledge` end-to-end

---

## 🟡 Comportamento incorreto

### 3. `AlertAdminScreen` — não carrega notificações ao abrir

**Arquivo:** `frontend/lib/features/alerts/screen/alerts_admin_screen.dart`

**Problema:** `initState` não chama `loadNotifications()`. A lista só carrega via
pull-to-refresh manual.

**O que fazer:** adicionar no `initState`:
```dart
WidgetsBinding.instance.addPostFrameCallback((_) {
  ref.read(alertProvider.notifier).loadNotifications();
});
```

---

### 4. `AlertUserScreen` — transição PENDING → VIEWED nunca acontece

**Arquivo:** `frontend/lib/features/alerts/screen/alerts_user_screen.dart`

**Problema:** ao exibir os assignments, o app não chama `markAsViewed()`. O status
nunca avança de `PENDING` para `VIEWED` no backend.

**O que fazer:** chamar `markAsViewed(assignmentId)` para cada assignment com
status `PENDING` quando ele é renderizado na tela (ou ao abrir os detalhes).

---

### 5. Erros silenciados em `AlertNotifier` — sem feedback ao usuário

**Arquivo:** `frontend/lib/features/alerts/providers/alert_provider.dart`

**Problema:** todos os métodos terminam em `catch (_) {}`. Não há estado de erro.
O usuário vê tela vazia sem saber se houve falha de rede, token expirado ou erro
no servidor.

**O que fazer:**
- Adicionar `String? errorMessage` ao `AlertState`
- Propagar erros relevantes no catch
- Exibir feedback na UI (`SnackBar` ou inline)

---

### 6. Token expira mid-session sem deslogar o usuário

**Problema:** JWT expira em 1h. Após isso, chamadas retornam 401, mas os erros
são silenciados. O usuário fica preso com tela vazia sem ser deslogado.

**O que fazer:** no `ApiClient` ou nos services, interceptar `statusCode == 401`
e chamar `authProvider.notifier.logout()` automaticamente — ou redirecionar para
o login com mensagem de sessão expirada.

---

### 7. Aba "Histórico" no `AlertAdminScreen` sempre vazia

**Arquivo:** `frontend/lib/features/alerts/screen/alerts_admin_screen.dart`

**Problema:** a aba Histórico usa `const []` hardcoded.

**O que fazer:** definir o que "histórico" significa com base nos dados reais
(ex: notificações antigas, assignments encerrados) ou remover a aba até que
exista um endpoint dedicado.

---

## 🟠 Dados incorretos / hardcoded

### 8. Setores hardcoded — buscar via `GET /sectors`

**Arquivos:**
- `frontend/lib/features/alerts/modals/create_alert_modal.dart`
- `frontend/lib/features/alerts/screen/alerts_admin_screen.dart`

**Problema:** setores (`TI`, `Operações`, `RH`...) estão hardcoded. O backend
tem `GET /sectors` com os setores reais do banco.

**O que fazer:**
- Criar `SectorService.getSectors(token)` que chama `GET /sectors`
- Criar `sectorProvider` que carrega a lista
- Substituir os hardcoded pelos dados do provider nos dois arquivos

---

### 9. `slaMinutes` hardcoded em `CreateAlertModal`

**Arquivo:** `frontend/lib/features/alerts/modals/create_alert_modal.dart`

**Problema:** `slaMinutes: _level == AlertLevel.critical ? 30 : 60` — sem campo
no formulário. O supervisor não controla o SLA.

**O que fazer:** adicionar campo numérico no formulário (ou dropdown com opções
predefinidas: 15, 30, 60, 120, 240 min) e passar o valor selecionado.

---

### 10. `UserModel.sector` guarda UUID, exibe UUID

**Arquivo:** `frontend/lib/features/login/services/auth_service.dart`

**Problema:** `sector: data['sectorId']` armazena o ID do setor (UUID). Qualquer
tela que exiba `user.sector` vai mostrar um UUID bruto.

**O que fazer:** após buscar o usuário, fazer lookup em `GET /sectors` para
resolver `sectorId → sectorName`, ou verificar se o backend pode retornar
`sectorName` junto ao `/users/by-email/{email}`.

---

## 🔵 Pendências conhecidas (sem backend ainda)

| Item | Observação |
|---|---|
| **Feed de posts** | `PostService` é 100% mock. Sem endpoint no backend. |
| **`fcmToken`** | Backend retorna o campo; `UserModel` não o armazena. Push notifications não suportadas. |
| **`go_router`** | Incluso mas inativo. Sem deep linking nem rotas nomeadas. |

---

## Ordem de execução sugerida

```
1. Confirmar PATCH /assignments com o backend          (pré-requisito para 4 e 5)
2. Reescrever dashboard_provider.dart                  (bug crítico)
3. loadNotifications() no initState do AdminScreen     (quick win)
4. markAsViewed() no UserScreen                        (depende de 1)
5. Buscar setores via GET /sectors                     (melhora dados)
6. errorMessage no AlertState + interceptar 401        (robustez)
7. slaMinutes como campo do formulário                 (UX)
8. UserModel.sector → nome legível                     (UX)
```
