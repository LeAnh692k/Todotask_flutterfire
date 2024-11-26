import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:todo_task/models/todo_model.dart';

class DatabaseService {
  final CollectionReference todoCollection =
  FirebaseFirestore.instance.collection("todos");

  User? user = FirebaseAuth.instance.currentUser;

  //Add Todo task
  Future<DocumentReference> addTodoTask(String title,
      String descripttion) async {
    return await todoCollection.add({
      'uid': user!.uid,
      'title': title,
      'description': descripttion,
      'completed': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  //Update Todo Task
  Future<void> updateTodo(String id, String title, String decription) async {
    final updateTodoCollection =
    FirebaseFirestore.instance.collection("todos").doc(id);
    return await updateTodoCollection
        .update({'title': title, 'decription': decription});
  }

  //Update Todo Status
  Future<void> updateTodoStatus(String id, bool completed) async {
    return await todoCollection.doc(id).update({'completed': completed});
  }

  //Delete Todo Task
  Future<void> deleteTodoTask(String id) async {
    return await todoCollection.doc(id).delete();
  }

  //Get pending tasks
  Stream<List<ToDo>> get todos {
    return todoCollection.where('uid', isEqualTo: user!.uid).where(
        'completed', isEqualTo: false).snapshots().map(_todoListFromSnapshot);
  }

  //Get completed tasks
  Stream<List<ToDo>> get completedtodos {
    return todoCollection.where('uid', isEqualTo: user!.uid).where(
        'completed', isEqualTo: true).snapshots().map(_todoListFromSnapshot);
  }

  List<ToDo> _todoListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return ToDo(id: doc.id,
          title: doc['title'] ?? '',
          description: doc['description'] ?? '',
          completed: doc['completed'] ?? false,
          timestamp: doc['createAt'] ?? '');
    }).toList();
  }
}
