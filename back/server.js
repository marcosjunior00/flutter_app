const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const sqlite3 = require('sqlite3').verbose();
const bcrypt = require('bcryptjs');
const path = require('path');

const app = express();
const PORT = 3000;

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Inicializar banco de dados
const dbPath = path.join(__dirname, 'database.sqlite');
const db = new sqlite3.Database(dbPath, (err) => {
  if (err) {
    console.error('Erro ao conectar ao banco de dados:', err.message);
  } else {
    console.log('Conectado ao banco de dados SQLite');
    initDatabase();
  }
});

// Criar tabelas
function initDatabase() {
  // Tabela de usuários
  db.run(`CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL,
    phone TEXT,
    avatar_color INTEGER NOT NULL DEFAULT 0xFF9333EA,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
  )`);

  // Tabela de tarefas
  db.run(`CREATE TABLE IF NOT EXISTS tasks (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    title TEXT NOT NULL,
    project TEXT NOT NULL,
    date TEXT NOT NULL,
    completed INTEGER NOT NULL DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
  )`);

  console.log('Tabelas criadas/verificadas');
}

// ========== ROTAS DE AUTENTICAÇÃO ==========

// Registrar usuário
app.post('/api/register', async (req, res) => {
  const { name, email, password, phone, avatarColor } = req.body;

  if (!name || !email || !password) {
    return res.status(400).json({ error: 'Nome, email e senha são obrigatórios' });
  }

  try {
    // Verificar se email já existe
    db.get('SELECT id FROM users WHERE email = ?', [email], async (err, row) => {
      if (err) {
        return res.status(500).json({ error: 'Erro ao verificar usuário' });
      }

      if (row) {
        return res.status(400).json({ error: 'Email já cadastrado' });
      }

      // Hash da senha
      const hashedPassword = await bcrypt.hash(password, 10);
      const avatarColorValue = avatarColor || 0xFF9333EA;

      // Inserir usuário
      db.run(
        'INSERT INTO users (name, email, password, phone, avatar_color) VALUES (?, ?, ?, ?, ?)',
        [name, email, hashedPassword, phone || null, avatarColorValue],
        function(err) {
          if (err) {
            return res.status(500).json({ error: 'Erro ao criar usuário' });
          }

          // Retornar usuário criado (sem senha)
          db.get('SELECT id, name, email, phone, avatar_color FROM users WHERE id = ?', [this.lastID], (err, user) => {
            if (err) {
              return res.status(500).json({ error: 'Erro ao buscar usuário criado' });
            }
            res.status(201).json({ 
              success: true, 
              user: {
                id: user.id,
                name: user.name,
                email: user.email,
                phone: user.phone,
                avatarColor: user.avatar_color
              }
            });
          });
        }
      );
    });
  } catch (error) {
    res.status(500).json({ error: 'Erro interno do servidor' });
  }
});

// Login
app.post('/api/login', (req, res) => {
  const { email, password } = req.body;
  console.log(email, password); 

  if (!email || !password) {
    return res.status(400).json({ error: 'Email e senha são obrigatórios' });
  }

  db.get('SELECT * FROM users WHERE email = ?', [email], async (err, user) => {
    if (err) {
      return res.status(500).json({ error: 'Erro ao buscar usuário' });
    }

    if (!user) {
      return res.status(401).json({ error: 'Credenciais inválidas' });
    }

    // Verificar senha
    const isValidPassword = await bcrypt.compare(password, user.password);
    if (!isValidPassword) {
      return res.status(401).json({ error: 'Credenciais inválidas' });
    }

    // Retornar usuário (sem senha)
    res.json({
      success: true,
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        avatarColor: user.avatar_color
      }
    });
  });
});

// Atualizar perfil
app.put('/api/users/:id', (req, res) => {
  const userId = parseInt(req.params.id);
  const { name, email, phone, avatarColor } = req.body;

  if (!name || !email) {
    return res.status(400).json({ error: 'Nome e email são obrigatórios' });
  }

  db.run(
    'UPDATE users SET name = ?, email = ?, phone = ?, avatar_color = ? WHERE id = ?',
    [name, email, phone || null, avatarColor || 0xFF9333EA, userId],
    function(err) {
      if (err) {
        return res.status(500).json({ error: 'Erro ao atualizar perfil' });
      }

      if (this.changes === 0) {
        return res.status(404).json({ error: 'Usuário não encontrado' });
      }

      db.get('SELECT id, name, email, phone, avatar_color FROM users WHERE id = ?', [userId], (err, user) => {
        if (err) {
          return res.status(500).json({ error: 'Erro ao buscar usuário atualizado' });
        }
        res.json({ success: true, user });
      });
    }
  );
});

// ========== ROTAS DE TAREFAS ==========

// Listar tarefas do usuário
app.get('/api/users/:userId/tasks', (req, res) => {
  const userId = parseInt(req.params.userId);

  db.all('SELECT * FROM tasks WHERE user_id = ? ORDER BY created_at DESC', [userId], (err, rows) => {
    if (err) {
      return res.status(500).json({ error: 'Erro ao buscar tarefas' });
    }

    const tasks = rows.map(row => ({
      id: row.id,
      userId: row.user_id,
      title: row.title,
      project: row.project,
      date: row.date,
      completed: row.completed === 1
    }));

    res.json(tasks);
  });
});

// Criar tarefa
app.post('/api/users/:userId/tasks', (req, res) => {
  const userId = parseInt(req.params.userId);
  const { title, project, date } = req.body;

  if (!title) {
    return res.status(400).json({ error: 'Título é obrigatório' });
  }

  db.run(
    'INSERT INTO tasks (user_id, title, project, date, completed) VALUES (?, ?, ?, ?, 0)',
    [userId, title, project || 'Plano ...', date || 'Hoje'],
    function(err) {
      if (err) {
        return res.status(500).json({ error: 'Erro ao criar tarefa' });
      }

      db.get('SELECT * FROM tasks WHERE id = ?', [this.lastID], (err, row) => {
        if (err) {
          return res.status(500).json({ error: 'Erro ao buscar tarefa criada' });
        }

        res.status(201).json({
          id: row.id,
          userId: row.user_id,
          title: row.title,
          project: row.project,
          date: row.date,
          completed: row.completed === 1
        });
      });
    }
  );
});

// Atualizar tarefa
app.put('/api/tasks/:id', (req, res) => {
  const taskId = parseInt(req.params.id);
  const { title, project, date, completed } = req.body;

  db.run(
    'UPDATE tasks SET title = ?, project = ?, date = ?, completed = ? WHERE id = ?',
    [title, project, date, completed ? 1 : 0, taskId],
    function(err) {
      if (err) {
        return res.status(500).json({ error: 'Erro ao atualizar tarefa' });
      }

      if (this.changes === 0) {
        return res.status(404).json({ error: 'Tarefa não encontrada' });
      }

      db.get('SELECT * FROM tasks WHERE id = ?', [taskId], (err, row) => {
        if (err) {
          return res.status(500).json({ error: 'Erro ao buscar tarefa atualizada' });
        }

        res.json({
          id: row.id,
          userId: row.user_id,
          title: row.title,
          project: row.project,
          date: row.date,
          completed: row.completed === 1
        });
      });
    }
  );
});

// Deletar tarefa
app.delete('/api/tasks/:id', (req, res) => {
  const taskId = parseInt(req.params.id);

  db.run('DELETE FROM tasks WHERE id = ?', [taskId], function(err) {
    if (err) {
      return res.status(500).json({ error: 'Erro ao deletar tarefa' });
    }

    if (this.changes === 0) {
      return res.status(404).json({ error: 'Tarefa não encontrada' });
    }

    res.json({ success: true });
  });
});

// Iniciar servidor
app.listen(PORT, () => {
  console.log(`Servidor rodando em http://localhost:${PORT}`);
});

// Fechar banco ao encerrar
process.on('SIGINT', () => {
  db.close((err) => {
    if (err) {
      console.error(err.message);
    }
    console.log('Conexão com banco de dados fechada.');
    process.exit(0);
  });
});

