import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_video_trimmer/flutter_video_trimmer.dart';
import '../models/video.dart';
import '../utils/constants.dart';

class EditVideoScreen extends StatefulWidget {
  final Video video;
  const EditVideoScreen({Key? key, required this.video}) : super(key: key);

  @override
  State<EditVideoScreen> createState() => _EditVideoScreenState();
}

class _EditVideoScreenState extends State<EditVideoScreen> {
  late VideoPlayerController _controller = VideoPlayerController.network(widget.video.videoUrl);
  ChewieController? _chewieController;
  final Trimmer _trimmer = Trimmer();
  bool _isProcessing = false;
  bool _isLoading = true;
  String? _processedVideoPath;
  double _startValue = 0.0;
  double _endValue = 0.0;
  bool _isPlaying = false;
  double _brightness = 1.0;
  String _selectedFilter = 'none';
  EditingMode _currentMode = EditingMode.none;
  File? _tempVideoFile;
  String? _currentPreviewPath;

  final Map<String, String> _filters = VideoConstants.videoFilters;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    setState(() => _isLoading = true);
    
    try {
      // Download video to local storage for trimmer
      final tempDir = await getTemporaryDirectory();
      _tempVideoFile = File('${tempDir.path}/temp_${DateTime.now().millisecondsSinceEpoch}.mp4');
      
      // Download and save the original video
      final videoBytes = await NetworkAssetBundle(Uri.parse(widget.video.videoUrl))
          .load(widget.video.videoUrl);
      await _tempVideoFile!.writeAsBytes(videoBytes.buffer.asUint8List());

      // Initialize video player and trimmer
      await _initializePlayer(_tempVideoFile!);
      await _trimmer.loadVideo(videoFile: _tempVideoFile!);
      
      setState(() {
        _endValue = _controller.value.duration.inMilliseconds.toDouble();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading video: $e')),
        );
      }
    }
  }

  Future<void> _initializePlayer(File videoFile) async {
    try {
      // Ensure previous controllers are properly disposed
      await _controller.dispose();
      _chewieController?.dispose();

      _controller = VideoPlayerController.file(videoFile);
      await _controller.initialize();
      
      _chewieController = ChewieController(
        videoPlayerController: _controller,
        autoPlay: false,
        looping: false,
        deviceOrientationsAfterFullScreen: [DeviceOrientation.portraitUp],
        aspectRatio: _controller.value.aspectRatio,
        allowedScreenSleep: false,
      );
      
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Error initializing player: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error initializing video player: $e')),
        );
      }
    }
  }

  Future<void> _applyFilters() async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);
    
    try {
      // Ensure previous video player is disposed
      await _controller.pause();
      
      final tempDir = await getTemporaryDirectory();
      final outputPath = '${tempDir.path}/preview_${DateTime.now().millisecondsSinceEpoch}.mp4';
      
      // Build the FFmpeg command
      final List<String> filterComponents = [];
      
      // Add selected visual filter
      if (_selectedFilter != 'none' && _filters[_selectedFilter]!.isNotEmpty) {
        filterComponents.add(_filters[_selectedFilter]!);
      }

      // Add brightness adjustment
      if (_brightness != 1.0) {
        final double brightnessValue = (_brightness - 1.0).clamp(-1.0, 1.0);
        filterComponents.add(
          'colorlevels=rimin=${-brightnessValue}:rimax=${brightnessValue}:'
          'gimin=${-brightnessValue}:gimax=${brightnessValue}:'
          'bimin=${-brightnessValue}:bimax=${brightnessValue}'
        );
      }

      String command = '-i "${_tempVideoFile!.path}"';
      if (filterComponents.isNotEmpty) {
        command += ' -vf "${filterComponents.join(',')}"';
      }
      command += ' -c:a copy "$outputPath"';

      debugPrint('Executing FFmpeg command: $command');

      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();
      final output = await session.getOutput();
      final failStackTrace = await session.getFailStackTrace();

      if (!ReturnCode.isSuccess(returnCode)) {
        debugPrint('FFmpeg failed with output: $output');
        debugPrint('FFmpeg failed with stack trace: $failStackTrace');
        throw Exception('Failed to apply filters: ${output ?? 'Unknown error'}');
      }

      // Clean up previous preview file after ensuring new one is ready
      if (_currentPreviewPath != null) {
        final previousFile = File(_currentPreviewPath!);
        if (await previousFile.exists()) {
          await previousFile.delete().catchError((e) {
            debugPrint('Error deleting previous preview file: $e');
          });
        }
      }

      _currentPreviewPath = outputPath;
      await _initializePlayer(File(outputPath));

    } catch (e) {
      debugPrint('Error in _applyFilters: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error applying filters: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _processVideo() async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);
    
    try {
      final tempDir = await getTemporaryDirectory();
      final outputPath = '${tempDir.path}/processed_${DateTime.now().millisecondsSinceEpoch}.mp4';

      // First trim the video
      await _trimmer.saveTrimmedVideo(
        startValue: _startValue,
        endValue: _endValue,
        onSave: (String? outputPath) async {
          debugPrint('Trimmed video saved to: $outputPath');
          if (outputPath != null) {
            setState(() {
              _processedVideoPath = outputPath;
              _isProcessing = false;
            });

            // Apply current filters to the trimmed video
            _tempVideoFile = File(outputPath);
            await _applyFilters();
          }
        },
      );
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _controller.dispose();
    _trimmer.dispose();
    // Clean up all temporary files
    _tempVideoFile?.delete().ignore();
    if (_currentPreviewPath != null) {
      File(_currentPreviewPath!).delete().ignore();
    }
    if (_processedVideoPath != null) {
      File(_processedVideoPath!).delete().ignore();
    }
    super.dispose();
  }

  Widget _buildEditingControls() {
    switch (_currentMode) {
      case EditingMode.trim:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 100,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: VideoViewer(trimmer: _trimmer),
            ),
            TrimViewer(
              trimmer: _trimmer,
              viewerHeight: 50.0,
              viewerWidth: MediaQuery.of(context).size.width * 0.9,
              maxVideoLength: Duration(seconds: VideoConstants.maxVideoDuration),
              onChangeStart: (value) => _startValue = value,
              onChangeEnd: (value) => _endValue = value,
              onChangePlaybackState: (value) => 
                setState(() => _isPlaying = value),
            ),
          ],
        );
      
      case EditingMode.filter:
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Wrap(
            spacing: 8.0,
            children: _filters.keys.map((filter) => 
              ChoiceChip(
                label: Text(filter),
                selected: _selectedFilter == filter,
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _selectedFilter = filter);
                    _applyFilters();
                  }
                },
              ),
            ).toList(),
          ),
        );
      
      case EditingMode.brightness:
        return ListTile(
          title: const Text('Brightness'),
          subtitle: Slider(
            value: _brightness,
            min: 0.0,
            max: 2.0,
            onChanged: (value) {
              setState(() => _brightness = value);
            },
            onChangeEnd: (value) {
              _applyFilters();
            },
          ),
        );
      
      case EditingMode.none:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit: ${widget.video.title}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isProcessing || _isLoading ? null : _processVideo,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isLoading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else if (_controller.value.isInitialized) ...[
            Expanded(
              child: Center(
                child: Container(
                  color: Colors.black,
                  child: Chewie(controller: _chewieController!),
                ),
              ),
            ),
          ] else
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          if (!_isLoading && _currentMode != EditingMode.none)
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: _buildEditingControls(),
              ),
            ),
          if (_isProcessing)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentMode.index,
        onTap: _isLoading ? null : (index) {
          setState(() {
            _currentMode = EditingMode.values[index];
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.video_settings),
            label: 'None',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.content_cut),
            label: 'Trim',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.filter),
            label: 'Filter',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.brightness_6),
            label: 'Brightness',
          ),
        ],
      ),
    );
  }
}

enum EditingMode {
  none,
  trim,
  filter,
  brightness,
}
