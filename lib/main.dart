import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'firebase_options.dart';

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

class VideoItem {
  final String title;
  final String url;

  VideoItem({required this.title, required this.url});
}

class YouTubeGridPage extends StatelessWidget {
  const YouTubeGridPage({super.key});

  Future<List<VideoItem>> fetchYouTubeVideos() async {
  try {
    final ref = FirebaseDatabase.instance.ref().child('youtubeVideos');
    final snapshot = await ref.get();

    debugPrint('📦 Snapshot: ${snapshot.value}');

    final data = snapshot.value;

    if (data is List) {
      return data
          .whereType<Map>() // filters out any nulls or non-map entries
          .map((e) {
            final item = Map<String, dynamic>.from(e);
            return VideoItem(
              title: item['title'] ?? 'No Title',
              url: item['url'] ?? '',
            );
          })
          .toList();
    } else {
      debugPrint('❌ youtubeVideos is not a List');
    }
  } catch (e) {
    debugPrint('⚠️ Error fetching data: $e');
  }

  return [];
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
                  final thumbnail =
                      'https://img.youtube.com/vi/$videoId/0.jpg';

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              YouTubePlayerScreen(videoId: videoId),
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
  const YouTubePlayerScreen({super.key, required this.videoId});

  @override
  State<YouTubePlayerScreen> createState() => _YouTubePlayerScreenState();
}

class _YouTubePlayerScreenState extends State<YouTubePlayerScreen> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
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
        child: YoutubePlayer(
          controller: _controller,
          aspectRatio: 16 / 9,
        ),
      ),
    );
  }
}
