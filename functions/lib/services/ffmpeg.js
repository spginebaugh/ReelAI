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
exports.convertWavToMp3 = void 0;
const logger = __importStar(require("firebase-functions/logger"));
const fs = __importStar(require("fs"));
const fluent_ffmpeg_1 = __importDefault(require("fluent-ffmpeg"));
const ffmpegInstaller = __importStar(require("@ffmpeg-installer/ffmpeg"));
// Set up FFmpeg path
fluent_ffmpeg_1.default.setFfmpegPath(ffmpegInstaller.path);
/**
 * Converts a WAV audio file to MP3 format using FFmpeg
 * @param {string} inputPath - Path to the input WAV file
 * @param {string} outputPath - Path where the output MP3 file will be saved
 * @return {Promise<void>} - Resolves when conversion is complete
 */
async function convertWavToMp3(inputPath, outputPath) {
    logger.info("🎵 Starting WAV to MP3 conversion:", {
        inputPath,
        outputPath,
        inputExists: await fs.promises.access(inputPath)
            .then(() => true)
            .catch(() => false),
    });
    return new Promise((resolve, reject) => {
        (0, fluent_ffmpeg_1.default)()
            .input(inputPath)
            .toFormat("mp3")
            .on("error", (err) => {
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
exports.convertWavToMp3 = convertWavToMp3;
//# sourceMappingURL=ffmpeg.js.map