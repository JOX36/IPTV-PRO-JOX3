import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/deep_ocean_colors.dart';
import '../../core/models/media_item.dart';

class PlayerScreen extends StatefulWidget {
  final MediaItem item;

  const PlayerScreen({super.key, required this.item});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
    // WakelockPlus.enable(); // Removed - incompatible plugin
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  Future<void> _initializePlayer() async {
    if (widget.item.url == null) {
      setState(() {
        _hasError = true;
        _errorMessage = 'No hay URL de reproducción disponible';
      });
      return;
    }

    try {
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(widget.item.url!),
      );

      await _videoController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: true,
        looping: false,
        showControls: true,
        allowFullScreen: false,
        allowMuting: true,
        allowPlaybackSpeedChanging: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: DeepOceanColors.accent,
          handleColor: DeepOceanColors.accentGlow,
          backgroundColor: DeepOceanColors.bgCard,
          bufferedColor: DeepOceanColors.accentDark.withOpacity(0.3),
        ),
        placeholder: Container(
          color: DeepOceanColors.bgPrimary,
          child: const Center(
            child: CircularProgressIndicator(
              color: DeepOceanColors.accent,
            ),
          ),
        ),
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline,
                  color: DeepOceanColors.error, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Error al reproducir',
                  style: const TextStyle(
                    color: DeepOceanColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  errorMessage,
                  style: const TextStyle(
                    color: DeepOceanColors.textSecondary,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => _initializePlayer(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                ),
              ],
            ),
          );
        },
      );

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _chewieController?.dispose();
    // WakelockPlus.disable(); // Removed - incompatible plugin
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DeepOceanColors.bgPrimary,
      body: Stack(
        children: [
          // Video
          if (_isLoading)
            const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    color: DeepOceanColors.accent,
                    strokeWidth: 3,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Cargando stream...',
                    style: TextStyle(
                      color: DeepOceanColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          else if (_hasError)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline,
                    color: DeepOceanColors.error, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage ?? 'Error desconocido',
                    style: const TextStyle(
                      color: DeepOceanColors.textSecondary,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _isLoading = true;
                        _hasError = false;
                      });
                      _initializePlayer();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            )
          else if (_chewieController != null)
            GestureDetector(
              onTap: () {
                setState(() => _showControls = !_showControls);
              },
              child: Chewie(controller: _chewieController!),
            ),

          // Overlay de info (aparece al tocar)
          if (_showControls && !_isLoading && !_hasError)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 16,
                  right: 16,
                  bottom: 16,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_rounded,
                        color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.item.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (widget.item.group != null)
                            Text(
                              widget.item.group!,
                              style: TextStyle(
                                color: DeepOceanColors.accent.withOpacity(0.8),
                                fontSize: 13,
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Botón de favorito
                    IconButton(
                      onPressed: () {
                        // TODO: Toggle favorito
                      },
                      icon: const Icon(Icons.favorite_border_rounded,
                        color: DeepOceanColors.favorite, size: 24),
                    ),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: -0.3),
            ),
        ],
      ),
    );
  }
}
