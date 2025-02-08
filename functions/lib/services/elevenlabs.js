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
exports.getSubtitlesForDubbing = exports.getDubbedTranscript = exports.dubAudio = exports.elevenLabsApiKey = void 0;
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
 * @return {Promise<{audio: Buffer, dubbingId: string}>} - Audio data and ID
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
        throw new Error("ElevenLabs API error: " +
            `${response.status} ${response.statusText} - ${error}`);
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
        const status = await getDubbingStatus(dubbingId);
        logger.info("📊 Dubbing status:", {
            dubbingId,
            status: status.status,
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
                throw new Error("Error getting dubbed audio: " +
                    `${audioResponse.status} - ${error}`);
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
    return {
        audio: audioBuffer,
        dubbingId,
    };
}
exports.dubAudio = dubAudio;
/**
 * Gets the current status of a dubbing job
 * @param {string} dubbingId - The ID of the dubbing job to check
 * @return {Promise<DubbingStatus>} - Resolves with the current status
 */
async function getDubbingStatus(dubbingId) {
    const response = await (0, node_fetch_1.default)(`https://api.elevenlabs.io/v1/dubbing/${dubbingId}`, {
        headers: {
            "xi-api-key": exports.elevenLabsApiKey.value(),
        },
    });
    if (!response.ok) {
        const error = await response.text();
        throw new Error("Error checking dubbing status: " +
            `${response.status} - ${error}`);
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
async function getDubbedTranscript(dubbingId, languageCode, format = "srt") {
    const response = await (0, node_fetch_1.default)(`https://api.elevenlabs.io/v1/dubbing/${dubbingId}/transcript/${languageCode}?format_type=${format}`, {
        headers: {
            "xi-api-key": exports.elevenLabsApiKey.value(),
        },
    });
    if (!response.ok) {
        const error = await response.text();
        throw new Error("Error getting dubbed transcript: " +
            `${response.status} - ${error}`);
    }
    return response.text();
}
exports.getDubbedTranscript = getDubbedTranscript;
/**
 * Gets both SRT and VTT subtitles for a dubbed audio
 * @param {string} dubbingId - The ID of the dubbing job
 * @param {string} languageCode - The language code (e.g., "pt")
 * @return {Promise<{srt: string, vtt: string}>} - both subtitle formats
 */
async function getSubtitlesForDubbing(dubbingId, languageCode) {
    logger.info("📝 Getting subtitles for dubbing:", {
        dubbingId,
        languageCode,
    });
    const [srt, vtt] = await Promise.all([
        getDubbedTranscript(dubbingId, languageCode, "srt"),
        getDubbedTranscript(dubbingId, languageCode, "webvtt"),
    ]);
    return { srt, vtt };
}
exports.getSubtitlesForDubbing = getSubtitlesForDubbing;
//# sourceMappingURL=elevenlabs.js.map