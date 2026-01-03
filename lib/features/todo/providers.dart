import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//Fournit la collection "todos"
final todosCollectionProvider =
    Provider<CollectionReference<Map<String, dynamic>>>((ref) {
      return FirebaseFirestore.instance.collection("todos");
    });

// ecoute et fournit en temps reel les todos
final todosStreamProvider = StreamProvider<QuerySnapshot<Map<String, dynamic>>>(
  (ref) {
    final collection = ref.watch(todosCollectionProvider);
    return collection.orderBy('createdAt', descending: true).snapshots();
  },
);
