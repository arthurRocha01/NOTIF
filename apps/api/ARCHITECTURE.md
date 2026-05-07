# Arquitetura do Sistema

## 1. Visão Arquitetural

O NOTIF Corporativo é um sistema monolítico modular, organizado em arquitetura em camadas, responsável por gerenciar notificações corporativas com:

- rastreabilidade individual
- controle de prazo (SLA)
- medição de tempo de resposta
- bloqueio sistêmico para eventos críticos

O sistema não se limita ao envio de notificações. Ele modela obrigações individuais auditáveis associadas a cada usuário.

O elemento central da arquitetura é a entidade **NotificationAssignment**, responsável por representar o vínculo comportamental entre um usuário e uma notificação. Essa entidade permite registrar:

- entrega da notificação
- visualização
- confirmação de ciência
- atraso no cumprimento

## 2. Padrão Arquitetural

### 2.1 Estilo Arquitetural

O sistema adota o modelo **monólito modular com arquitetura em camadas**, organizado por domínio.

Fluxo estrutural das requisições:

```
Controller
   ↓
Application Service
   ↓
Domain
   ↓
Repository
   ↓
Database
```

Essa separação garante isolamento entre:
- entrada HTTP
- orquestração de casos de uso
- regras de domínio
- persistência

### 2.2 Responsabilidades das Camadas

#### Controller

Responsável pela interface HTTP.

Funções:
- receber requisições
- validar entrada via DTO
- encaminhar requisição para Application Service

Controllers **não contêm regras de negócio**.

#### Application Service

Responsável por orquestrar casos de uso.

Funções:
- coordenar múltiplas entidades de domínio
- gerenciar persistência
- disparar integrações externas
- controlar fluxo da aplicação

Exemplo de integrações:
- envio de push notifications via Firebase Cloud Messaging

Application Services **não contêm lógica conceitual profunda**, apenas coordenação.

#### Domain

Camada central do sistema.

Contém:
- entidades de domínio
- estados de ciclo de vida
- regras temporais
- transições de estado
- cálculo de atraso
- regras de bloqueio por criticidade

Toda regra conceitual relevante deve estar nessa camada.

#### Repository

Responsável pela persistência. Implementação baseada em Prisma ORM.

Funções:
- persistir entidades
- recuperar entidades
- mapear dados entre banco e domínio

## 3. Modelo de Domínio

### 3.1 Sector

Representa uma unidade organizacional.

Regras:
- um usuário pertence a exatamente um setor
- uma notificação setorial pertence a exatamente um setor
- não existe hierarquia entre setores
- usuários não possuem múltiplos vínculos

Relações:
```
Sector 1:N Users
Sector 1:N Notifications
```

### 3.2 User

Representa colaboradores do sistema.

Campos principais:
- `id`
- `name`
- `email`
- `role`
- `sectorId`

Papéis possíveis:
- `EMPLOYEE`
- `SUPERVISOR`
- `ADMIN`

Regras:
- cada usuário pertence a um único setor
- apenas ADMIN pode criar notificações globais

### 3.3 Notification

Representa o evento coletivo de comunicação.

Campos principais:
- `id`
- `title`
- `message`
- `level`
- `slaMinutes`
- `requiresAcknowledgment`
- `sectorId` (nullable)

Semântica:
- `sectorId != null` → notificação setorial
- `sectorId = null` → notificação global

**Importante:** A entidade Notification **não** representa obrigação individual. Ela representa apenas o evento coletivo de comunicação.

### 3.4 NotificationAssignment (Entidade Central)

Representa a obrigação individual de um usuário diante de uma notificação.

Campos principais:
- `id`
- `userId`
- `notificationId`
- `notificationLevel`
- `slaMinutes` (tempo mínimo para visualização)
- `status`
- `createdAt`
- `deliveredAt`
- `dueAt`
- `viewedAt`
- `acknowledgedAt`

Estados possíveis:
- `PENDING`
- `VIEWED`
- `ACKNOWLEDGED`
- `OVERDUE`

**Regra fundamental:** Cada Notification gera um NotificationAssignment para cada usuário alvo.

Essa entidade constitui o núcleo de:
- auditoria
- controle de SLA
- análise comportamental

## 4. Ciclo de Vida da NotificationAssignment

### 4.1 Criação

Fluxo:
1. Supervisor cria Notification
2. Backend valida permissões
3. SLA é definido
4. Usuários alvo são identificados
5. Assignments são criados
6. Push notification é disparado

Definição de usuários alvo:
- notificação setorial → usuários do setor
- notificação global → todos os usuários

**Importante:** Assignments são criados independentemente do sucesso do envio de push.

### 4.2 Entrega

Entrega é confirmada quando o aplicativo sincroniza com o backend.

**Definição:** `deliveredAt` = momento em que o backend registra que o app consultou a notificação.

Neste momento:
```
dueAt = deliveredAt + slaMinutes
```

O SLA começa na entrega, não na criação. O push enviado via Firebase Cloud Messaging é apenas um alerta visual. A confirmação de entrega é determinada exclusivamente pelo backend.

### 4.3 Visualização

Quando o usuário abre a notificação:
- `viewedAt` é registrado
- `status` → `VIEWED`

A transição ocorre apenas se o status ainda não for:
- `OVERDUE`
- `ACKNOWLEDGED`

### 4.4 Confirmação

Quando o usuário confirma ciência:
- `acknowledgedAt` é registrado
- `status` → `ACKNOWLEDGED`

Tempo de resposta:
```
acknowledgedAt - deliveredAt
```

Essa métrica permite análise de comportamento organizacional.

### 4.5 Atraso

Uma notificação é considerada atrasada quando:
```
now > dueAt
AND
status != ACKNOWLEDGED
```

Neste caso:
```
status → OVERDUE
```

Esse estado pode ser:
- calculado dinamicamente
- atualizado por job periódico

Antes da entrega, não existe atraso possível.

## 5. Bloqueio Sistêmico

O sistema aplica bloqueio quando existem notificações críticas não confirmadas.

**Condição:** Existe `NotificationAssignment` tal que:
- `notificationLevel = CRITICAL`
- `status != ACKNOWLEDGED`

Se essa condição for verdadeira:
- Requisições comuns são bloqueadas.
- Somente os seguintes endpoints permanecem acessíveis:
  - listagem de pendências
  - confirmação de ciência

Esse mecanismo garante a obrigatoriedade de comunicações críticas.

## 6. Integração com Firebase

### 6.1 Autenticação

A autenticação é realizada por meio do Firebase Authentication.

Responsabilidades do Firebase:
- autenticação do usuário
- emissão de token

Responsabilidades do backend:
- validação do token
- autorização
- execução das regras de negócio

**Importante:** Autorização não depende do Firebase, apenas da lógica do backend.

### 6.2 Push Notifications (FCM)

O envio de notificações push é realizado por meio do Firebase Cloud Messaging.

Responsabilidade do FCM:
- envio de alerta visual para o dispositivo

O FCM **não** é fonte de verdade do sistema. Ele não:
- confirma entrega
- registra visualização
- determina confirmação de leitura

O push é apenas um efeito colateral da criação da notificação. Toda rastreabilidade é mantida exclusivamente pelo backend.

## 7. Persistência e Escalabilidade

O volume de NotificationAssignments cresce proporcionalmente ao número de usuários e notificações.

```
TotalAssignments ≈ Usuários × Notificações
```

O banco relacional suporta esse volume com índices adequados:
- índice em `userId`
- índice em `notificationId`
- índice em `status`
- índice em `dueAt`

Para o escopo do projeto, a arquitetura é plenamente suficiente.

## 8. Decisões Arquiteturais Fundamentais

Princípios adotados:
- a verdade do sistema reside no backend
- push notifications são apenas alertas
- obrigações são persistidas
- cada usuário possui instância individual da obrigação
- simplicidade estrutural foi priorizada

O sistema foi projetado como monólito modular organizado, evitando complexidade prematura.

## 9. Limitações Assumidas

Para manter coerência e viabilidade no escopo:
- usuários pertencem a apenas um setor
- não existe hierarquia organizacional
- não há histórico de movimentação entre setores
- notificações globais são representadas por `sectorId = null`
- não há microserviços
- não há mensageria distribuída

Essas decisões reduzem complexidade arquitetural.

## 10. Resultado Arquitetural

O NOTIF Corporativo não é um simples sistema de envio de mensagens. Ele é um sistema de:

- registro formal de obrigações
- medição de comportamento organizacional
- auditoria de resposta
- controle de exposição obrigatória

A arquitetura foi projetada para garantir:
- rastreabilidade
- consistência
- simplicidade estrutural
- clareza conceitual
