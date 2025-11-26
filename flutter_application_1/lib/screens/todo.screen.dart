import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/api.service.dart';
import 'editProfile.screen.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({Key? key}) : super(key: key);

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  int selectedTab = 0;

  String userName = "Beatriz";
  String userEmail = "beatriz@email.com";
  String userPhone = "(11) 99999-9999";
  Color avatarColor = const Color(0xFF9333EA);

  List<Task> tasks = [];
  bool loading = true;

  String _formatarDataAtual() {
    final now = DateTime.now();
    // Lista de nomes dos dias da semana (começando por segunda-feira = 1)
    const diasSemana = [
      'Segunda-feira',
      'Terça-feira',
      'Quarta-feira',
      'Quinta-feira',
      'Sexta-feira',
      'Sábado',
      'Domingo'
    ];
    const mesesAno = [
      '',
      'janeiro',
      'fevereiro',
      'março',
      'abril',
      'maio',
      'junho',
      'julho',
      'agosto',
      'setembro',
      'outubro',
      'novembro',
      'dezembro'
    ];

    final nomeDia = diasSemana[now.weekday - 1];
    final nomeMes = mesesAno[now.month];
    final dia = now.day.toString().padLeft(2, '0');
    final ano = now.year;

    // Exemplo: "Quarta-feira, 29 de março de 2024"
    return "$nomeDia, $dia de $nomeMes de $ano";
  }

  @override
  void initState() {
    super.initState();
    loadUserData();
    loadTasks();
  }

  Future<void> loadUserData() async {
    final user = ApiService.currentUser;
    if (user != null) {
      setState(() {
        userName = user.name;
        userEmail = user.email;
        userPhone = user.phone ?? '';
        avatarColor = user.avatarColorAsColor;
      });
    }
  }

  Future<void> loadTasks() async {
    setState(() => loading = true);
    tasks = await ApiService.getTasks();
    setState(() => loading = false);
  }

  List<Task> get filteredTasks {
    if (selectedTab == 0) return tasks;
    if (selectedTab == 1) return tasks.where((t) => !t.completed).toList();
    return tasks.where((t) => t.completed).toList();
  }

  int get completedTasksCount {
    return tasks.where((t) => t.completed).length;
  }

  String get userInitial {
    return userName.isNotEmpty ? userName[0].toUpperCase() : '?';
  }

  Future<void> updateProfile(String name, String email, String phone, Color color) async {
    final userId = ApiService.currentUserId ?? await ApiService.getStoredUserId();
    if (userId == null) return;

    bool success = await ApiService.updateProfile(
      userId,
      name,
      email,
      phone,
      color.value,
    );

    if (success) {
      setState(() {
        userName = name;
        userEmail = email;
        userPhone = phone;
        avatarColor = color;
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Erro ao atualizar perfil"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          Expanded(
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  _buildProfileLine(context),
                  _buildTabs(),
                  Expanded(child: _buildTaskList())
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF9333EA),
            Color(0xFF7C3AED),
            Color(0xFF6B46C1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _formatarDataAtual(),
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Boa noite, $userName!",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Row(
                children: [
                  _buildHeaderChip(
                      "$completedTasksCount concluídas", Icons.check),
                  const SizedBox(width: 8),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildHeaderChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 12))
        ],
      ),
    );
  }

  Widget _buildProfileLine(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: avatarColor,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
              child: Text(
                userInitial,
                style: const TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            "Minhas tarefas",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF323130),
            ),
          ),
          const Icon(Icons.lock, size: 16, color: Color(0xFF605E5C)),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditProfileScreen(
                    currentName: userName,
                    currentEmail: userEmail,
                    currentPhone: userPhone,
                    currentColor: avatarColor,
                  ),
                ),
              );

              if (result != null) {
                updateProfile(
                  result["name"],
                  result["email"],
                  result["phone"],
                  result["color"],
                );
              }
            },
          )
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _buildTab("Todos", 0),
          const SizedBox(width: 32),
          _buildTab("Em andamento", 1),
          const SizedBox(width: 32),
          _buildTab("Concluídas", 2),
        ],
      ),
    );
  }

  Widget _buildTab(String text, int index) {
    final bool selected = selectedTab == index;
    return InkWell(
      onTap: () {
        setState(() {
          selectedTab = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected ? const Color(0xFF9333EA) : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            color: selected ? const Color(0xFF9333EA) : const Color(0xFF605E5C),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskList() {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        ...filteredTasks.map((task) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildTaskItem(task),
          );
        }).toList(),
        _buildAddTaskButton()
      ],
    );
  }

  Widget _buildTaskItem(Task task) {
    return InkWell(
      onTap: () => _showEditTaskDialog(task),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE9D5FF)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF9333EA).withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            InkWell(
              onTap: () async {
                task.completed = !task.completed;
                await ApiService.updateTask(task);
                loadTasks();
              },
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      task.completed ? const Color(0xFF9333EA) : Colors.white,
                  border: Border.all(
                    color: const Color(0xFFA78BFA),
                    width: 2,
                  ),
                ),
                child: task.completed
                    ? const Icon(Icons.check, color: Colors.white, size: 12)
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                task.title,
                style: TextStyle(
                  decoration:
                      task.completed ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF3E8FF), Color(0xFFE9D5FF)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                task.project,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF7C3AED),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              task.date,
              style: const TextStyle(color: Color(0xFF9333EA)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAddTaskButton() {
    return InkWell(
      onTap: _showAddTaskDialog,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFF3E8FF), Color(0xFFE9D5FF)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, color: Color(0xFF9333EA)),
            SizedBox(width: 12),
            Text(
              "Criar nova tarefa",
              style: TextStyle(
                color: Color(0xFF7C3AED),
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showAddTaskDialog() {
    final title = TextEditingController();
    final project = TextEditingController(text: "Plano ...");
    final date = TextEditingController(text: "Hoje");

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Nova tarefa"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: title,
                  decoration: const InputDecoration(labelText: "Título")),
              const SizedBox(height: 12),
              TextField(
                  controller: project,
                  decoration: const InputDecoration(labelText: "Projeto")),
              const SizedBox(height: 12),
              TextField(
                  controller: date,
                  decoration: const InputDecoration(labelText: "Data")),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text("Adicionar"),
              onPressed: () async {
                await ApiService.createTask(
                  title.text,
                  project.text,
                  date.text,
                );
                Navigator.pop(context);
                loadTasks();
              },
            )
          ],
        );
      },
    );
  }

  void _showEditTaskDialog(Task task) {
    final title = TextEditingController(text: task.title);
    final project = TextEditingController(text: task.project);
    final date = TextEditingController(text: task.date);

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Editar tarefa"),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  if (task.id != null) {
                    await ApiService.deleteTask(task.id!);
                    Navigator.pop(context);
                    loadTasks();
                  }
                },
              )
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: title,
                  decoration: const InputDecoration(labelText: "Título")),
              const SizedBox(height: 12),
              TextField(
                  controller: project,
                  decoration: const InputDecoration(labelText: "Projeto")),
              const SizedBox(height: 12),
              TextField(
                  controller: date,
                  decoration: const InputDecoration(labelText: "Data")),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text("Salvar"),
              onPressed: () async {
                task.title = title.text;
                task.project = project.text;
                task.date = date.text;

                await ApiService.updateTask(task);

                Navigator.pop(context);
                loadTasks();
              },
            )
          ],
        );
      },
    );
  }
}
