import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'firebase_options.dart';
import 'package:tradetook/models/video_item.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('✅ Firebase initialized!');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Responsive YouTube Grid',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.red),
      home: const YouTubeGridPage(),
    );
  }
}



class YouTubeGridPage extends StatelessWidget {
  const YouTubeGridPage({super.key});

  Future<void> addRichYouTubeVideo({
    required String title,
    required String link,
  }) async {
    try {
      final ref = FirebaseDatabase.instance.ref().child('youTubeVideos');

      // Hardcoded dummy values
      final dayWiseHits = {
        'sun': 3,
        'mon': 2,
        'tue': 1,
        'wed': 0,
        'thu': 4,
        'fri': 1,
        'sat': 0,
      };

      final videoData = {
        'title': title,
        'link': link,
        'desc': 'This is a sample description for testing.',
        'hitCounts': {
          'totalHits': 11,
          'dayWiseHits': dayWiseHits,
          'hitUsersMob': {'9876543210': true, '9123456789': true},
        },
      };

      await ref.push().set(videoData);
      debugPrint('✅ Video added with dummy hit counts and user mobiles');
    } catch (e) {
      debugPrint('❌ Error adding video: $e');
    }
  }

  /*Future<void> addYouTubeVideo(String title, String url) async {
    try {
      final ref = FirebaseDatabase.instance.ref().child('youtubeVideos');
      await ref.push().set({
        'title': title,
        'url': url,
      });
      debugPrint('✅ Video added successfully');
    } catch (e) {
      debugPrint('❌ Failed to add video: $e');
    }
  }*/

  Future<List<VideoItem>> fetchYouTubeVideos() async {
    addRichYouTubeVideo(
  title: 'chemtrails',
  link: 'https://youtu.be/vBHild0PiTE?si=m2InfkoDRFwEsVu0',
);

  try {
    final ref = FirebaseDatabase.instance.ref().child('youTubeVideos');
    final snapshot = await ref.get();

    debugPrint('📦 Snapshot: ${snapshot.value}');

    final data = snapshot.value;

    if (data is Map) {
      return (data).entries.map((entry) {
      final item = Map<String, dynamic>.from(entry.value);
      return VideoItem.fromMap(item)..firebaseKey = entry.key;
    }).toList();
    } else {
      return [];
    }
  } catch (e) {
    debugPrint('❌ Error fetching videos: $e');
    return [];
  }
}


  String extractVideoId(String url) {
    return YoutubePlayerController.convertUrlToId(url) ?? '';
  }

  int calculateColumnCount(double width) {
    if (width >= 1024) return 4;
    if (width >= 800) return 3;
    if (width >= 600) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('YouTube Video Gallery')),
      body: FutureBuilder<List<VideoItem>>(
        future: fetchYouTubeVideos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No videos found.'));
          }

          final videos = snapshot.data!;
          return LayoutBuilder(
            builder: (context, constraints) {
              final columnCount = calculateColumnCount(constraints.maxWidth);

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columnCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 16 / 10,
                ),
                itemCount: videos.length,
                itemBuilder: (context, index) {
                  final video = videos[index];
                  final videoId = extractVideoId(video.url);
                  final thumbnail = 'https://img.youtube.com/vi/$videoId/0.jpg';

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => YouTubePlayerScreen(
                            videoId: videoId,
                            firebaseKey: video.firebaseKey!,
                          ),
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        Expanded(
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  thumbnail,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const Center(
                                child: Icon(
                                  Icons.play_circle_fill,
                                  size: 64,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          video.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class YouTubePlayerScreen extends StatefulWidget {
  final String videoId;
  final String firebaseKey;

  const YouTubePlayerScreen({super.key, required this.videoId, required this.firebaseKey,});

  @override
  State<YouTubePlayerScreen> createState() => _YouTubePlayerScreenState();
}

class _YouTubePlayerScreenState extends State<YouTubePlayerScreen> {
  late YoutubePlayerController _controller;
  Future<void> incrementHitCount() async {
    final ref = FirebaseDatabase.instance.ref('youTubeVideos/${widget.firebaseKey}/hitCounts/totalHits');

    try {
      final snapshot = await ref.get();
      final currentHits = snapshot.value as int? ?? 0;
      await ref.set(currentHits + 1);
      debugPrint('🔥 totalHits updated to ${currentHits + 1}');
    } catch (e) {
      debugPrint('❌ Failed to update totalHits: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    incrementHitCount();
    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.videoId,
      autoPlay: true,
      params: const YoutubePlayerParams(
        showFullscreenButton: true,
        showVideoAnnotations: false,
        playsInline: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller.stopVideo();
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Playing Video')),
      body: Center(
        child: YoutubePlayer(controller: _controller, aspectRatio: 16 / 9),
      ),
    );
  }
}
