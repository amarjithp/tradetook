class VideoItem {
  final String title;
  final String url;
  final String desc;
  final int totalHits;
  final Map<String, int> dayWiseHits;
  final List<String> hitUsersMob;

  VideoItem({
    required this.title,
    required this.url,
    required this.desc,
    required this.totalHits,
    required this.dayWiseHits,
    required this.hitUsersMob,
  });

  // Factory constructor to create from Firebase Map
  factory VideoItem.fromMap(Map<String, dynamic> map) {
    return VideoItem(
      title: map['title'] ?? 'No Title',
      url: map['link'] ?? '',
      desc: map['desc'] ?? '',
      totalHits: map['hitCounts']?['totalHits'] ?? 0,
      dayWiseHits: Map<String, int>.from(map['hitCounts']?['dayWiseHits'] ?? {}),
      hitUsersMob: (map['hitCounts']?['hitUsersMob'] as Map?)?.keys.map((e) => e.toString()).toList() ?? [],
    );
  }

  // Optional: convert back to map (useful if pushing this object)
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'link': url,
      'desc': desc,
      'hitCounts': {
        'totalHits': totalHits,
        'dayWiseHits': dayWiseHits,
        'hitUsersMob': {for (var mob in hitUsersMob) mob: true},
      },
    };
  }
}
