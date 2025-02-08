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
 * @return {Promise<Buffer>} - Resolves with the dubbed audio data
 */
export async function dubAudio(
  audioPath: string,
  targetLang: string,
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

/**
 * Calls ElevenLabs API to generate transcript from audio file
 * @param {string} audioPath - Path to the input audio file
 * @param {string} [language] - Optional ISO-639-1 or ISO-639-3 language code
 * @return {Promise<TranscriptResponse>} - Resolves with the transcript data
 */
export async function generateTranscript(
  audioPath: string,
  language?: string,
): Promise<TranscriptResponse> {
  logger.info("🎙️ Starting speech-to-text transcription:", {
    audioPath,
    language,
    audioExists: await fs.promises.access(audioPath)
      .then(() => true)
      .catch(() => false),
    audioSize: fs.statSync(audioPath).size,
  });

  const formData = new FormData();
  formData.append("file", fs.createReadStream(audioPath));
  formData.append("model_id", "scribe_v1");
  if (language) {
    formData.append("language_code", language);
  }

  logger.info("📤 Sending request to ElevenLabs speech-to-text API...");
  const response = await fetch("https://api.elevenlabs.io/v1/speech-to-text", {
    method: "POST",
    headers: {
      "xi-api-key": elevenLabsApiKey.value(),
      ...formData.getHeaders(),
    },
    body: formData,
  });

  if (!response.ok) {
    const error = await response.text();
    logger.error("❌ ElevenLabs speech-to-text API error:", {
      status: response.status,
      statusText: response.statusText,
      error,
    });
    throw new Error(
      `ElevenLabs speech-to-text API error: ${response.status} ` +
      `${response.statusText} - ${error}`
    );
  }

  const result = await response.json();
  logger.info("✅ Successfully generated transcript:", {
    languageCode: result.language_code,
    confidence: result.language_probability,
    textLength: result.text.length,
    wordCount: result.words.length,
  });

  return result;
}

// Add TypeScript interface for the transcript response
interface TranscriptResponse {
  language_code: string;
  language_probability: number;
  text: string;
  words: Array<{
    text: string;
    type: string;
    speaker_id: string;
    start: number;
    end: number;
  }>;
}
