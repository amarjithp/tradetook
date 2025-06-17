import 'package:firebase_database/firebase_database.dart';
import '../models/user_node.dart';

Future<UserNode?> fetchUserTreeFromFirebase() async {
  final ref = FirebaseDatabase.instance.ref('usersTree');
  final snapshot = await ref.get();

  if (snapshot.exists) {
    final data = Map<String, dynamic>.from(snapshot.value as Map);
    final rootId = data.keys.first;
    final rootData = Map<String, dynamic>.from(data[rootId]);
    return UserNode.fromMap(rootId, rootData);
  }

  return null;
}
