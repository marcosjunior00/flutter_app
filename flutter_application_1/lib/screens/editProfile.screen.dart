import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  final String currentName;
  final String currentEmail;
  final String currentPhone;
  final Color currentColor;

  const EditProfileScreen({
    super.key,
    required this.currentName,
    required this.currentEmail,
    required this.currentPhone,
    required this.currentColor,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController name;
  late TextEditingController email;
  late TextEditingController phone;
  late Color selectedColor;

  final List<Color> colors = [
    const Color(0xFF9333EA),
    const Color(0xFF7C3AED),
    const Color(0xFF6B46C1),
    const Color(0xFFA855F7),
    const Color(0xFF8B5CF6),
    const Color(0xFFC084FC),
  ];

  @override
  void initState() {
    super.initState();
    name = TextEditingController(text: widget.currentName);
    email = TextEditingController(text: widget.currentEmail);
    phone = TextEditingController(text: widget.currentPhone);
    selectedColor = widget.currentColor;
  }

  String get initial => name.text.isNotEmpty ? name.text[0].toUpperCase() : "?";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF9333EA),
        title: const Text(
          "Editar perfil",
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: save,
            child: const Text(
              "Salvar",
              style: TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildAvatarSelector(),
            const SizedBox(height: 40),
            _buildForm()
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarSelector() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: selectedColor,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Center(
            child: Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text("Escolha a cor do avatar"),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          children: colors
              .map(
                (c) => InkWell(
                  onTap: () => setState(() => selectedColor = c),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selectedColor == c
                            ? Colors.black
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: selectedColor == c
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Informações pessoais",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        const Text("Nome"),
        TextField(controller: name),
        const SizedBox(height: 20),
        const Text("Email"),
        TextField(controller: email),
        const SizedBox(height: 20),
        const Text("Telefone"),
        TextField(controller: phone),
      ],
    );
  }

  void save() {
    Navigator.pop(context, {
      "name": name.text,
      "email": email.text,
      "phone": phone.text,
      "color": selectedColor,
    });
  }
}
