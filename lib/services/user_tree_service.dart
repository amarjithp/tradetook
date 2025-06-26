import 'package:firebase_database/firebase_database.dart';
import '../models/user_node.dart';

Future<Map<String, UserNode>> fetchUserTree() async {
  final ref = FirebaseDatabase.instance.ref("usersTable");
  final snapshot = await ref.get();

  if (snapshot.exists) {
    final Map<String, dynamic> data =
        Map<String, dynamic>.from(snapshot.value as Map);
    return data.map((key, value) =>
        MapEntry(key, UserNode.fromJson(Map<String, dynamic>.from(value))));
  } else {
    return {};
  }
}
