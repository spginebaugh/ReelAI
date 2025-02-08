import * as logger from "firebase-functions/logger";
import * as fs from "fs";
import fetch from "node-fetch";
import FormData from "form-data";
import {defineSecret} from "firebase-functions/params";

// Define secrets
export const elevenLabsApiKey = defineSecret("ELEVENLABS_API_KEY");

/**
 * Calls ElevenLabs API to dub an audio file
 * @param {string} audioPath - Path to the input audio file
 * @param {string} targetLang - Target language code
 * @return {Promise<{audio: Buffer, dubbingId: string}>} - Audio data and ID
 */
export async function dubAudio(
  audioPath: string,
  targetLang: string,
): Promise<{audio: Buffer; dubbingId: string}> {
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
      "ElevenLabs API error: " +
      `${response.status} ${response.statusText} - ${error}`
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

    const status = await getDubbingStatus(dubbingId);
    logger.info("📊 Dubbing status:", {
      dubbingId,
      status: status.status,
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
          "Error getting dubbed audio: " +
          `${audioResponse.status} - ${error}`
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

  return {
    audio: audioBuffer,
    dubbingId,
  };
}

/**
 * Gets the current status of a dubbing job
 * @param {string} dubbingId - The ID of the dubbing job to check
 * @return {Promise<DubbingStatus>} - Resolves with the current status
 */
async function getDubbingStatus(dubbingId: string): Promise<DubbingStatus> {
  const response = await fetch(
    `https://api.elevenlabs.io/v1/dubbing/${dubbingId}`,
    {
      headers: {
        "xi-api-key": elevenLabsApiKey.value(),
      },
    }
  );

  if (!response.ok) {
    const error = await response.text();
    throw new Error(
      "Error checking dubbing status: " +
      `${response.status} - ${error}`
    );
  }

  return response.json();
}

/**
 * Gets the transcript for a dubbed audio in specified format
 * @param {string} dubbingId - The ID of the dubbing job
 * @param {string} languageCode - The language of transcript (e.g., "pt")
 * @param {"srt" | "webvtt"} format - The desired subtitle format
 * @return {Promise<string>} - Resolves with the transcript content
 */
export async function getDubbedTranscript(
  dubbingId: string,
  languageCode: string,
  format: "srt" | "webvtt" = "srt"
): Promise<string> {
  const response = await fetch(
    `https://api.elevenlabs.io/v1/dubbing/${dubbingId}/transcript/${languageCode}?format_type=${format}`,
    {
      headers: {
        "xi-api-key": elevenLabsApiKey.value(),
      },
    }
  );

  if (!response.ok) {
    const error = await response.text();
    throw new Error(
      "Error getting dubbed transcript: " +
      `${response.status} - ${error}`
    );
  }

  return response.text();
}

/**
 * Gets both SRT and VTT subtitles for a dubbed audio
 * @param {string} dubbingId - The ID of the dubbing job
 * @param {string} languageCode - The language code (e.g., "pt")
 * @return {Promise<{srt: string, vtt: string}>} - both subtitle formats
 */
export async function getSubtitlesForDubbing(
  dubbingId: string,
  languageCode: string,
): Promise<{srt: string; vtt: string}> {
  logger.info("📝 Getting subtitles for dubbing:", {
    dubbingId,
    languageCode,
  });

  const [srt, vtt] = await Promise.all([
    getDubbedTranscript(dubbingId, languageCode, "srt"),
    getDubbedTranscript(dubbingId, languageCode, "webvtt"),
  ]);

  return {srt, vtt};
}

// Interface for dubbing result
export interface DubbingResult {
  audio: Buffer;
  dubbingId: string;
}

// Interface for dubbing status
interface DubbingStatus {
  status: "queued" | "processing" | "done" | "dubbed" | "error";
  error?: string;
}
