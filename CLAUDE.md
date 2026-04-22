# NOTIF — Contrato de Sessão

## 1. Entendimento de contexto

Antes de qualquer tarefa, leia nessa ordem:

1. `.backend-architecture.md` — arquitetura, fluxos e contratos da API
2. `.frontend-architecture.md` — stack, estado, navegação e integrações do app
3. Código fonte relevante para a tarefa (nunca assuma — leia)

Edições são feitas **somente no frontend** (`frontend/`).  
O backend serve apenas como referência de contrato de API.

---

## 2. TDD obrigatório

Todo desenvolvimento segue o ciclo Red → Green → Refactor:

1. **Escreva o teste primeiro** — o teste deve falhar antes da implementação
2. **Implemente o mínimo** para o teste passar
3. **Refatore** sem quebrar os testes

Testes ficam em `frontend/test/features/<feature>/`.  
Para rodar: `flutter test test/features/<feature>/`

---

## 3. Resumo antes de executar

Antes de iniciar qualquer implementação, apresente ao usuário:

- **O que será feito** — descrição curta da tarefa
- **Arquivos que serão criados ou modificados**
- **Abordagem** — decisões técnicas relevantes

Aguarde confirmação antes de prosseguir.
