import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import '../models/user_node.dart';
import '../services/user_tree_service.dart';

class UserTreeGraphScreen extends StatefulWidget {
  const UserTreeGraphScreen({super.key});

  @override
  State<UserTreeGraphScreen> createState() => _UserTreeGraphScreenState();
}

class _UserTreeGraphScreenState extends State<UserTreeGraphScreen> {
  final Graph graph = Graph()..isTree = true;
  final BuchheimWalkerConfiguration builder = BuchheimWalkerConfiguration();

  final Map<String, Node> nodeCache = {};
  final Map<String, Widget> nodeWidgets = {};

  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadTree();
  }

  Future<void> _loadTree() async {
    final root = await fetchUserTreeFromFirebase();
    if (root != null) {
      graph.nodes.clear();
      graph.edges.clear();
      nodeCache.clear();
      nodeWidgets.clear();
      _buildGraph(root);
    }

    setState(() {
      loading = false;
    });
  }

  void _buildGraph(UserNode node) {
    final parentNode = _getOrCreateNode(node);

    for (final child in node.children) {
      final childNode = _getOrCreateNode(child);
      graph.addEdge(parentNode, childNode);
      _buildGraph(child);
    }
  }

  Node _getOrCreateNode(UserNode user) {
  if (nodeCache.containsKey(user.id)) {
    return nodeCache[user.id]!;
  }

  final widget = Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Colors.green.shade100,
      border: Border.all(color: Colors.green),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text("📱 ${user.mobile}"),
        Text("💰 ${user.earning}"),
      ],
    ),
  );

  final node = Node.Id(user.id);
  nodeCache[user.id] = node;
  nodeWidgets[user.id] = widget;
  return node;
}


  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("User Tree Graph")),
      body: InteractiveViewer(
        constrained: false,
        boundaryMargin: const EdgeInsets.all(100),
        minScale: 0.01,
        maxScale: 5.0,
        child: GraphView(
          graph: graph,
          algorithm: BuchheimWalkerAlgorithm(builder, TreeEdgeRenderer(builder)),
          builder: (Node node) {
            final id = node.key!.value as String;
            return nodeWidgets[id] ?? const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
