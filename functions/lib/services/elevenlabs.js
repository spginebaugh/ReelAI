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
exports.generateTranscript = exports.dubAudio = exports.elevenLabsApiKey = void 0;
const logger = __importStar(require("firebase-functions/logger"));
const fs = __importStar(require("fs"));
const node_fetch_1 = __importDefault(require("node-fetch"));
const form_data_1 = __importDefault(require("form-data"));
const params_1 = require("firebase-functions/params");
// Define secrets
exports.elevenLabsApiKey = (0, params_1.defineSecret)("ELEVENLABS_API_KEY");
/**
 * Calls ElevenLabs API to dub an audio file
 * @param {string} audioPath - Path to the input audio file
 * @param {string} targetLang - Target language code
 * @return {Promise<Buffer>} - Resolves with the dubbed audio data
 */
async function dubAudio(audioPath, targetLang) {
    logger.info("🎙️ Starting audio dubbing process:", {
        audioPath,
        targetLang,
        audioExists: await fs.promises.access(audioPath)
            .then(() => true)
            .catch(() => false),
        audioSize: fs.statSync(audioPath).size,
    });
    const formData = new form_data_1.default();
    formData.append("file", fs.createReadStream(audioPath));
    formData.append("target_lang", targetLang);
    formData.append("source_lang", "en");
    formData.append("num_speakers", "0");
    logger.info("📤 Sending request to ElevenLabs API...");
    const response = await (0, node_fetch_1.default)("https://api.elevenlabs.io/v1/dubbing", {
        method: "POST",
        headers: Object.assign({ "xi-api-key": exports.elevenLabsApiKey.value() }, formData.getHeaders()),
        body: formData,
    });
    if (!response.ok) {
        const error = await response.text();
        logger.error("❌ ElevenLabs API error:", {
            status: response.status,
            statusText: response.statusText,
            error,
        });
        throw new Error(`ElevenLabs API error: ${response.status} ` +
            `${response.statusText} - ${error}`);
    }
    const result = await response.json();
    logger.info("✅ Successfully initiated dubbing:", {
        dubbingId: result.dubbing_id,
        expectedDuration: result.expected_duration_sec,
    });
    // Wait for dubbing to complete and get the result
    const dubbingId = result.dubbing_id;
    let isDubbed = false;
    let audioBuffer = null;
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
        const statusResponse = await (0, node_fetch_1.default)(`https://api.elevenlabs.io/v1/dubbing/${dubbingId}`, {
            headers: {
                "xi-api-key": exports.elevenLabsApiKey.value(),
            },
        });
        if (!statusResponse.ok) {
            const error = await statusResponse.text();
            logger.error("❌ Error checking dubbing status:", {
                dubbingId,
                status: statusResponse.status,
                error,
                attempts,
            });
            throw new Error(`Error checking dubbing status: ${statusResponse.status} - ${error}`);
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
            const audioResponse = await (0, node_fetch_1.default)(`https://api.elevenlabs.io/v1/dubbing/${dubbingId}/audio/${targetLang}`, {
                headers: {
                    "xi-api-key": exports.elevenLabsApiKey.value(),
                },
            });
            if (!audioResponse.ok) {
                const error = await audioResponse.text();
                logger.error("❌ Error getting dubbed audio:", {
                    dubbingId,
                    status: audioResponse.status,
                    error,
                    attempts,
                });
                throw new Error(`Error getting dubbed audio: ${audioResponse.status} - ${error}`);
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
        }
        else if (status.status === "error") {
            logger.error("❌ Dubbing failed:", {
                dubbingId,
                status,
                attempts,
            });
            throw new Error(`Dubbing failed: ${status.error || "Unknown error"}`);
        }
        else {
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
exports.dubAudio = dubAudio;
/**
 * Calls ElevenLabs API to generate transcript from audio file
 * @param {string} audioPath - Path to the input audio file
 * @param {string} [language] - Optional ISO-639-1 or ISO-639-3 language code
 * @return {Promise<TranscriptResponse>} - Resolves with the transcript data
 */
async function generateTranscript(audioPath, language) {
    logger.info("🎙️ Starting speech-to-text transcription:", {
        audioPath,
        language,
        audioExists: await fs.promises.access(audioPath)
            .then(() => true)
            .catch(() => false),
        audioSize: fs.statSync(audioPath).size,
    });
    const formData = new form_data_1.default();
    formData.append("file", fs.createReadStream(audioPath));
    formData.append("model_id", "scribe_v1");
    if (language) {
        formData.append("language_code", language);
    }
    logger.info("📤 Sending request to ElevenLabs speech-to-text API...");
    const response = await (0, node_fetch_1.default)("https://api.elevenlabs.io/v1/speech-to-text", {
        method: "POST",
        headers: Object.assign({ "xi-api-key": exports.elevenLabsApiKey.value() }, formData.getHeaders()),
        body: formData,
    });
    if (!response.ok) {
        const error = await response.text();
        logger.error("❌ ElevenLabs speech-to-text API error:", {
            status: response.status,
            statusText: response.statusText,
            error,
        });
        throw new Error(`ElevenLabs speech-to-text API error: ${response.status} ` +
            `${response.statusText} - ${error}`);
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
exports.generateTranscript = generateTranscript;
//# sourceMappingURL=elevenlabs.js.map