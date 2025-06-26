class UserNode {
  final String mob;
  final String name;
  final int earning;
  final String parent;

  UserNode({
    required this.mob,
    required this.name,
    required this.earning,
    required this.parent,
  });

  factory UserNode.fromJson(Map<String, dynamic> json) {
    return UserNode(
      mob: json['Mob'],
      name: json['name'],
      earning: json['earning'],
      parent: json['parent'],
    );
  }
}
