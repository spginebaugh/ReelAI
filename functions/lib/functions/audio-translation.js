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
exports.generateTranslation = void 0;
const logger = __importStar(require("firebase-functions/logger"));
const admin = __importStar(require("firebase-admin"));
const fs = __importStar(require("fs"));
const os = __importStar(require("os"));
const path = __importStar(require("path"));
const https_1 = require("firebase-functions/v2/https");
const storage_1 = require("firebase-admin/storage");
const elevenlabs_1 = require("../services/elevenlabs");
const subtitle_converter_1 = require("../services/subtitle-converter");
// Using v2 functions with correct auth setup
exports.generateTranslation = (0, https_1.onCall)({
    enforceAppCheck: false,
    timeoutSeconds: 540,
    memory: "2GiB",
    region: "us-central1",
    secrets: [elevenlabs_1.elevenLabsApiKey],
}, async (request) => {
    var _a, _b;
    try {
        logger.info("🎬 Starting translation request:", {
            hasAuth: !!request.auth,
            userId: (_a = request.auth) === null || _a === void 0 ? void 0 : _a.uid,
            videoId: (_b = request.data) === null || _b === void 0 ? void 0 : _b.videoId,
        });
        // Ensure user is authenticated
        if (!request.auth) {
            throw new Error("User must be authenticated to translate audio");
        }
        const { videoId } = request.data;
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
        if ((videoData === null || videoData === void 0 ? void 0 : videoData.uploaderId) !== request.auth.uid) {
            throw new Error("Not authorized to translate this video");
        }
        const mp3StoragePath = [
            videoData.uploaderId,
            videoId,
            "audio",
            "audio_english.mp3",
        ].join("/");
        let tempMp3Path;
        try {
            // Download the existing MP3 file
            tempMp3Path = path.join(os.tmpdir(), `${videoId}.mp3`);
            await (0, storage_1.getStorage)().bucket().file(mp3StoragePath).download({
                destination: tempMp3Path,
            });
            logger.info("📥 Downloaded MP3 file:", {
                path: tempMp3Path,
                size: fs.statSync(tempMp3Path).size,
            });
            // Dub the audio to Portuguese
            logger.info("🎙️ Starting Portuguese dubbing process");
            const { audio: dubbedAudio, dubbingId, } = await (0, elevenlabs_1.dubAudio)(tempMp3Path, "pt");
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
            await (0, storage_1.getStorage)().bucket().file(dubbedStoragePath).save(dubbedAudio, {
                contentType: "audio/mp3",
            });
            // Get subtitles for the dubbed audio
            logger.info("📝 Getting Portuguese subtitles...");
            const { srt, vtt } = await (0, elevenlabs_1.getSubtitlesForDubbing)(dubbingId, "pt");
            // Validate subtitle formats
            if (!(0, subtitle_converter_1.validateSubtitleFormat)(srt, "srt")) {
                throw new Error("Generated SRT content failed validation");
            }
            if (!(0, subtitle_converter_1.validateSubtitleFormat)(vtt, "vtt")) {
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
                (0, storage_1.getStorage)()
                    .bucket()
                    .file(`${baseSubtitlesPath}.srt`)
                    .save(srt, {
                    contentType: "text/plain",
                    metadata: {
                        language: "pt",
                    },
                }),
                // VTT subtitles
                (0, storage_1.getStorage)()
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
        }
        finally {
            // Clean up temp files
            if (tempMp3Path) {
                try {
                    await fs.promises.unlink(tempMp3Path);
                    logger.info("✅ Cleaned up temp MP3 file:", { path: tempMp3Path });
                }
                catch (cleanupError) {
                    logger.warn("⚠️ Failed to clean up temp MP3 file:", {
                        path: tempMp3Path,
                        error: cleanupError,
                    });
                }
            }
        }
    }
    catch (error) {
        logger.error("❌ Error in audio translation:", {
            error: error instanceof Error ? error.message : "Unknown error",
            stack: error instanceof Error ? error.stack : undefined,
        });
        if (error instanceof Error) {
            throw new Error(`Failed to translate audio: ${error.message}`);
        }
        throw new Error("Failed to translate audio: Unknown error");
    }
});
//# sourceMappingURL=audio-translation.js.map