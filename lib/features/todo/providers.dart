import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Fournit la collection "todos" pour éviter de la recréer partout.
final todosCollectionProvider =
    Provider<CollectionReference<Map<String, dynamic>>>((ref) {
  return FirebaseFirestore.instance.collection('todos');
});

// Écoute en continu les todos triés par date de création (les plus récents en haut).
final todosStreamProvider =
    StreamProvider<QuerySnapshot<Map<String, dynamic>>>((ref) {
  final collection = ref.watch(todosCollectionProvider);
  return collection.orderBy('createdAt', descending: true).snapshots();
});
