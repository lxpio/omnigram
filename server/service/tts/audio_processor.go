package tts

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"

	"github.com/lxpio/omnigram/server/log"
)

// AudioProcessor handles post-processing of generated chapter audio files.
// It uses ffmpeg when available for LUFS normalization, silence trimming,
// and ID3 tag embedding. All operations are optional and gracefully degrade.
type AudioProcessor struct {
	ffmpegPath string // empty if ffmpeg is not available
}

// ChapterMeta holds metadata for ID3 tag embedding.
type ChapterMeta struct {
	BookTitle    string
	Author       string
	ChapterTitle string
	ChapterIndex int
	TotalChaps   int
	CoverPath    string // optional path to cover image
}

// NewAudioProcessor creates a processor, auto-detecting ffmpeg availability.
func NewAudioProcessor() *AudioProcessor {
	path, err := exec.LookPath("ffmpeg")
	if err != nil {
		log.I("TTS: ffmpeg not found, audio post-processing disabled")
		return &AudioProcessor{}
	}
	log.I("TTS: ffmpeg found at " + path + ", audio post-processing enabled")
	return &AudioProcessor{ffmpegPath: path}
}

// Available returns true if ffmpeg is available for post-processing.
func (p *AudioProcessor) Available() bool {
	return p.ffmpegPath != ""
}

// ProbeDurationMs returns the audio file's duration in milliseconds using
// ffprobe. Returns an error if ffprobe is not installed or the file cannot
// be read. ffprobe ships alongside ffmpeg in the alpine package so this is
// only unavailable on stripped installs.
func ProbeDurationMs(path string) (int64, error) {
	ffprobe, err := exec.LookPath("ffprobe")
	if err != nil {
		return 0, fmt.Errorf("ffprobe not found: %w", err)
	}
	out, err := exec.Command(ffprobe,
		"-v", "quiet",
		"-show_entries", "format=duration",
		"-of", "default=nw=1:nk=1",
		path,
	).Output()
	if err != nil {
		return 0, fmt.Errorf("ffprobe: %w", err)
	}
	s := strings.TrimSpace(string(out))
	if s == "" || s == "N/A" {
		return 0, fmt.Errorf("ffprobe returned empty duration")
	}
	var secs float64
	if _, err := fmt.Sscanf(s, "%f", &secs); err != nil {
		return 0, fmt.Errorf("parse duration %q: %w", s, err)
	}
	return int64(secs * 1000), nil
}

// Process applies all post-processing steps to a chapter audio file:
// 1. Trim leading/trailing silence
// 2. LUFS loudness normalization (target -16 LUFS)
// 3. Embed ID3v2 tags (title, artist, album, track number)
//
// The file is modified in-place. If ffmpeg is not available, this is a no-op.
func (p *AudioProcessor) Process(audioPath string, meta ChapterMeta) error {
	if !p.Available() {
		return nil
	}

	if _, err := os.Stat(audioPath); os.IsNotExist(err) {
		return fmt.Errorf("audio file not found: %s", audioPath)
	}

	tmpPath := audioPath + ".tmp.mp3"
	defer os.Remove(tmpPath)

	args := []string{
		"-i", audioPath,
		"-af", strings.Join([]string{
			// Trim leading silence (threshold -50dB, min 0.1s)
			"silenceremove=start_periods=1:start_threshold=-50dB:start_duration=0.05",
			// Trim trailing silence
			"areverse,silenceremove=start_periods=1:start_threshold=-50dB:start_duration=0.05,areverse",
			// LUFS loudness normalization (broadcast standard -16 LUFS)
			"loudnorm=I=-16:TP=-1.5:LRA=11",
		}, ","),
	}

	// Add ID3 metadata
	if meta.BookTitle != "" {
		args = append(args, "-metadata", "album="+meta.BookTitle)
	}
	if meta.Author != "" {
		args = append(args, "-metadata", "artist="+meta.Author)
	}
	if meta.ChapterTitle != "" {
		args = append(args, "-metadata", "title="+meta.ChapterTitle)
	}
	if meta.TotalChaps > 0 {
		args = append(args, "-metadata", fmt.Sprintf("track=%d/%d", meta.ChapterIndex+1, meta.TotalChaps))
	}

	// Embed cover art if available
	if meta.CoverPath != "" {
		if _, err := os.Stat(meta.CoverPath); err == nil {
			args = append(args,
				"-i", meta.CoverPath,
				"-map", "0:a", "-map", "1:v",
				"-c:v", "mjpeg",
				"-disposition:v:0", "attached_pic",
			)
		}
	}

	args = append(args,
		"-id3v2_version", "3",
		"-y", // overwrite output
		tmpPath,
	)

	cmd := exec.Command(p.ffmpegPath, args...)
	output, err := cmd.CombinedOutput()
	if err != nil {
		log.W(fmt.Sprintf("TTS post-processing failed for %s: %v\n%s",
			filepath.Base(audioPath), err, string(output)))
		return fmt.Errorf("ffmpeg post-processing: %w", err)
	}

	// Replace original with processed file
	if err := os.Rename(tmpPath, audioPath); err != nil {
		return fmt.Errorf("replace audio file: %w", err)
	}

	return nil
}
