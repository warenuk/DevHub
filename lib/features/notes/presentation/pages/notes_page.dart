import 'package:devhub_gpt/features/notes/domain/entities/note.dart';
import 'package:devhub_gpt/features/notes/presentation/providers/notes_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotesPage extends ConsumerWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncNotes = ref.watch(notesControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Notes')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEditDialog(context, ref),
        child: const Icon(Icons.add),
      ),
      body: asyncNotes.when(
        loading: () => const _NotesList(notes: <Note>[]),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (notes) => _NotesList(notes: notes),
      ),
    );
  }

  Future<void> _showEditDialog(
    BuildContext context,
    WidgetRef ref, {
    Note? note,
  }) async {
    final titleCtrl = TextEditingController(text: note?.title ?? '');
    final contentCtrl = TextEditingController(text: note?.content ?? '');
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(note == null ? 'New note' : 'Edit note'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: contentCtrl,
                decoration: const InputDecoration(labelText: 'Content'),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final title = titleCtrl.text.trim();
                final content = contentCtrl.text.trim();
                if (title.isEmpty) return;
                if (note == null) {
                  await ref
                      .read(notesControllerProvider.notifier)
                      .add(title, content);
                } else {
                  await ref
                      .read(notesControllerProvider.notifier)
                      .update(note.copyWith(title: title, content: content));
                }
                if (context.mounted) Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}

class _NotesList extends ConsumerWidget {
  const _NotesList({required this.notes});
  final List<Note> notes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (notes.isEmpty) {
      return const Center(child: Text('No notes yet'));
    }
    return ListView.separated(
      itemCount: notes.length,
      separatorBuilder: (context, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final n = notes[index];
        return ListTile(
          title: Text(n.title),
          subtitle: Text(
            n.content,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () => _openEdit(context, ref, n),
          trailing: IconButton(
            tooltip: 'Delete',
            icon: const Icon(Icons.delete_outline),
            onPressed: () =>
                ref.read(notesControllerProvider.notifier).remove(n.id),
          ),
        );
      },
    );
  }

  void _openEdit(BuildContext context, WidgetRef ref, Note n) {
    showDialog<void>(
      context: context,
      builder: (context) {
        final titleCtrl = TextEditingController(text: n.title);
        final contentCtrl = TextEditingController(text: n.content);
        return AlertDialog(
          title: const Text('Edit note'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: contentCtrl,
                decoration: const InputDecoration(labelText: 'Content'),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final title = titleCtrl.text.trim();
                final content = contentCtrl.text.trim();
                if (title.isEmpty) return;
                await ref
                    .read(notesControllerProvider.notifier)
                    .update(n.copyWith(title: title, content: content));
                if (context.mounted) Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
