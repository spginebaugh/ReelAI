"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || function (mod) {
    if (mod && mod.__esModule) return mod;
    var result = {};
    if (mod != null) for (var k in mod) if (k !== "default" && Object.prototype.hasOwnProperty.call(mod, k)) __createBinding(result, mod, k);
    __setModuleDefault(result, mod);
    return result;
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.generateVideoMetadata = exports.generateTranscript = exports.openAiApiKey = void 0;
const logger = __importStar(require("firebase-functions/logger"));
const fs = __importStar(require("fs"));
const node_fetch_1 = __importDefault(require("node-fetch"));
const form_data_1 = __importDefault(require("form-data"));
const params_1 = require("firebase-functions/params");
// Define secrets
exports.openAiApiKey = (0, params_1.defineSecret)("OPENAI_API_KEY");
/**
 * Calls OpenAI Whisper API to generate transcript from audio file
 * @param {string} audioPath - Path to the input audio file
 * @return {Promise<WhisperResponse>} - Resolves with the transcript data
 */
async function generateTranscript(audioPath) {
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
        throw new Error(`Audio file size (${fileSize} bytes) ` +
            `exceeds OpenAI's limit of ${MAX_FILE_SIZE} bytes`);
    }
    let lastError = null;
    for (let attempt = 1; attempt <= MAX_RETRIES; attempt++) {
        try {
            const formData = new form_data_1.default();
            formData.append("file", fs.createReadStream(audioPath));
            formData.append("model", "whisper-1");
            formData.append("language", "en");
            formData.append("response_format", "verbose_json");
            formData.append("timestamp_granularities[]", "word");
            logger.info("📤 Sending request to OpenAI Whisper API...", {
                attempt,
                maxRetries: MAX_RETRIES,
            });
            const response = await (0, node_fetch_1.default)("https://api.openai.com/v1/audio/transcriptions", {
                method: "POST",
                headers: Object.assign({ "Authorization": `Bearer ${exports.openAiApiKey.value()}` }, formData.getHeaders()),
                body: formData,
            });
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
                    lastError = new Error("OpenAI Whisper API error: " +
                        `${response.status}${response.statusText} - ${error}`);
                    logger.info(`⏳ Retrying in ${RETRY_DELAY / 1000} seconds...`, {
                        attempt,
                        maxRetries: MAX_RETRIES,
                    });
                    await new Promise((resolve) => setTimeout(resolve, RETRY_DELAY));
                    continue;
                }
                throw new Error("OpenAI Whisper API error: " +
                    `${response.status}${response.statusText} - ${error}`);
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
        }
        catch (error) {
            lastError = error;
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
exports.generateTranscript = generateTranscript;
/**
 * Generates video title and description from transcript using GPT-4
 * @param {WhisperResponse} transcript - The transcript data from Whisper API
 * @return {Promise<VideoMetadata>} - Resolve w/ generated title and description
 */
async function generateVideoMetadata(transcript) {
    logger.info("🤖 Starting metadata generation with GPT-4...", {
        transcriptLength: transcript.text.length,
        language: transcript.language,
    });
    try {
        const response = await (0, node_fetch_1.default)("https://api.openai.com/v1/chat/completions", {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
                "Authorization": `Bearer ${exports.openAiApiKey.value()}`,
            },
            body: JSON.stringify({
                model: "gpt-4o-mini",
                messages: [
                    {
                        role: "system",
                        content: "You are a professional video metadata generator. " +
                            `Your task is to:
1. Generate a concise, engaging title (max 100 characters)
2. Create a clear, informative description (max 500 characters)
Both should accurately reflect the content while being SEO-friendly.
Respond in JSON format: {"title": "...", "description": "..."}`,
                    },
                    {
                        role: "user",
                        content: "Generate title and description for this video " +
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
            throw new Error(`GPT-4 API error: ${response.status} ${response.statusText} - ${error}`);
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
    }
    catch (error) {
        logger.error("❌ Failed to generate video metadata:", {
            error: error instanceof Error ? error.message : "Unknown error",
            stack: error instanceof Error ? error.stack : undefined,
        });
        throw error;
    }
}
exports.generateVideoMetadata = generateVideoMetadata;
//# sourceMappingURL=openai.js.map