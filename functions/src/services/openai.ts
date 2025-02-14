import * as logger from "firebase-functions/logger";
import * as fs from "fs";
import fetch from "node-fetch";
import FormData from "form-data";
import {defineSecret} from "firebase-functions/params";

// Define secrets
export const openAiApiKey = defineSecret("OPENAI_API_KEY");

/**
 * Calls OpenAI Whisper API to generate transcript from audio file
 * @param {string} audioPath - Path to the input audio file
 * @return {Promise<WhisperResponse>} - Resolves with the transcript data
 */
export async function generateTranscript(
  audioPath: string,
): Promise<WhisperResponse> {
  const MAX_RETRIES = 3;
  const RETRY_DELAY = 5000; // 5 seconds
  const MAX_FILE_SIZE = 25 * 1024 * 1024; // 25MB (OpenAI's limit)

  logger.info("🎙️ Starting OpenAI speech-to-text transcription:", {
    audioPath,
    audioExists: await fs.promises.access(audioPath)
      .then(() => true)
      .catch(() => false),
    audioSize: fs.statSync(audioPath).size,
  });

  // Check file size before attempting transcription
  const fileSize = fs.statSync(audioPath).size;
  if (fileSize > MAX_FILE_SIZE) {
    throw new Error(
      `Audio file size (${fileSize} bytes) ` +
      `exceeds OpenAI's limit of ${MAX_FILE_SIZE} bytes`
    );
  }

  let lastError: Error | null = null;
  for (let attempt = 1; attempt <= MAX_RETRIES; attempt++) {
    try {
      const formData = new FormData();
      formData.append("file", fs.createReadStream(audioPath));
      formData.append("model", "whisper-1");
      formData.append("language", "en");
      formData.append("response_format", "verbose_json");
      formData.append("timestamp_granularities[]", "word");

      logger.info("📤 Sending request to OpenAI Whisper API...", {
        attempt,
        maxRetries: MAX_RETRIES,
      });

      const response = await fetch(
        "https://api.openai.com/v1/audio/transcriptions",
        {
          method: "POST",
          headers: {
            "Authorization": `Bearer ${openAiApiKey.value()}`,
            ...formData.getHeaders(),
          },
          body: formData,
        },
      );

      if (!response.ok) {
        const error = await response.text();
        logger.error("❌ OpenAI Whisper API error:", {
          status: response.status,
          statusText: response.statusText,
          error,
          attempt,
        });

        // Only retry on 5xx errors (server errors)
        if (response.status >= 500 && attempt < MAX_RETRIES) {
          lastError = new Error(
            "OpenAI Whisper API error: " +
            `${response.status}${response.statusText} - ${error}`
          );
          logger.info(`⏳ Retrying in ${RETRY_DELAY/1000} seconds...`, {
            attempt,
            maxRetries: MAX_RETRIES,
          });
          await new Promise((resolve) => setTimeout(resolve, RETRY_DELAY));
          continue;
        }

        throw new Error(
          "OpenAI Whisper API error: " +
          `${response.status}${response.statusText} - ${error}`
        );
      }

      const result = await response.json();

      logger.info("✅ Successfully generated transcript:", {
        language: result.language,
        duration: result.duration,
        textLength: result.text.length,
        wordCount: result.words.length,
        attempt,
      });

      return result;
    } catch (error) {
      lastError = error as Error;
      if (attempt === MAX_RETRIES) {
        logger.error("❌ All retry attempts failed:", {
          error: lastError.message,
          attempts: MAX_RETRIES,
        });
        throw lastError;
      }
    }
  }

  // This should never happen due to the throw in the loop above
  throw lastError || new Error("Unknown error in transcript generation");
}

// TypeScript interface for the Whisper API response
interface WhisperResponse {
  task: string;
  language: string;
  duration: number;
  text: string;
  words: Array<{
    word: string;
    start: number;
    end: number;
    confidence: number;
  }>;
  segments: Array<{
    id: number;
    seek: number;
    start: number;
    end: number;
    text: string;
    tokens: number[];
    temperature: number;
    avg_logprob: number;
    compression_ratio: number;
    no_speech_prob: number;
  }>;
}

interface VideoMetadata {
  title: string;
  description: string;
}

/**
 * Generates video title and description from transcript using GPT-4
 * @param {WhisperResponse} transcript - The transcript data from Whisper API
 * @return {Promise<VideoMetadata>} - Resolve w/ generated title and description
 */
export async function generateVideoMetadata(
  transcript: WhisperResponse,
): Promise<VideoMetadata> {
  logger.info("🤖 Starting metadata generation with GPT-4...", {
    transcriptLength: transcript.text.length,
    language: transcript.language,
  });

  try {
    const response = await fetch("https://api.openai.com/v1/chat/completions", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Authorization": `Bearer ${openAiApiKey.value()}`,
      },
      body: JSON.stringify({
        model: "gpt-4o-mini",
        messages: [
          {
            role: "system",
            content:
              "You are a professional video metadata generator. "+
              `Your task is to:
1. Generate a concise, engaging title (max 100 characters)
2. Create a clear, informative description (max 500 characters)
Both should accurately reflect the content while being SEO-friendly.
Respond in JSON format: {"title": "...", "description": "..."}`,
          },
          {
            role: "user",
            content:
              "Generate title and description for this video "+
              `transcript:\n${transcript.text}`,
          },
        ],
        temperature: 0.7,
        max_tokens: 500,
      }),
    });

    if (!response.ok) {
      const error = await response.text();
      logger.error("❌ GPT-4 API error:", {
        status: response.status,
        statusText: response.statusText,
        error,
      });
      throw new Error(
        `GPT-4 API error: ${response.status} ${response.statusText} - ${error}`
      );
    }

    const result = await response.json();
    const metadata = JSON.parse(result.choices[0].message.content);

    logger.info("✅ Successfully generated video metadata:", {
      titleLength: metadata.title.length,
      descriptionLength: metadata.description.length,
    });

    return {
      title: metadata.title.trim(),
      description: metadata.description.trim(),
    };
  } catch (error) {
    logger.error("❌ Failed to generate video metadata:", {
      error: error instanceof Error ? error.message : "Unknown error",
      stack: error instanceof Error ? error.stack : undefined,
    });
    throw error;
  }
}
