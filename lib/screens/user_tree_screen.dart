import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:tradetook/models/user_node.dart';

class GraphPage extends StatefulWidget {
  const GraphPage({super.key});

  @override
  State<GraphPage> createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> {
  final Graph graph = Graph();
  final BuchheimWalkerConfiguration builder = BuchheimWalkerConfiguration();
  final TransformationController _transformationController = TransformationController();

  Map<String, UserNode> userMap = {};
  Map<String, Node> nodeMap = {};

  @override
  void initState() {
    super.initState();
    loadGraph();
  }

  void loadGraph() async {
    userMap = await fetchUserTree();
    buildGraph();
    setState(() {});

    /// Center after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenWidth = MediaQuery.of(context).size.width;
      final screenHeight = MediaQuery.of(context).size.height;

      _transformationController.value = Matrix4.identity()
        ..translate(screenWidth / 2 - 150, screenHeight / 10); // Adjust -150 to shift the root to center
    });
  }

  void buildGraph() {
  graph.nodes.clear();
  graph.edges.clear();
  nodeMap.clear();

  final rootUsers = userMap.values.where((u) => u.parent == "none");

  final queue = <MapEntry<UserNode, int>>[];
  final visited = <String>{};

  for (var root in rootUsers) {
    queue.add(MapEntry(root, 0));
    visited.add(root.mob);

    final node = Node.Id(root.mob);
    nodeMap[root.mob] = node;
    graph.addNode(node);
  }

  while (queue.isNotEmpty) {
    final entry = queue.removeAt(0);
    final user = entry.key;
    final depth = entry.value;

    if (depth >= 3) continue;

    final children = userMap.values.where((u) => u.parent == user.mob);

    for (var child in children) {
      if (visited.contains(child.mob)) continue;

      visited.add(child.mob);

      final childNode = Node.Id(child.mob);
      nodeMap[child.mob] = childNode;
      graph.addNode(childNode);

      // At this point, we know the parent (user) was added
      graph.addEdge(nodeMap[user.mob]!, childNode);

      queue.add(MapEntry(child, depth + 1));
    }
  }

  builder
    ..siblingSeparation = 30
    ..levelSeparation = 50
    ..subtreeSeparation = 40
    ..orientation = BuchheimWalkerConfiguration.ORIENTATION_TOP_BOTTOM;
}



  Widget createNodeWidget(UserNode user) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text('Mob: ${user.mob}'),
          Text('₹ ${user.earning}'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("User Tree")),
      body: userMap.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : InteractiveViewer(
              transformationController: _transformationController,
              constrained: false,
              boundaryMargin: const EdgeInsets.all(200),
              minScale: 0.01,
              maxScale: 5.6,
              child: GraphView(
                graph: graph,
                algorithm: BuchheimWalkerAlgorithm(builder, TreeEdgeRenderer(builder)),
                paint: Paint()..color = Colors.black,
                builder: (Node node) {
                  final mob = node.key!.value as String;
                  final user = userMap[mob]!;
                  return createNodeWidget(user);
                },
              ),
            ),
    );
  }
}

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
