import 'dart:io';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import '../models/filter_option.dart';

class FFmpegService {
  /// Applies visual filters and brightness adjustments to a video file
  Future<String> applyFilters({
    required File inputFile,
    required FilterOption filter,
    required double brightness,
    required String outputPath,
  }) async {
    final List<String> filterComponents = [];

    // Add selected visual filter
    if (filter != FilterOption.none) {
      filterComponents.add(filter.ffmpegCommand);
    }

    // Add brightness adjustment
    if (brightness != 1.0) {
      final double brightnessValue = (brightness - 1.0).clamp(-1.0, 1.0);
      filterComponents
          .add('colorlevels=rimin=${-brightnessValue}:rimax=${brightnessValue}:'
              'gimin=${-brightnessValue}:gimax=${brightnessValue}:'
              'bimin=${-brightnessValue}:bimax=${brightnessValue}');
    }

    String command = '-i "${inputFile.path}"';
    if (filterComponents.isNotEmpty) {
      command += ' -vf "${filterComponents.join(',')}"';
    }
    command += ' -c:a copy "$outputPath"';

    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();

    if (!ReturnCode.isSuccess(returnCode)) {
      final output = await session.getOutput();
      throw Exception('Failed to apply filters: ${output ?? 'Unknown error'}');
    }

    return outputPath;
  }

  /// Cleans up a video file if it exists
  Future<void> cleanupFile(String? filePath) async {
    if (filePath != null) {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    }
  }
}
