import 'package:devhub_gpt/shared/providers/secure_storage_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final _githubCtrl = TextEditingController();
  final _aiCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _githubCtrl.dispose();
    _aiCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final storage = ref.read(secureStorageProvider);
    _githubCtrl.text = (await storage.read(key: 'github_token')) ?? '';
    _aiCtrl.text = (await storage.read(key: 'ai_key')) ?? '';
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    setState(() => _loading = true);
    final storage = ref.read(secureStorageProvider);
    await storage.write(key: 'github_token', value: _githubCtrl.text.trim());
    await storage.write(key: 'ai_key', value: _aiCtrl.text.trim());
    if (!mounted) return;
    setState(() => _loading = false);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Saved')));
  }

  @override
  void initState() {
    super.initState();
    // ignore: discarded_futures
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Keys',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _githubCtrl,
                  decoration: const InputDecoration(labelText: 'GitHub Token'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _aiCtrl,
                  decoration: const InputDecoration(labelText: 'AI Key'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _save,
                  child: const Text('Save Changes'),
                ),
              ],
            ),
    );
  }
}
