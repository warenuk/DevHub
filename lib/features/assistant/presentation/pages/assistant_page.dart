import 'dart:async';

import 'package:devhub_gpt/features/assistant/presentation/providers/assistant_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AssistantPage extends ConsumerStatefulWidget {
  const AssistantPage({super.key});

  @override
  ConsumerState<AssistantPage> createState() => _AssistantPageState();
}

class _AssistantPageState extends ConsumerState<AssistantPage> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _streamBuffer = [];
  StreamSubscription<String>? _sub;

  @override
  void dispose() {
    _sub?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    _streamBuffer.clear();
    await _sub?.cancel();
    final ctrl = ref.read(assistantControllerProvider.notifier);
    _sub = ctrl.send(text).listen((chunk) {
      setState(() => _streamBuffer.add(chunk));
    });
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(assistantControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('AI Assistant')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                for (final (role, content) in messages)
                  Align(
                    alignment: role == 'user'
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: role == 'user'
                            ? Theme.of(context).colorScheme.primaryContainer
                            : Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(content),
                    ),
                  ),
                if (_streamBuffer.isNotEmpty)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(_streamBuffer.join('\n')),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration:
                        const InputDecoration(hintText: 'Type message…'),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: _send, child: const Text('Send')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
