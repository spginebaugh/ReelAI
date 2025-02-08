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
Object.defineProperty(exports, "__esModule", { value: true });
exports.onAudioUploaded = void 0;
const logger = __importStar(require("firebase-functions/logger"));
const fs = __importStar(require("fs"));
const os = __importStar(require("os"));
const path = __importStar(require("path"));
const storage_1 = require("firebase-functions/v2/storage");
const storage_2 = require("firebase-admin/storage");
const ffmpeg_1 = require("../services/ffmpeg");
const openai_1 = require("../services/openai");
const subtitle_converter_1 = require("../services/subtitle-converter");
// Storage trigger for WAV to MP3 conversion
exports.onAudioUploaded = (0, storage_1.onObjectFinalized)({
    timeoutSeconds: 300,
    memory: "2GiB",
    region: "us-central1",
    secrets: [openai_1.openAiApiKey],
}, async (event) => {
    try {
        // Only process audio_english.wav files
        if (!event.data.name.endsWith("/audio/audio_english.wav")) {
            logger.info("Skipping non-target file:", {
                fileName: event.data.name,
            });
            return;
        }
        logger.info("🎵 Starting WAV to MP3 conversion for uploaded file:", {
            fileName: event.data.name,
            contentType: event.data.contentType,
            size: event.data.size,
        });
        const bucket = (0, storage_2.getStorage)().bucket(event.data.bucket);
        const tempDir = os.tmpdir();
        const tempInputPath = path.join(tempDir, "audio_english.wav");
        const tempOutputPath = path.join(tempDir, "audio_english.mp3");
        try {
            // Download the WAV file
            await bucket.file(event.data.name).download({
                destination: tempInputPath,
            });
            logger.info("📥 Downloaded WAV file:", {
                tempPath: tempInputPath,
                size: fs.statSync(tempInputPath).size,
            });
            // Convert WAV to MP3
            await (0, ffmpeg_1.convertWavToMp3)(tempInputPath, tempOutputPath);
            // Upload the MP3 file
            const mp3Path = event.data.name.replace(".wav", ".mp3");
            await bucket.upload(tempOutputPath, {
                destination: mp3Path,
                metadata: {
                    contentType: "audio/mp3",
                },
            });
            logger.info("✅ Successfully converted and uploaded MP3:", {
                originalPath: event.data.name,
                mp3Path: mp3Path,
            });
            // Generate transcript from the MP3 file
            logger.info("🎙️ Generating transcript from MP3...");
            const transcript = await (0, openai_1.generateTranscript)(tempOutputPath);
            // Generate all subtitle formats
            logger.info("📝 Converting transcript to different subtitle formats...");
            const srtContent = (0, subtitle_converter_1.convertJsonToSRT)(transcript);
            const vttContent = (0, subtitle_converter_1.convertJsonToVTT)(transcript);
            // Validate subtitle formats
            if (!(0, subtitle_converter_1.validateSubtitleFormat)(srtContent, "srt")) {
                throw new Error("Generated SRT content failed validation");
            }
            if (!(0, subtitle_converter_1.validateSubtitleFormat)(vttContent, "vtt")) {
                throw new Error("Generated VTT content failed validation");
            }
            // Calculate the base subtitles path
            const baseSubtitlesPath = event.data.name.replace("/audio/audio_english.wav", "/subtitles/subtitles_english");
            // Upload all subtitle formats
            const uploads = [
                // JSON subtitles
                bucket.file(`${baseSubtitlesPath}.json`).save(JSON.stringify(transcript, null, 2), {
                    contentType: "application/json",
                    metadata: {
                        language: transcript.language,
                        duration: transcript.duration.toString(),
                    },
                }),
                // SRT subtitles
                bucket.file(`${baseSubtitlesPath}.srt`).save(srtContent, {
                    contentType: "text/plain",
                    metadata: {
                        language: transcript.language,
                        duration: transcript.duration.toString(),
                    },
                }),
                // VTT subtitles
                bucket.file(`${baseSubtitlesPath}.vtt`).save(vttContent, {
                    contentType: "text/vtt",
                    metadata: {
                        language: transcript.language,
                        duration: transcript.duration.toString(),
                    },
                }),
            ];
            await Promise.all(uploads);
            logger.info("✅ Successfully generated and uploaded all subtitle formats:", {
                basePath: baseSubtitlesPath,
                language: transcript.language,
                duration: transcript.duration,
                wordCount: transcript.words.length,
            });
        }
        finally {
            // Clean up temp files
            for (const [label, path] of [
                ["WAV", tempInputPath],
                ["MP3", tempOutputPath],
            ]) {
                try {
                    if (fs.existsSync(path)) {
                        await fs.promises.unlink(path);
                        logger.info(`✅ Cleaned up temp ${label} file:`, { path });
                    }
                }
                catch (cleanupError) {
                    logger.warn(`⚠️ Failed to clean up temp ${label} file:`, {
                        path,
                        error: cleanupError,
                    });
                }
            }
        }
    }
    catch (error) {
        logger.error("❌ Error in WAV to MP3 conversion:", {
            error: error instanceof Error ? error.message : "Unknown error",
            stack: error instanceof Error ? error.stack : undefined,
            fileName: event.data.name,
        });
        throw error;
    }
});
//# sourceMappingURL=audio-conversion.js.map