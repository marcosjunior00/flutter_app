import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import '../models/user.dart';

class ApiService {
  // Para emulador Android use: http://10.0.2.2:3000/api
  // Para iOS Simulator use: http://localhost:3000/api
  // Para dispositivo físico, use o IP da sua máquina: http://192.168.x.x:3000/api
  // static const String baseUrl = 'http://10.0.2.2:3000/api'; // Android emulator
  static const String baseUrl = 'http://localhost:3000/api'; // iOS Simulator

  // Armazenar usuário logado
  static int? _currentUserId;
  static User? _currentUser;

  // Obter usuário atual
  static User? get currentUser => _currentUser;
  static int? get currentUserId => _currentUserId;

  // Login
  static Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          _currentUser = User(
            id: data['user']['id'],
            name: data['user']['name'],
            email: data['user']['email'],
            password: '', // Não armazenar senha
            phone: data['user']['phone'],
            avatarColor: data['user']['avatarColor'],
          );
          _currentUserId = data['user']['id'];

          // Salvar ID do usuário nas preferências
          // Ignorar erro de SharedPreferences para evitar MissingPluginException em plataformas sem suporte
          try {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setInt('userId', _currentUserId!);
          } catch (e) {
            print('Erro ao salvar userId nas preferências: $e');
          }

          print(data);

          return true;
        }
      }
      return false;
    } catch (e) {
      print('Erro no login: $e');
      return false;
    }
  }

  // Registrar
  static Future<bool> register(String name, String email, String password,
      {String? phone, int? avatarColor}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'phone': phone,
          'avatarColor': avatarColor ?? 0xFF9333EA,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          _currentUser = User(
            id: data['user']['id'],
            name: data['user']['name'],
            email: data['user']['email'],
            password: '',
            phone: data['user']['phone'],
            avatarColor: data['user']['avatarColor'],
          );
          _currentUserId = data['user']['id'];

          // Salvar ID do usuário nas preferências
          try {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setInt('userId', _currentUserId!);
          } catch (e) {
            print('Erro ao salvar userId nas preferências: $e');
          }

          return true;
        }
      }
      return false;
    } catch (e) {
      print('Erro no registro: $e');
      return false;
    }
  }

  // Atualizar perfil
  static Future<bool> updateProfile(int userId, String name, String email,
      String? phone, int avatarColor) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/users/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'phone': phone,
          'avatarColor': avatarColor,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // print com todos os dados como texto, ex: Id: 1, Name: John Doe, Email: john.doe@example.com, Phone: 1234567890, AvatarColor: 1234567890
        print('Id: ${data['user']['id']}, Name: ${data['user']['name']}, Email: ${data['user']['email']}, Phone: ${data['user']['phone']}, AvatarColor: ${data['user']['avatar_color']}');
        if (data['success'] == true) {
          _currentUser = User(
            id: data['user']['id'],
            name: data['user']['name'],
            email: data['user']['email'],
            password: '',
            phone: data['user']['phone'] ?? null,
            avatarColor: data['user']['avatar_color'],
          );
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Erro ao atualizar perfil: $e');
      return false;
    }
  }

  // Obter ID do usuário logado (das preferências)
  static Future<int?> getStoredUserId() async {
    if (_currentUserId != null) return _currentUserId;

    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }

  // Listar tarefas
  static Future<List<Task>> getTasks() async {
    try {
      final userId = _currentUserId ?? await getStoredUserId();
      if (userId == null) return [];

      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId/tasks'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Task.fromMap(json)).toList();
      }
      return [];
    } catch (e) {
      print('Erro ao buscar tarefas: $e');
      return [];
    }
  }

  // Criar tarefa
  static Future<bool> createTask(
      String title, String project, String date) async {
    try {
      final userId = _currentUserId ?? await getStoredUserId();
      if (userId == null) return false;

      final response = await http.post(
        Uri.parse('$baseUrl/users/$userId/tasks'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': title,
          'project': project,
          'date': date,
        }),
      );

      return response.statusCode == 201;
    } catch (e) {
      print('Erro ao criar tarefa: $e');
      return false;
    }
  }

  // Atualizar tarefa
  static Future<bool> updateTask(Task task) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/tasks/${task.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': task.title,
          'project': task.project,
          'date': task.date,
          'completed': task.completed,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Erro ao atualizar tarefa: $e');
      return false;
    }
  }

  // Deletar tarefa
  static Future<bool> deleteTask(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/tasks/$id'),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Erro ao deletar tarefa: $e');
      return false;
    }
  }

  // Logout
  static Future<void> logout() async {
    _currentUser = null;
    _currentUserId = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
  }
}
