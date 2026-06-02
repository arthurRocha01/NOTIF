# Manual do Usuário — NOTIF

## Visão Geral

O **NOTIF** é uma plataforma web de notificações corporativas com rastreamento de conformidade. Supervisores criam e distribuem avisos para colaboradores, que devem visualizar e confirmar o recebimento dentro de um prazo (SLA). O sistema registra todo o ciclo de vida de cada notificação e gera métricas de conformidade por setor.

---

## Perfis de Acesso

| Perfil | O que pode fazer |
|---|---|
| **Colaborador** | Receber e confirmar notificações |
| **Supervisor** | Criar notificações, ver conformidade do setor, acessar dashboard |
| **Administrador** | Tudo acima + gerenciar usuários e setores |

---

## 1. Login

1. Acesse o endereço da plataforma no navegador.
2. Informe seu **e-mail** e **senha** nos campos indicados.
3. Clique em **Entrar**.

Caso suas credenciais estejam corretas, você será redirecionado automaticamente para a tela correspondente ao seu perfil.

> Se a sessão ainda estiver válida de um acesso anterior, o sistema restaura o login automaticamente ao abrir a plataforma.

---

## 2. Tela Principal (Home)

Após o login, a tela principal é dividida em abas na barra inferior:

| Aba | Disponível para |
|---|---|
| **Feed** | Todos |
| **Dashboard** | Supervisores e Administradores |
| **Alertas** | Todos |

---

## 3. Alertas (Colaboradores)

### 3.1 Ver notificações recebidas

A aba **Alertas** exibe todas as notificações enviadas a você, com indicação visual de urgência:

| Cor | Nível |
|---|---|
| Verde | Baixo |
| Âmbar | Médio |
| Laranja | Alto |
| Vermelho | Crítico |

Cada card mostra o título, nível de urgência e o status atual da notificação.

### 3.2 Status das notificações

| Status | Significado |
|---|---|
| **Pendente** | Recebida, ainda não visualizada |
| **Visualizada** | Você abriu a notificação |
| **Confirmada** | Você confirmou o recebimento |
| **Vencida** | O prazo (SLA) expirou sem confirmação |
| **Negada** | Você negou o recebimento |

### 3.3 Confirmar uma notificação

1. Toque no card da notificação para abrir os detalhes.
2. Leia o conteúdo.
3. Clique em **Confirmar** para registrar o seu recebimento.

### 3.4 Notificações críticas (bloqueio de tela)

Quando uma notificação **Crítica** é recebida:

- Uma tela de bloqueio aparece automaticamente sobre todo o conteúdo do aplicativo.
- Um alerta sonoro é disparado.
- **O aplicativo fica bloqueado até que você confirme a notificação.**
- Toque em **"Estou ciente"** para desbloquear e voltar ao uso normal.

> Notificações críticas não podem ser ignoradas ou descartadas sem confirmação.

### 3.5 Notificações em segundo plano

Se o aplicativo estiver minimizado ou fechado, você receberá uma notificação push no dispositivo. Ao abri-la, será direcionado diretamente para os detalhes da notificação.

---

## 4. Criação de Notificações (Supervisores)

### 4.1 Criar uma nova notificação

1. Acesse a aba **Alertas**.
2. Clique no botão **"+"** (nova notificação).
3. Preencha os campos:

| Campo | Descrição |
|---|---|
| **Título** | Título curto e descritivo |
| **Mensagem** | Texto completo do aviso |
| **Nível** | Baixo / Médio / Alto / Crítico |
| **SLA (minutos)** | Prazo para o colaborador confirmar |
| **Destinatários** | Todos os setores ou um setor específico |

4. Clique em **Enviar**.

O sistema distribui automaticamente a notificação para todos os colaboradores dos setores selecionados e registra o prazo de vencimento com base no SLA informado.

### 4.2 SLA e vencimento automático

O SLA define o prazo (em minutos) para que o colaborador confirme a notificação. Após o vencimento:

- O status da notificação muda automaticamente para **Vencida**.
- O dashboard reflete o impacto no índice de conformidade do setor.

---

## 5. Dashboard (Supervisores e Administradores)

O dashboard apresenta métricas de conformidade em tempo real.

### 5.1 Indicadores (KPIs)

| Indicador | Descrição |
|---|---|
| **Total enviado** | Número de notificações distribuídas |
| **Confirmadas** | Quantidade de confirmações recebidas |
| **Pendentes** | Ainda aguardando confirmação |
| **Críticas** | Notificações de nível crítico no período |

### 5.2 Filtros disponíveis

- **Período**: Últimos 7 dias / Últimos 30 dias / Todo o histórico
- **Setor**: Filtrar por um setor específico (Administradores veem todos os setores)

### 5.3 Gráficos

- **Taxa de conformidade por setor** (gráfico de barras): compara o índice de confirmação entre setores.
- **Detalhamento do setor** (gráfico de rosca): distribuição de status (confirmado, pendente, vencido) dentro de um setor selecionado.

---

## 6. Painel Administrativo (Administradores)

Acesse pelo menu lateral ou pela tela inicial após login com perfil de Administrador.

O painel possui três abas:

### 6.1 Dashboard

Mesmas métricas do supervisor, mas com visibilidade de **todos os setores**.

### 6.2 Usuários

Exibe a lista completa de usuários cadastrados.

**Criar usuário:**
1. Clique no botão **"+"**.
2. Preencha: nome, e-mail, senha, perfil (Colaborador / Supervisor / Administrador) e setor.
3. Clique em **Salvar**.

**Editar usuário:**
1. Clique no ícone de edição ao lado do usuário.
2. Altere os campos desejados.
3. Clique em **Salvar**.

**Excluir usuário:**
1. Clique no ícone de exclusão.
2. Confirme a ação.

### 6.3 Setores

Exibe a lista de setores (departamentos) cadastrados.

**Criar setor:**
1. Clique no botão **"+"**.
2. Informe o nome do setor.
3. Clique em **Salvar**.

**Editar / Excluir:** mesma lógica da gestão de usuários.

---

## 7. Perfil

Acessível pelo menu lateral (gaveta de navegação).

- Visualize e edite seu nome de exibição.
- Consulte seu setor e perfil de acesso.

---

## 8. Sair da plataforma

1. Abra o menu lateral (ícone de hambúrguer no canto superior esquerdo).
2. Clique em **Sair**.

A sessão é encerrada e você retorna para a tela de login.

---

## 9. Dúvidas frequentes

**Não consigo fechar a tela de alerta crítico.**
Isso é esperado. Notificações críticas bloqueiam o aplicativo até que sejam confirmadas. Leia o conteúdo e toque em **"Estou ciente"**.

**Minha notificação está como "Vencida".**
O prazo definido pelo supervisor (SLA) expirou antes que você confirmasse. Você ainda pode abrir os detalhes, mas o status não volta para pendente.

**Não estou recebendo notificações push.**
Verifique se as permissões de notificação do navegador estão habilitadas para este site. As permissões são solicitadas automaticamente no primeiro acesso.

**Não consigo fazer login.**
Confirme com o administrador que sua conta está criada corretamente e que você está usando o e-mail e senha cadastrados.

**Quero mudar minha senha.**
Entre em contato com o administrador do sistema para redefinição de senha.
