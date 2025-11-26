# Backend - Gerenciador de Tarefas

Backend Node.js com Express e SQLite para o aplicativo de gerenciamento de tarefas.

## Instalação

```bash
npm install
```

## Executar

```bash
npm start
```

Para desenvolvimento com auto-reload:

```bash
npm run dev
```

O servidor estará rodando em `http://localhost:3000`

## Endpoints

### Autenticação

- `POST /api/register` - Registrar novo usuário
- `POST /api/login` - Fazer login
- `PUT /api/users/:id` - Atualizar perfil do usuário

### Tarefas

- `GET /api/users/:userId/tasks` - Listar tarefas do usuário
- `POST /api/users/:userId/tasks` - Criar nova tarefa
- `PUT /api/tasks/:id` - Atualizar tarefa
- `DELETE /api/tasks/:id` - Deletar tarefa

## Banco de Dados

O banco de dados SQLite é criado automaticamente como `database.sqlite` na pasta `back/`.

