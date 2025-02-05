import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:path_provider/path_provider.dart';
import '../models/video.dart';
import '../models/video_edit_state.dart';
import '../models/filter_option.dart';
import '../utils/constants.dart';
import '../services/video_processing_service.dart';
import '../widgets/trim_controls_widget.dart';
import '../widgets/filter_controls_widget.dart';
import '../widgets/brightness_controls_widget.dart';

class EditVideoScreen extends StatefulWidget {
  final Video video;
  const EditVideoScreen({Key? key, required this.video}) : super(key: key);

  @override
  State<EditVideoScreen> createState() => _EditVideoScreenState();
}

class _EditVideoScreenState extends State<EditVideoScreen> {
  late VideoPlayerController _controller;
  ChewieController? _chewieController;
  late final VideoProcessingService _videoService = VideoProcessingService();
  late VideoEditState _editState = VideoEditState.initial();
  final List<FilterOption> _filterOptions = VideoConstants.videoFilters.toFilterOptions();

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    setState(() => _editState = _editState.copyWith(isLoading: true));
    
    try {
      // Download and save the original video
      final tempFile = await _videoService.downloadVideo(widget.video.videoUrl);
      
      // Initialize video player
      _controller = VideoPlayerController.file(tempFile);
      await _controller.initialize();
      
      _chewieController = await _videoService.initializePlayer(tempFile);
      
      final duration = await _videoService.getVideoDuration(tempFile);
      
      setState(() {
        _editState = _editState.copyWith(
          endValue: duration,
          isLoading: false,
          tempVideoFile: tempFile,
        );
      });
    } catch (e) {
      setState(() => _editState = _editState.copyWith(isLoading: false));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading video: $e')),
        );
      }
    }
  }

  Future<void> _applyFilters() async {
    if (_editState.isProcessing) return;

    setState(() => _editState = _editState.copyWith(isProcessing: true));
    
    try {
      _chewieController?.pause();
      
      final tempDir = await getTemporaryDirectory();
      final outputPath = '${tempDir.path}/preview_${DateTime.now().millisecondsSinceEpoch}.mp4';
      
      final filteredPath = await _videoService.applyFilters(
        inputFile: _editState.tempVideoFile!,
        filter: _editState.selectedFilter,
        brightness: _editState.brightness,
        outputPath: outputPath,
      );

      // Clean up previous preview file
      await _videoService.cleanup([_editState.currentPreviewPath]);

      setState(() {
        _editState = _editState.copyWith(
          currentPreviewPath: filteredPath,
          isProcessing: false,
        );
      });
      
      _chewieController = await _videoService.initializePlayer(File(filteredPath));
      setState(() {});

    } catch (e) {
      setState(() => _editState = _editState.copyWith(isProcessing: false));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error applying filters: $e')),
        );
      }
    }
  }

  Future<void> _processVideo() async {
    if (_editState.isProcessing) return;

    setState(() => _editState = _editState.copyWith(isProcessing: true));
    
    try {
      final outputPath = await _videoService.trimVideo(
        inputFile: _editState.tempVideoFile!,
        startValue: _editState.startValue,
        endValue: _editState.endValue,
      );

      if (outputPath != null) {
        setState(() {
          _editState = _editState.copyWith(
            processedVideoPath: outputPath,
            isProcessing: false,
            tempVideoFile: File(outputPath),
          );
        });
      }
    } catch (e) {
      setState(() => _editState = _editState.copyWith(isProcessing: false));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Widget _buildEditingControls() {
    switch (_editState.currentMode) {
      case EditingMode.trim:
        return TrimControlsWidget(
          controller: _controller,
          startValue: _editState.startValue,
          endValue: _editState.endValue,
          onChangeStart: (value) => setState(() => 
            _editState = _editState.copyWith(startValue: value)),
          onChangeEnd: (value) => setState(() => 
            _editState = _editState.copyWith(endValue: value)),
          onChangePlaybackState: (value) => setState(() => 
            _editState = _editState.copyWith(isPlaying: value)),
        );
      
      case EditingMode.filter:
        return FilterControlsWidget(
          selectedFilter: _editState.selectedFilter.name,
          onFilterSelected: (filterName) {
            final filter = _filterOptions.firstWhere((f) => f.name == filterName);
            setState(() => _editState = _editState.copyWith(selectedFilter: filter));
            _applyFilters();
          },
        );
      
      case EditingMode.brightness:
        return BrightnessControlsWidget(
          brightness: _editState.brightness,
          onChanged: (value) => setState(() =>
            _editState = _editState.copyWith(brightness: value)),
          onChangeEnd: (value) => _applyFilters(),
        );
      
      case EditingMode.none:
        return const SizedBox.shrink();
    }
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _controller.dispose();
    _videoService.dispose();
    // Clean up all temporary files
    _videoService.cleanup([
      _editState.tempVideoFile?.path,
      _editState.currentPreviewPath,
      _editState.processedVideoPath,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit: ${widget.video.title}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _editState.isProcessing || _editState.isLoading 
              ? null 
              : _processVideo,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_editState.isLoading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else if (_chewieController != null) ...[
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
          if (!_editState.isLoading && _editState.currentMode != EditingMode.none)
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
          if (_editState.isProcessing)
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
        currentIndex: _editState.currentMode.index,
        onTap: _editState.isLoading || _editState.isProcessing
            ? null
            : (index) {
                setState(() {
                  _editState = _editState.copyWith(
                    currentMode: EditingMode.values[index],
                  );
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
