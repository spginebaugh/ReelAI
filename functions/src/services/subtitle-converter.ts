import * as logger from "firebase-functions/logger";

interface WhisperWord {
  word: string;
  start: number;
  end: number;
  confidence: number;
}

interface WhisperResponse {
  task: string;
  language: string;
  duration: number;
  text: string;
  words: WhisperWord[];
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

/**
 * Converts seconds to SRT/VTT timestamp format
 * @param {number} seconds - The time in seconds to convert
 * @param {boolean} useVTTFormat - which format to use
 * @return {string} Formatted timestamp string
 */
function formatTimestamp(seconds: number, useVTTFormat = false): string {
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
function groupWordsIntoSegments(words: WhisperWord[]): WhisperWord[] {
  const segments: WhisperWord[] = [];
  let currentSegment: (WhisperWord & {text?: string}) | null = null;

  const MAX_SEGMENT_LENGTH = 42; // Characters
  const MAX_SEGMENT_DURATION = 5; // Seconds
  const MIN_SEGMENT_DURATION = 1; // Seconds

  for (const word of words) {
    if (!currentSegment) {
      currentSegment = {...word, text: word.word};
      continue;
    }

    const wouldBeText = `${currentSegment.text} ${word.word}`;
    const duration = word.end - currentSegment.start;

    if (
      wouldBeText.length > MAX_SEGMENT_LENGTH ||
      duration > MAX_SEGMENT_DURATION ||
      (duration >= MIN_SEGMENT_DURATION && word.word.includes("."))
    ) {
      // Using optional chaining and nullish coalescing
      segments.push({
        ...currentSegment,
        word: currentSegment.text ?? currentSegment.word,
      });
      currentSegment = {...word, text: word.word};
    } else {
      currentSegment.text = wouldBeText;
      currentSegment.end = word.end;
    }
  }

  if (currentSegment) {
    segments.push({
      ...currentSegment,
      word: currentSegment.text ?? currentSegment.word,
    });
  }

  return segments;
}

/**
 * Converts OpenAI transcript JSON to SRT format
 * @param {WhisperResponse} transcript - The OpenAI Whisper transcript response
 * @return {string} Formatted SRT subtitle string
 */
export function convertJsonToSRT(transcript: WhisperResponse): string {
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

/**
 * Converts OpenAI transcript JSON to VTT format
 * @param {WhisperResponse} transcript - The OpenAI Whisper transcript response
 * @return {string} Formatted WebVTT subtitle string
 */
export function convertJsonToVTT(transcript: WhisperResponse): string {
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

/**
 * Converts SRT format to VTT format
 * @param {string} srt - The SRT formatted subtitle string
 * @return {string} Formatted WebVTT subtitle string
 */
export function convertSRTtoVTT(srt: string): string {
  const header = "WEBVTT\n\n";
  // Remove subtitle numbers and convert timestamp format
  const content = srt
    .replace(/^\d+$/gm, "") // Remove subtitle numbers
    .replace(/,/g, ".") // Convert timestamp format
    .trim();
  return header + content;
}

/**
 * Validates and formats subtitle files
 * @param {string} content - The subtitle content to validate
 * @param {"srt" | "vtt"} format - The format to validate against
 * @return {boolean} Whether the subtitle content is valid
 */
export function validateSubtitleFormat(
  content: string,
  format: "srt" | "vtt",
): boolean {
  try {
    if (format === "vtt" && !content.startsWith("WEBVTT")) {
      return false;
    }

    const lines = content.trim().split("\n");
    if (format === "srt") {
      // Basic SRT format validation
      return lines.some((line) =>
        /^\d{2}:\d{2}:\d{2},\d{3} --> \d{2}:\d{2}:\d{2},\d{3}$/.test(
          line.trim(),
        ),
      );
    } else {
      // Basic VTT format validation
      return lines.some((line) =>
        /^\d{2}:\d{2}:\d{2}\.\d{3} --> \d{2}:\d{2}:\d{2}\.\d{3}$/.test(
          line.trim(),
        ),
      );
    }
  } catch (error) {
    logger.error("Error validating subtitle format:", error);
    return false;
  }
}
