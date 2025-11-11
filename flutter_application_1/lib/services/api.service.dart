import 'dart:async';
import '../models/task.dart';

class ApiService {
  static final List<Task> _mockTasks = [
    Task(
      id: 1,
      title: "Escrever o brief do projeto",
      project: "Plano ...",
      date: "Hoje – 7 nov",
      completed: false,
    ),
    Task(
      id: 2,
      title: "Agendar reunião inicial",
      project: "Plano ...",
      date: "6 – 10 nov",
      completed: false,
    ),
  ];

  static int _idCounter = 3;

  // Simula login
  static Future<bool> login(String email, String senha) async {
    await Future.delayed(const Duration(seconds: 1));
    return email.isNotEmpty && senha.isNotEmpty;
  }

  // Simula registro
  static Future<bool> register(String name, String email, String senha) async {
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  // Lista tarefas
  static Future<List<Task>> getTasks() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return List.from(_mockTasks);
  }

  // Criar tarefa
  static Future<bool> createTask(
      String title, String project, String date) async {
    await Future.delayed(const Duration(milliseconds: 600));
    _mockTasks.add(
      Task(
        id: _idCounter++,
        title: title,
        project: project,
        date: date,
        completed: false,
      ),
    );
    return true;
  }

  // Editar tarefa
  static Future<bool> updateTask(Task task) async {
    await Future.delayed(const Duration(milliseconds: 600));

    int index = _mockTasks.indexWhere((t) => t.id == task.id);
    if (index >= 0) {
      _mockTasks[index] = task;
      return true;
    }
    return false;
  }

  // Deletar tarefa
  static Future<bool> deleteTask(int id) async {
    await Future.delayed(const Duration(milliseconds: 600));
    _mockTasks.removeWhere((t) => t.id == id);
    return true;
  }
}
