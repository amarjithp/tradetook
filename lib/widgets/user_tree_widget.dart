// lib/widgets/user_tree_widget.dart

import 'package:flutter/material.dart';
import '../models/user_node.dart';

class UserTreeWidget extends StatelessWidget {
  final UserNode user;

  const UserTreeWidget({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
      children: user.children.map((child) => UserTreeWidget(user: child)).toList(),
    );
  }
}
