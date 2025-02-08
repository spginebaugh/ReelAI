import * as logger from "firebase-functions/logger";
import * as admin from "firebase-admin";
import * as fs from "fs";
import * as os from "os";
import * as path from "path";
import {onCall} from "firebase-functions/v2/https";
import {getStorage} from "firebase-admin/storage";
import {
  dubAudio,
  getSubtitlesForDubbing,
  elevenLabsApiKey,
} from "../services/elevenlabs";
import {validateSubtitleFormat} from "../services/subtitle-converter";

// Using v2 functions with correct auth setup
export const generateTranslation = onCall(
  {
    enforceAppCheck: false,
    timeoutSeconds: 540,
    memory: "2GiB",
    region: "us-central1",
    secrets: [elevenLabsApiKey],
  },
  async (request) => {
    try {
      logger.info("🎬 Starting translation request:", {
        hasAuth: !!request.auth,
        userId: request.auth?.uid,
        videoId: request.data?.videoId,
      });

      // Ensure user is authenticated
      if (!request.auth) {
        throw new Error("User must be authenticated to translate audio");
      }

      const {videoId} = request.data;
      if (!videoId) {
        throw new Error("Video ID is required");
      }

      // Get video document from Firestore
      const videoDoc = await admin
        .firestore()
        .collection("videos")
        .doc(videoId)
        .get();

      if (!videoDoc.exists) {
        throw new Error("Video not found");
      }

      // Verify user owns this video
      const videoData = videoDoc.data();
      if (videoData?.uploaderId !== request.auth.uid) {
        throw new Error("Not authorized to translate this video");
      }

      const mp3StoragePath = [
        videoData.uploaderId,
        videoId,
        "audio",
        "audio_english.mp3",
      ].join("/");
      let tempMp3Path: string | undefined;

      try {
        // Download the existing MP3 file
        tempMp3Path = path.join(os.tmpdir(), `${videoId}.mp3`);
        await getStorage().bucket().file(mp3StoragePath).download({
          destination: tempMp3Path,
        });

        logger.info("📥 Downloaded MP3 file:", {
          path: tempMp3Path,
          size: fs.statSync(tempMp3Path).size,
        });

        // Dub the audio to Portuguese
        logger.info("🎙️ Starting Portuguese dubbing process");
        const {
          audio: dubbedAudio,
          dubbingId,
        } = await dubAudio(tempMp3Path, "pt");

        // Upload dubbed MP3 to Firebase Storage
        const dubbedStoragePath = [
          videoData.uploaderId,
          videoId,
          "audio",
          "audio_portuguese.mp3",
        ].join("/");

        logger.info("📤 Uploading Portuguese audio to storage:", {
          path: dubbedStoragePath,
        });

        await getStorage().bucket().file(dubbedStoragePath).save(dubbedAudio, {
          contentType: "audio/mp3",
        });

        // Get subtitles for the dubbed audio
        logger.info("📝 Getting Portuguese subtitles...");
        const {srt, vtt} = await getSubtitlesForDubbing(dubbingId, "pt");

        // Validate subtitle formats
        if (!validateSubtitleFormat(srt, "srt")) {
          throw new Error("Generated SRT content failed validation");
        }
        if (!validateSubtitleFormat(vtt, "vtt")) {
          throw new Error("Generated VTT content failed validation");
        }

        // Calculate the base subtitles path
        const baseSubtitlesPath = [
          videoData.uploaderId,
          videoId,
          "subtitles",
          "subtitles_portuguese",
        ].join("/");

        // Upload all subtitle formats
        const uploads = [
          // SRT subtitles
          getStorage()
            .bucket()
            .file(`${baseSubtitlesPath}.srt`)
            .save(srt, {
              contentType: "text/plain",
              metadata: {
                language: "pt",
              },
            }),
          // VTT subtitles
          getStorage()
            .bucket()
            .file(`${baseSubtitlesPath}.vtt`)
            .save(vtt, {
              contentType: "text/vtt",
              metadata: {
                language: "pt",
              },
            }),
        ];

        await Promise.all(uploads);

        logger.info("✅ Audio translation and subtitle generation complete:", {
          videoId,
          portuguesePath: dubbedStoragePath,
          subtitlePath: baseSubtitlesPath,
        });

        return {
          success: true,
          dubbedPath: dubbedStoragePath,
          subtitlesPath: baseSubtitlesPath,
        };
      } finally {
        // Clean up temp files
        if (tempMp3Path) {
          try {
            await fs.promises.unlink(tempMp3Path);
            logger.info("✅ Cleaned up temp MP3 file:", {path: tempMp3Path});
          } catch (cleanupError) {
            logger.warn("⚠️ Failed to clean up temp MP3 file:", {
              path: tempMp3Path,
              error: cleanupError,
            });
          }
        }
      }
    } catch (error) {
      logger.error("❌ Error in audio translation:", {
        error: error instanceof Error ? error.message : "Unknown error",
        stack: error instanceof Error ? error.stack : undefined,
      });
      if (error instanceof Error) {
        throw new Error(`Failed to translate audio: ${error.message}`);
      }
      throw new Error("Failed to translate audio: Unknown error");
    }
  },
);
