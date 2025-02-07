"use strict";
/**
 * Import function triggers from their respective submodules:
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */
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
exports.generateSubtitles = void 0;
const logger = __importStar(require("firebase-functions/logger"));
const admin = __importStar(require("firebase-admin"));
const https_1 = require("firebase-functions/v2/https");
const params_1 = require("firebase-functions/params");
const openai_1 = __importDefault(require("openai"));
const fs = __importStar(require("fs"));
const os = __importStar(require("os"));
const path = __importStar(require("path"));
const node_fetch_1 = __importDefault(require("node-fetch"));
// Initialize Firebase Admin
admin.initializeApp();
// Define secrets
const openaiApiKey = (0, params_1.defineSecret)("OPENAI_API_KEY");
// Constants for storage paths
const LANG = "english"; // Default language
// Start writing functions
// https://firebase.google.com/docs/functions/typescript
// export const helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
// Using v2 functions with correct auth setup
exports.generateSubtitles = (0, https_1.onCall)({
    enforceAppCheck: false,
    timeoutSeconds: 540,
    memory: "2GiB",
    region: "us-central1",
    secrets: [openaiApiKey],
}, async (request) => {
    var _a, _b;
    try {
        // Log detailed request information
        logger.info("🔍 Detailed request analysis:", {
            hasAuth: !!request.auth,
            authDetails: request.auth ? {
                uid: request.auth.uid,
                token: request.auth.token,
                hasAppCheckToken: !!((_a = request.auth.token) === null || _a === void 0 ? void 0 : _a.app_check),
            } : "No auth",
            appDetails: request.app ? {
                id: request.app.appId,
            } : "No app details",
            rawHeaders: (_b = request.rawRequest) === null || _b === void 0 ? void 0 : _b.headers,
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
            logger.error("User not authorized:", {
                requestUserId: request.auth.uid,
                videoUploaderId: videoData === null || videoData === void 0 ? void 0 : videoData.uploaderId,
            });
            throw new Error("Not authorized to generate subtitles for this video");
        }
        if (!(videoData === null || videoData === void 0 ? void 0 : videoData.audioUrl)) {
            throw new Error("Audio URL not found for video");
        }
        // Log the audio URL from Firestore
        logger.info("🎵 Audio file path from Firestore:", {
            audioUrl: videoData.audioUrl,
        });
        let tempFilePath;
        try {
            // Download the file directly using the Firestore URL
            const response = await (0, node_fetch_1.default)(videoData.audioUrl, { headers: { Accept: "audio/wav" } });
            // Log response details
            logger.info("📥 Download response details:", {
                status: response.status,
                contentType: response.headers.get("content-type"),
                contentLength: response.headers.get("content-length"),
            });
            if (!response.ok) {
                throw new Error(`Failed to download file: ${response.status} ${response.statusText}`);
            }
            const contentType = response.headers.get("content-type");
            if (!(contentType === null || contentType === void 0 ? void 0 : contentType.includes("audio/"))) {
                logger.warn("⚠️ Unexpected content type:", {
                    contentType,
                    expectedType: "audio/wav",
                });
            }
            tempFilePath = path.join(os.tmpdir(), `${videoId}.wav`);
            const fileStream = fs.createWriteStream(tempFilePath);
            await new Promise((resolve, reject) => {
                // Handle stream errors
                response.body.on("error", (error) => {
                    fileStream.destroy();
                    reject(error);
                });
                fileStream.on("error", (error) => {
                    response.body.unpipe();
                    reject(error);
                });
                // Only resolve when the file is fully written and closed
                fileStream.on("finish", () => {
                    fileStream.close();
                });
                fileStream.on("close", () => {
                    resolve();
                });
                // Pipe the response to the file
                response.body.pipe(fileStream);
            });
            // Verify the file exists and has content
            const stats = await fs.promises.stat(tempFilePath);
            if (stats.size === 0) {
                throw new Error("Downloaded file is empty");
            }
            // Log detailed file information
            logger.info("📁 Audio file details:", {
                path: tempFilePath,
                sizeBytes: stats.size,
                exists: await fs.promises
                    .access(tempFilePath)
                    .then(() => true)
                    .catch(() => false),
            });
            // Read first few bytes to check WAV header
            const fileHandle = await fs.promises.open(tempFilePath, "r");
            const buffer = Buffer.alloc(44); // WAV header is 44 bytes
            const { bytesRead } = await fileHandle.read(buffer, 0, 44, 0);
            await fileHandle.close();
            // Log WAV header details in chunks to avoid line length issues
            const headerInfo = {
                riffHeader: buffer.toString("ascii", 0, 4),
                waveHeader: buffer.toString("ascii", 8, 12),
                format: buffer.toString("ascii", 12, 16),
            };
            logger.info("🎵 WAV header check:", Object.assign(Object.assign({}, headerInfo), { headerBytes: buffer.toString("hex", 0, 44), bytesRead }));
            // Initialize OpenAI client
            const openai = new openai_1.default({
                apiKey: openaiApiKey.value(),
            });
            logger.info("📤 Sending file to OpenAI:", {
                filePath: tempFilePath,
                fileExists: await fs.promises
                    .access(tempFilePath)
                    .then(() => true)
                    .catch(() => false),
                fileSize: stats.size,
            });
            const transcription = await openai.audio.transcriptions.create({
                file: fs.createReadStream(tempFilePath),
                model: "whisper-1",
                response_format: "verbose_json",
                timestamp_granularities: ["word"],
            });
            // Store the transcription in Firebase Storage using new path structure
            const subtitlesPath = `${videoData.uploaderId}/` +
                `${videoId}/subtitles/subtitles_${LANG}.json`;
            const subtitlesFile = admin.storage().bucket().file(subtitlesPath);
            await subtitlesFile.save(JSON.stringify(transcription), {
                contentType: "application/json",
                metadata: {
                    contentType: "application/json",
                    language: LANG,
                },
            });
            // Update video document with subtitles URL
            await videoDoc.ref.update({
                subtitlesUrl: subtitlesPath,
                updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            });
            return { success: true, subtitlesPath };
        }
        finally {
            // Clean up temp file if it exists
            if (tempFilePath) {
                try {
                    await fs.promises.unlink(tempFilePath);
                }
                catch (cleanupError) {
                    logger.warn("Failed to clean up temp file:", cleanupError);
                }
            }
        }
    }
    catch (error) {
        logger.error("Error generating subtitles:", error);
        if (error instanceof Error) {
            throw new Error(`Failed to generate subtitles: ${error.message}`);
        }
        throw new Error("Failed to generate subtitles: Unknown error");
    }
});
//# sourceMappingURL=index.js.map