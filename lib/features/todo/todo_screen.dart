import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers.dart';

// Écran principal de l'app : formulaire + liste des tâches.
class TodoScreen extends ConsumerStatefulWidget {
  const TodoScreen({super.key});

  @override
  ConsumerState<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends ConsumerState<TodoScreen> {
  // Contrôleur du champ texte pour récupérer et vider la saisie.
  final TextEditingController _textController = TextEditingController();

  // Ajoute un document dans Firestore avec un titre et un indicateur "done".
  Future<void> _addTodo() async {
    final text = _textController.text.trim(); // Nettoie la saisie.
    if (text.isEmpty) return; // Sort si rien n'a été écrit.

    final todosCollection = ref.read(
      todosCollectionProvider,
    ); // Récupère la collection.

    await todosCollection.add({
      'title': text,
      'done': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    _textController.clear(); // Vide le champ après l'enregistrement.
  }

  // Bascule la valeur "done" du document reçu.
  Future<void> _toggleTodo(DocumentSnapshot<Map<String, dynamic>> doc) async {
    final current = doc.data()?['done'] as bool? ?? false;
    await doc.reference.update({'done': !current});
  }

  // Supprime le document reçu.
  Future<void> _deleteTodo(DocumentSnapshot<Map<String, dynamic>> doc) async {
    await doc.reference.delete();
  }

  @override
  void dispose() {
    _textController
        .dispose(); // Libère le contrôleur quand l'écran est détruit.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Récupère l'état du stream (loading / data / error).
    final todosAsync = ref.watch(todosStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Firebase TODOs')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            const Text(
              'Ajouter une tâche',
              style: TextStyle(fontSize: 18, fontWeight: .bold),
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
              style: TextStyle(fontSize: 18, fontWeight: .bold),
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
                  final docs = snapshot.docs; // Liste des documents Firestore.
                  if (docs.isEmpty) {
                    return const Center(
                      child: Text('Aucune tâche. Ajoutez-en une ci-dessus.'),
                    );
                  }

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data();
                      final title = data['title'] as String? ?? '';
                      final done = data['done'] as bool? ?? false;

                      return Card(
                        child: ListTile(
                          title: Text(
                            title,
                            style: TextStyle(
                              decoration: done ? .lineThrough : .none,
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
