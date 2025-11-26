# Gerenciador de Tarefas - Flutter App

Aplicativo Flutter com backend Node.js e SQLite para gerenciamento de tarefas.

## Estrutura do Projeto

- `flutter_application_1/` - Aplicativo Flutter
- `back/` - Backend Node.js com Express e SQLite

## Configuração

### Backend

1. Entre na pasta `back/`:
```bash
cd back
```

2. Instale as dependências:
```bash
npm install
```

3. Inicie o servidor:
```bash
npm start
```

O servidor estará rodando em `http://localhost:3000`

### Flutter App

1. Entre na pasta `flutter_application_1/`:
```bash
cd flutter_application_1
```

2. Instale as dependências:
```bash
flutter pub get
```

3. Configure o endereço do backend no arquivo `lib/services/api.service.dart`:
   - Para **Android Emulator**: use `http://10.0.2.2:3000/api` (já configurado)
   - Para **iOS Simulator**: use `http://localhost:3000/api`
   - Para **dispositivo físico**: use o IP da sua máquina, ex: `http://192.168.1.100:3000/api`

4. Execute o app:
```bash
flutter run
```

## Funcionalidades

- ✅ Login e registro de usuários
- ✅ Autenticação com hash de senha (bcrypt)
- ✅ Gerenciamento de tarefas (CRUD completo)
- ✅ Perfil de usuário com avatar colorido
- ✅ Persistência de dados em SQLite
- ✅ Filtros de tarefas (Todos, Em Andamento, Concluídas)

## Banco de Dados

O banco SQLite é criado automaticamente na pasta `back/` como `database.sqlite` quando o servidor é iniciado pela primeira vez.

### Tabelas

- **users**: Armazena informações dos usuários
- **tasks**: Armazena tarefas vinculadas aos usuários

## API Endpoints

### Autenticação
- `POST /api/register` - Registrar novo usuário
- `POST /api/login` - Fazer login
- `PUT /api/users/:id` - Atualizar perfil

### Tarefas
- `GET /api/users/:userId/tasks` - Listar tarefas do usuário
- `POST /api/users/:userId/tasks` - Criar nova tarefa
- `PUT /api/tasks/:id` - Atualizar tarefa
- `DELETE /api/tasks/:id` - Deletar tarefa

