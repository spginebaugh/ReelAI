import * as logger from "firebase-functions/logger";
import * as fs from "fs";
import ffmpeg from "fluent-ffmpeg";
import * as ffmpegInstaller from "@ffmpeg-installer/ffmpeg";

// Set up FFmpeg path
ffmpeg.setFfmpegPath(ffmpegInstaller.path);

/**
 * Converts a WAV audio file to MP3 format using FFmpeg
 * @param {string} inputPath - Path to the input WAV file
 * @param {string} outputPath - Path where the output MP3 file will be saved
 * @return {Promise<void>} - Resolves when conversion is complete
 */
export async function convertWavToMp3(
  inputPath: string,
  outputPath: string,
): Promise<void> {
  logger.info("🎵 Starting WAV to MP3 conversion:", {
    inputPath,
    outputPath,
    inputExists: await fs.promises.access(inputPath)
      .then(() => true)
      .catch(() => false),
  });

  return new Promise((resolve, reject) => {
    ffmpeg()
      .input(inputPath)
      .toFormat("mp3")
      .on("error", (err: Error) => {
        logger.error("❌ Error converting WAV to MP3:", {
          error: err.message,
          inputPath,
          outputPath,
        });
        reject(err);
      })
      .on("progress", (progress) => {
        logger.info("⏳ FFmpeg conversion progress:", progress);
      })
      .on("end", () => {
        logger.info("✅ Successfully converted WAV to MP3:", {
          outputPath,
          outputExists: fs.existsSync(outputPath),
          outputSize: fs.existsSync(outputPath) ?
            fs.statSync(outputPath).size : 0,
        });
        resolve();
      })
      .save(outputPath);
  });
}
