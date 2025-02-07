/**
 * Import function triggers from their respective submodules:
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

import * as logger from "firebase-functions/logger";
import * as admin from "firebase-admin";
import {onCall} from "firebase-functions/v2/https";
import {defineSecret} from "firebase-functions/params";
import * as fs from "fs";
import * as os from "os";
import * as path from "path";
import fetch from "node-fetch";
import ffmpeg from "fluent-ffmpeg";
import * as ffmpegInstaller from "@ffmpeg-installer/ffmpeg";
import FormData from "form-data";

// Initialize Firebase Admin
admin.initializeApp();

// Define secrets
const elevenLabsApiKey = defineSecret("ELEVENLABS_API_KEY");

// Set up FFmpeg path
ffmpeg.setFfmpegPath(ffmpegInstaller.path);

/**
 * Converts a WAV audio file to MP3 format using FFmpeg
 * @param {string} inputPath - Path to the input WAV file
 * @param {string} outputPath - Path where the output MP3 file will be saved
 * @return {Promise<void>} - Resolves when conversion is complete
 */
async function convertWavToMp3(
  inputPath: string,
  outputPath: string
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

/**
 * Calls ElevenLabs API to dub an audio file
 * @param {string} audioPath - Path to the input audio file
 * @param {string} targetLang - Target language code
 * @return {Promise<Buffer>} - Resolves with the dubbed audio data
 */
async function dubAudio(
  audioPath: string,
  targetLang: string
): Promise<Buffer> {
  logger.info("🎙️ Starting audio dubbing process:", {
    audioPath,
    targetLang,
    audioExists: await fs.promises.access(audioPath)
      .then(() => true)
      .catch(() => false),
    audioSize: fs.statSync(audioPath).size,
  });

  const formData = new FormData();
  formData.append("file", fs.createReadStream(audioPath));
  formData.append("target_lang", targetLang);
  formData.append("source_lang", "en");
  formData.append("num_speakers", "0");

  logger.info("📤 Sending request to ElevenLabs API...");
  const response = await fetch("https://api.elevenlabs.io/v1/dubbing", {
    method: "POST",
    headers: {
      "xi-api-key": elevenLabsApiKey.value(),
      ...formData.getHeaders(),
    },
    body: formData,
  });

  if (!response.ok) {
    const error = await response.text();
    logger.error("❌ ElevenLabs API error:", {
      status: response.status,
      statusText: response.statusText,
      error,
    });
    throw new Error(
      `ElevenLabs API error: ${response.status} `+
      `${response.statusText} - ${error}`
    );
  }

  const result = await response.json();
  logger.info("✅ Successfully initiated dubbing:", {
    dubbingId: result.dubbing_id,
    expectedDuration: result.expected_duration_sec,
  });

  // Wait for dubbing to complete and get the result
  const dubbingId = result.dubbing_id;
  let isDubbed = false;
  let audioBuffer: Buffer | null = null;
  let attempts = 0;

  while (!isDubbed) {
    attempts++;
    await new Promise((resolve) => setTimeout(resolve, 5000));

    logger.info("🔄 Checking dubbing status:", {
      dubbingId,
      attempt: attempts,
      elapsedTime: attempts * 5,
    });

    // First check the dubbing status
    const statusResponse = await fetch(
      `https://api.elevenlabs.io/v1/dubbing/${dubbingId}`,
      {
        headers: {
          "xi-api-key": elevenLabsApiKey.value(),
        },
      }
    );

    if (!statusResponse.ok) {
      const error = await statusResponse.text();
      logger.error("❌ Error checking dubbing status:", {
        dubbingId,
        status: statusResponse.status,
        error,
        attempts,
      });
      throw new Error(
        `Error checking dubbing status: ${statusResponse.status} - ${error}`
      );
    }

    const status = await statusResponse.json();
    logger.info("📊 Dubbing status:", {
      dubbingId,
      status: status.status,
      attempts,
    });

    // Add detailed logging of the entire status response
    logger.info("📋 Full status response:", {
      dubbingId,
      fullResponse: status,
      responseKeys: Object.keys(status),
      responseType: typeof status,
      attempts,
    });

    if (status.status === "done" || status.status === "dubbed") {
      // Now get the audio with the correct language code
      const audioResponse = await fetch(
        `https://api.elevenlabs.io/v1/dubbing/${dubbingId}/audio/${targetLang}`,
        {
          headers: {
            "xi-api-key": elevenLabsApiKey.value(),
          },
        }
      );

      if (!audioResponse.ok) {
        const error = await audioResponse.text();
        logger.error("❌ Error getting dubbed audio:", {
          dubbingId,
          status: audioResponse.status,
          error,
          attempts,
        });
        throw new Error(
          `Error getting dubbed audio: ${audioResponse.status} - ${error}`
        );
      }

      const arrayBuffer = await audioResponse.arrayBuffer();
      audioBuffer = Buffer.from(arrayBuffer);
      isDubbed = true;
      logger.info("✅ Successfully received dubbed audio:", {
        dubbingId,
        audioSize: audioBuffer.length,
        attempts,
        totalTime: attempts * 5,
      });
    } else if (status.status === "error") {
      logger.error("❌ Dubbing failed:", {
        dubbingId,
        status,
        attempts,
      });
      throw new Error(`Dubbing failed: ${status.error || "Unknown error"}`);
    } else {
      logger.info("⏳ Dubbing still in progress:", {
        dubbingId,
        status: status.status,
        attempts,
        elapsedTime: attempts * 5,
      });
    }
  }

  if (!audioBuffer) {
    logger.error("❌ Failed to get dubbed audio:", {
      dubbingId,
      attempts,
    });
    throw new Error("Failed to get dubbed audio");
  }

  return audioBuffer;
}

// Using v2 functions with correct auth setup
export const generateSubtitles = onCall(
  {
    enforceAppCheck: false,
    timeoutSeconds: 540,
    memory: "2GiB",
    region: "us-central1",
    secrets: [elevenLabsApiKey],
  },
  async (request) => {
    try {
      logger.info("🎬 Starting audio processing request:", {
        hasAuth: !!request.auth,
        userId: request.auth?.uid,
        videoId: request.data?.videoId,
      });

      // Log detailed request information
      logger.info("🔍 Detailed request analysis:", {
        hasAuth: !!request.auth,
        authDetails: request.auth ? {
          uid: request.auth.uid,
          token: request.auth.token,
          hasAppCheckToken: !!request.auth.token?.app_check,
        } : "No auth",
        appDetails: request.app ? {
          id: request.app.appId,
        } : "No app details",
        rawHeaders: request.rawRequest?.headers,
        data: request.data,
      });

      // Ensure user is authenticated
      if (!request.auth) {
        logger.error("❌ Authentication missing - Full context:", {
          request: {
            hasAuth: false,
            rawRequest: request.rawRequest,
            app: request.app,
          },
        });
        throw new Error("User must be authenticated to generate subtitles");
      }

      logger.info("✅ Authentication verified:", {
        uid: request.auth.uid,
        tokenClaims: request.auth.token,
      });

      const {videoId} = request.data;
      if (!videoId) {
        throw new Error("Video ID is required");
      }

      // Get video document from Firestore
      logger.info("📂 Fetching video document:", {
        videoId,
        userId: request.auth.uid,
      });

      const videoDoc = await admin
        .firestore()
        .collection("videos")
        .doc(videoId)
        .get();

      if (!videoDoc.exists) {
        logger.error("❌ Video document not found:", {videoId});
        throw new Error("Video not found");
      }

      // Verify user owns this video
      const videoData = videoDoc.data();
      if (videoData?.uploaderId !== request.auth.uid) {
        logger.error("User not authorized:", {
          requestUserId: request.auth.uid,
          videoUploaderId: videoData?.uploaderId,
        });
        throw new Error("Not authorized to generate subtitles for this video");
      }

      if (!videoData?.audioUrl) {
        throw new Error("Audio URL not found for video");
      }

      // Log the audio URL from Firestore
      logger.info("🎵 Audio file path from Firestore:", {
        audioUrl: videoData.audioUrl,
      });

      let tempWavPath: string | undefined;
      let tempMp3Path: string | undefined;
      let tempDubbedPath: string | undefined;

      try {
        logger.info("📥 Downloading WAV file:", {
          audioUrl: videoData.audioUrl,
        });

        // Download the WAV file
        const response = await fetch(
          videoData.audioUrl,
          {headers: {Accept: "audio/wav"}}
        );

        // Log response details
        logger.info("📥 Download response details:", {
          status: response.status,
          contentType: response.headers.get("content-type"),
          contentLength: response.headers.get("content-length"),
        });

        if (!response.ok) {
          throw new Error(
            `Failed to download file: ${response.status} ${response.statusText}`
          );
        }

        const contentType = response.headers.get("content-type");
        if (!contentType?.includes("audio/")) {
          logger.warn("⚠️ Unexpected content type:", {
            contentType,
            expectedType: "audio/wav",
          });
        }

        tempWavPath = path.join(os.tmpdir(), `${videoId}.wav`);
        const fileStream = fs.createWriteStream(tempWavPath);

        await new Promise<void>((resolve, reject) => {
          response.body.on("error", (error) => {
            fileStream.destroy();
            reject(error);
          });

          fileStream.on("error", (error) => {
            response.body.unpipe();
            reject(error);
          });

          fileStream.on("finish", () => {
            fileStream.close();
          });

          fileStream.on("close", () => {
            resolve();
          });

          response.body.pipe(fileStream);
        });

        logger.info("💾 Saving WAV file to temp storage:", {
          tempPath: tempWavPath,
        });

        // Convert WAV to MP3
        tempMp3Path = path.join(os.tmpdir(), `${videoId}.mp3`);
        await convertWavToMp3(tempWavPath, tempMp3Path);

        // Upload English MP3 to Firebase Storage
        const mp3StoragePath =
          `${videoData.uploaderId}/${videoId}/audio/audio_english.mp3`;
        logger.info("📤 Uploading English MP3 to storage:", {
          path: mp3StoragePath,
        });

        await admin.storage().bucket().upload(tempMp3Path, {
          destination: mp3StoragePath,
          metadata: {
            contentType: "audio/mp3",
          },
        });

        logger.info("✅ English MP3 upload complete");

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

        await admin.storage().bucket().upload(tempDubbedPath, {
          destination: dubbedStoragePath,
          metadata: {
            contentType: "audio/mp3",
          },
        });

        logger.info("✅ Audio processing complete:", {
          videoId,
          englishPath: mp3StoragePath,
          portuguesePath: dubbedStoragePath,
        });

        return {
          success: true,
          mp3Path: mp3StoragePath,
          dubbedPath: dubbedStoragePath,
        };
      } finally {
        // Clean up temp files with logging
        for (const [label, path] of [
          ["WAV", tempWavPath],
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
      logger.error("❌ Error in audio processing:", {
        error: error instanceof Error ? error.message : "Unknown error",
        stack: error instanceof Error ? error.stack : undefined,
      });
      if (error instanceof Error) {
        throw new Error(`Failed to process audio: ${error.message}`);
      }
      throw new Error("Failed to process audio: Unknown error");
    }
  },
);
