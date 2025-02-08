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
exports.validateSubtitleFormat = exports.convertSRTtoVTT = exports.convertJsonToVTT = exports.convertJsonToSRT = void 0;
const logger = __importStar(require("firebase-functions/logger"));
/**
 * Converts seconds to SRT/VTT timestamp format
 * @param {number} seconds - The time in seconds to convert
 * @param {boolean} useVTTFormat - which format to use
 * @return {string} Formatted timestamp string
 */
function formatTimestamp(seconds, useVTTFormat = false) {
    const hours = Math.floor(seconds / 3600);
    const minutes = Math.floor((seconds % 3600) / 60);
    const secs = Math.floor(seconds % 60);
    const ms = Math.floor((seconds % 1) * 1000);
    const separator = useVTTFormat ? "." : ",";
    return `${hours.toString().padStart(2, "0")}:${minutes
        .toString()
        .padStart(2, "0")}:${secs.toString().padStart(2, "0")}${separator}${ms
        .toString()
        .padStart(3, "0")}`;
}
/**
 * Groups words into subtitle segments based on length and timing constraints
 * @param {WhisperWord[]} words - Array of words with timing information
 * @return {WhisperWord[]} Array of grouped segments ready for formatting
 */
function groupWordsIntoSegments(words) {
    var _a, _b;
    const segments = [];
    let currentSegment = null;
    const MAX_SEGMENT_LENGTH = 42; // Characters
    const MAX_SEGMENT_DURATION = 5; // Seconds
    const MIN_SEGMENT_DURATION = 1; // Seconds
    for (const word of words) {
        if (!currentSegment) {
            currentSegment = Object.assign(Object.assign({}, word), { text: word.word });
            continue;
        }
        const wouldBeText = `${currentSegment.text} ${word.word}`;
        const duration = word.end - currentSegment.start;
        if (wouldBeText.length > MAX_SEGMENT_LENGTH ||
            duration > MAX_SEGMENT_DURATION ||
            (duration >= MIN_SEGMENT_DURATION && word.word.includes("."))) {
            // Using optional chaining and nullish coalescing
            segments.push(Object.assign(Object.assign({}, currentSegment), { word: (_a = currentSegment.text) !== null && _a !== void 0 ? _a : currentSegment.word }));
            currentSegment = Object.assign(Object.assign({}, word), { text: word.word });
        }
        else {
            currentSegment.text = wouldBeText;
            currentSegment.end = word.end;
        }
    }
    if (currentSegment) {
        segments.push(Object.assign(Object.assign({}, currentSegment), { word: (_b = currentSegment.text) !== null && _b !== void 0 ? _b : currentSegment.word }));
    }
    return segments;
}
/**
 * Converts OpenAI transcript JSON to SRT format
 * @param {WhisperResponse} transcript - The OpenAI Whisper transcript response
 * @return {string} Formatted SRT subtitle string
 */
function convertJsonToSRT(transcript) {
    const segments = groupWordsIntoSegments(transcript.words);
    return segments
        .map((segment, index) => {
        const number = index + 1;
        const start = formatTimestamp(segment.start);
        const end = formatTimestamp(segment.end);
        return `${number}\n${start} --> ${end}\n${segment.word}\n`;
    })
        .join("\n");
}
exports.convertJsonToSRT = convertJsonToSRT;
/**
 * Converts OpenAI transcript JSON to VTT format
 * @param {WhisperResponse} transcript - The OpenAI Whisper transcript response
 * @return {string} Formatted WebVTT subtitle string
 */
function convertJsonToVTT(transcript) {
    const segments = groupWordsIntoSegments(transcript.words);
    const header = "WEBVTT\n\n";
    const body = segments
        .map((segment) => {
        const start = formatTimestamp(segment.start, true);
        const end = formatTimestamp(segment.end, true);
        return `${start} --> ${end}\n${segment.word}\n`;
    })
        .join("\n");
    return header + body;
}
exports.convertJsonToVTT = convertJsonToVTT;
/**
 * Converts SRT format to VTT format
 * @param {string} srt - The SRT formatted subtitle string
 * @return {string} Formatted WebVTT subtitle string
 */
function convertSRTtoVTT(srt) {
    const header = "WEBVTT\n\n";
    // Remove subtitle numbers and convert timestamp format
    const content = srt
        .replace(/^\d+$/gm, "") // Remove subtitle numbers
        .replace(/,/g, ".") // Convert timestamp format
        .trim();
    return header + content;
}
exports.convertSRTtoVTT = convertSRTtoVTT;
/**
 * Validates and formats subtitle files
 * @param {string} content - The subtitle content to validate
 * @param {"srt" | "vtt"} format - The format to validate against
 * @return {boolean} Whether the subtitle content is valid
 */
function validateSubtitleFormat(content, format) {
    try {
        if (format === "vtt" && !content.startsWith("WEBVTT")) {
            return false;
        }
        const lines = content.trim().split("\n");
        if (format === "srt") {
            // Basic SRT format validation
            return lines.some((line) => /^\d{2}:\d{2}:\d{2},\d{3} --> \d{2}:\d{2}:\d{2},\d{3}$/.test(line.trim()));
        }
        else {
            // Basic VTT format validation
            return lines.some((line) => /^\d{2}:\d{2}:\d{2}\.\d{3} --> \d{2}:\d{2}:\d{2}\.\d{3}$/.test(line.trim()));
        }
    }
    catch (error) {
        logger.error("Error validating subtitle format:", error);
        return false;
    }
}
exports.validateSubtitleFormat = validateSubtitleFormat;
//# sourceMappingURL=subtitle-converter.js.map