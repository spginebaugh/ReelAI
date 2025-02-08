import * as logger from "firebase-functions/logger";
import * as admin from "firebase-admin";
import * as fs from "fs";
import * as os from "os";
import * as path from "path";
import {onCall} from "firebase-functions/v2/https";
import {getStorage} from "firebase-admin/storage";
import {dubAudio, elevenLabsApiKey} from "../services/elevenlabs";

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
      let tempDubbedPath: string | undefined;

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
        const dubbedAudio = await dubAudio(tempMp3Path, "pt");

        // Save dubbed audio to temp file
        tempDubbedPath = path.join(os.tmpdir(), `${videoId}_pt.mp3`);
        logger.info("💾 Saving dubbed audio to temp file:", {
          path: tempDubbedPath,
        });
        await fs.promises.writeFile(tempDubbedPath, dubbedAudio);

        // Upload dubbed MP3 to Firebase Storage
        const dubbedStoragePath =
          `${videoData.uploaderId}/${videoId}/audio/audio_portuguese.mp3`;
        logger.info("📤 Uploading Portuguese audio to storage:", {
          path: dubbedStoragePath,
        });

        await getStorage().bucket().upload(tempDubbedPath, {
          destination: dubbedStoragePath,
          metadata: {
            contentType: "audio/mp3",
          },
        });

        logger.info("✅ Audio translation complete:", {
          videoId,
          portuguesePath: dubbedStoragePath,
        });

        return {
          success: true,
          dubbedPath: dubbedStoragePath,
        };
      } finally {
        // Clean up temp files
        for (const [label, path] of [
          ["MP3", tempMp3Path],
          ["Dubbed", tempDubbedPath],
        ]) {
          if (path) {
            try {
              await fs.promises.unlink(path);
              logger.info(`✅ Cleaned up temp ${label} file:`, {path});
            } catch (cleanupError) {
              logger.warn(`⚠️ Failed to clean up temp ${label} file:`, {
                path,
                error: cleanupError,
              });
            }
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
