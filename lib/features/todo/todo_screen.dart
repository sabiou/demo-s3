import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:s3_firebase_demo/features/todo/providers.dart';

class TodoScreen extends ConsumerStatefulWidget {
  const TodoScreen({super.key});

  @override
  ConsumerState<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends ConsumerState<TodoScreen> {
  // Contrôleur du champ texte pour récupérer et vider la saisie.
  final TextEditingController _textController = TextEditingController();

  // Ajoute un document (todo) dans la collection todos (Create)
  Future<void> _addTodo() async {
    final title = _textController.text.trim();
    if (title.isEmpty) return;

    final todosCollection = ref.read(todosCollectionProvider);

    await todosCollection.add({
      'title': title,
      'done': false,
      "createdAt": FieldValue.serverTimestamp(),
    });

    _textController.clear(); // vide le champ de saisie
  }

  // Marquer la tache comme terminé (Update)
  Future<void> _toggleTodo(DocumentSnapshot<Map<String, dynamic>> doc) async {
    final currentTodo = doc.data()?['done'] as bool? ?? false;
    await doc.reference.update({'done': currentTodo});
  }

  // supprimer une todo (Delete)
  Future<void> _deleteTodo(DocumentSnapshot<Map<String, dynamic>> doc) async {
    await doc.reference.delete();
  }

  @override
  void dispose() {
    _textController.dispose(); // Libère le contrôleur
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // recupere l'etat actuel du stream (loading (chargement), data (données chargées), error (erreur de chargement))
    final todosAsync = ref.watch(todosStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Firebase TODOs')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ajouter une tâche',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Ex: Acheter du pain',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addTodo,
                  child: const Text('Enregistrer'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Vos tâches',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: todosAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ), // Chargement.
                error: (error, stack) =>
                    Center(child: Text('Erreur: $error')), // Erreur.
                data: (snapshot) {
                  final docs = snapshot
                      .docs; // liste de documents dans la collection "todos"
                  if (docs.isEmpty) {
                    return const Center(
                      child: Text('Aucune tâche. Ajoutez-en une ci-dessus.'),
                    );
                  }

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final todo = doc.data();
                      final title = todo['title'] as String? ?? '';
                      final done = todo['done'] as bool? ?? false;

                      return Card(
                        child: ListTile(
                          title: Text(
                            title,
                            style: TextStyle(
                              decoration: done
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                          leading: Checkbox(
                            value: done,
                            onChanged: (_) => _toggleTodo(doc),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _deleteTodo(doc),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
