# Backend — Fórum (Feed) e Perfil

Instruções para implementar os módulos `posts`, `comments` e `followers` no backend NestJS, seguindo os padrões já estabelecidos no projeto (Clean Architecture, Repository Pattern, DTO + class-validator, Prisma + MySQL).

---

## 1. Banco de Dados — Schema Prisma

Adicionar ao `schema.prisma`:

```prisma
model Post {
  id         String    @id @default(uuid())
  authorId   String
  author     User      @relation(fields: [authorId], references: [id])
  title      String    @db.VarChar(200)
  content    String    @db.Text
  likesCount Int       @default(0)
  createdAt  DateTime  @default(now())
  updatedAt  DateTime  @updatedAt

  comments   Comment[]
  likes      PostLike[]

  @@map("posts")
}

model Comment {
  id        String   @id @default(uuid())
  postId    String
  post      Post     @relation(fields: [postId], references: [id], onDelete: Cascade)
  authorId  String
  author    User     @relation(fields: [authorId], references: [id])
  content   String   @db.Text
  createdAt DateTime @default(now())

  @@map("comments")
}

model PostLike {
  id       String @id @default(uuid())
  postId   String
  post     Post   @relation(fields: [postId], references: [id], onDelete: Cascade)
  userId   String
  user     User   @relation(fields: [userId], references: [id])

  @@unique([postId, userId])
  @@map("post_likes")
}

model Follower {
  id          String @id @default(uuid())
  followerId  String
  follower    User   @relation("following", fields: [followerId], references: [id])
  followingId String
  following   User   @relation("followers", fields: [followingId], references: [id])

  @@unique([followerId, followingId])
  @@map("followers")
}
```

Adicionar relações no model `User` existente:

```prisma
// dentro de model User
posts       Post[]
comments    Comment[]
postLikes   PostLike[]
followers   Follower[] @relation("followers")
following   Follower[] @relation("following")
```

---

## 2. Módulo Posts

### Estrutura

```
modules/posts/
├── application/
│   └── posts.service.ts
├── domain/
│   └── post.entity.ts
├── infrastructure/
│   ├── posts.repository.ts
│   └── post.mapper.ts
└── presentation/
    └── posts.controller.ts
```

### Endpoints

| Método | Rota              | Descrição                          | Auth |
|--------|-------------------|------------------------------------|------|
| GET    | /posts            | Lista todos os posts (paginado)    | Sim  |
| POST   | /posts            | Cria um novo post                  | Sim  |
| DELETE | /posts/:id        | Deleta post (somente autor)        | Sim  |
| POST   | /posts/:id/like   | Toggle curtida                     | Sim  |

### DTO — Criar Post

```typescript
// create-post.dto.ts
import { IsString, MinLength, MaxLength } from 'class-validator';

export class CreatePostDto {
  @IsString()
  @MinLength(3)
  @MaxLength(200)
  title: string;

  @IsString()
  @MinLength(10)
  content: string;
}
```

### Resposta — GET /posts

```json
[
  {
    "id": "uuid",
    "title": "Título do tópico",
    "content": "Conteúdo do post...",
    "likesCount": 14,
    "commentsCount": 3,
    "isLiked": false,
    "isOwn": false,
    "author": {
      "id": "uuid",
      "name": "Roberta Lima",
      "role": "SUPERVISOR"
    },
    "createdAt": "2026-04-20T10:00:00Z"
  }
]
```

> `isLiked` e `isOwn` são computados pelo service com base no `userId` do JWT.

### Paginação (query params)

```
GET /posts?page=1&limit=20
```

---

## 3. Módulo Comments

### Estrutura

```
modules/comments/
├── application/
│   └── comments.service.ts
├── domain/
│   └── comment.entity.ts
├── infrastructure/
│   └── comments.repository.ts
└── presentation/
    └── comments.controller.ts
```

### Endpoints

| Método | Rota                         | Descrição                       | Auth |
|--------|------------------------------|---------------------------------|------|
| GET    | /posts/:postId/comments      | Lista comentários de um post    | Sim  |
| POST   | /posts/:postId/comments      | Cria comentário                 | Sim  |
| DELETE | /posts/:postId/comments/:id  | Deleta comentário (autor)       | Sim  |

### DTO — Criar Comentário

```typescript
export class CreateCommentDto {
  @IsString()
  @MinLength(1)
  @MaxLength(1000)
  content: string;
}
```

### Resposta — GET /posts/:postId/comments

```json
[
  {
    "id": "uuid",
    "content": "Recebido, obrigado!",
    "author": {
      "id": "uuid",
      "name": "Carlos Mendes"
    },
    "createdAt": "2026-04-20T11:00:00Z"
  }
]
```

---

## 4. Módulo Followers (Perfil)

### Endpoints

| Método | Rota                        | Descrição                              | Auth |
|--------|-----------------------------|----------------------------------------|------|
| GET    | /users/:id/followers        | Lista seguidores do usuário            | Sim  |
| GET    | /users/:id/following        | Lista quem o usuário segue             | Sim  |
| GET    | /users/:id/followers/count  | Contagem de seguidores e seguindo      | Sim  |
| POST   | /users/:id/follow           | Seguir usuário                         | Sim  |
| DELETE | /users/:id/follow           | Deixar de seguir                       | Sim  |

### Resposta — GET /users/:id/followers/count

```json
{
  "followersCount": 12,
  "followingCount": 5,
  "postsCount": 3
}
```

> Implementar como método adicional em `UsersService` — não precisa de módulo separado.

---

## 5. Integração com o Frontend

### Endpoints que o Flutter já espera

O `PostService` (mock) usa estes métodos — basta substituir pela chamada real via `ApiClient`:

| Método Flutter         | Endpoint backend        |
|------------------------|-------------------------|
| `fetchPosts()`         | `GET /posts`            |
| `createPost(...)`      | `POST /posts`           |
| `deletePost(id)`       | `DELETE /posts/:id`     |
| `toggleLike(id)`       | `POST /posts/:id/like`  |

### ProfileScreen espera

```
GET /users/:id/followers/count
→ { followersCount, followingCount, postsCount }
```

Atualmente mock em `ProfileState`. Substituir quando o endpoint estiver disponível.

---

## 6. Padrões a seguir

- Usar `@UseGuards(JwtAuthGuard)` em todos os endpoints
- Extrair `userId` de `req.user.userId` (padrão já estabelecido no projeto)
- Usar `class-validator` + `ValidationPipe` global (já configurado em `main.ts`)
- Retornar `404` se post/comentário não existir
- Retornar `403` se usuário tentar deletar recurso de outro autor
- `onDelete: Cascade` já configurado no schema — deletar post remove comments e likes automaticamente

---

## 7. Ordem de implementação sugerida

1. Rodar `npx prisma migrate dev --name add_forum_and_followers`
2. Implementar `PostsModule` (CRUD + like)
3. Implementar `CommentsModule` (CRUD)
4. Adicionar endpoints de followers em `UsersModule`
5. Substituir `PostService` mock no Flutter pelas chamadas reais
6. Substituir mock de `followersCount`/`followingCount` em `ProfileState`
