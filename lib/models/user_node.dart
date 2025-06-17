class UserNode {
  final String id; // Same as mobile
  final String name;
  final String mobile;
  final int earning;
  final String parent;
  final List<UserNode> children;

  UserNode({
    required this.id,
    required this.name,
    required this.mobile,
    required this.earning,
    required this.parent,
    required this.children,
  });

  factory UserNode.fromMap(String id, Map data) {
    final children = <UserNode>[];

    if (data['children'] != null) {
      final childrenMap = Map<String, dynamic>.from(data['children']);
      childrenMap.forEach((childId, childData) {
        children.add(UserNode.fromMap(
          childId,
          Map<String, dynamic>.from(childData),
        ));
      });
    }

    return UserNode(
      id: id,
      name: data['name'] ?? '',
      mobile: data['mobile'] ?? '',
      earning: data['earning'] ?? 0,
      parent: data['parent'] ?? '',
      children: children,
    );
  }
}
