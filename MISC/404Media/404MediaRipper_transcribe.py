#!/usr/bin/env python3
import os
import glob
from faster_whisper import WhisperModel

def transcribe_folder():
    print("Loading Whisper model with CUDA...")

    # Force CUDA with optimal settings
    model = WhisperModel(
        "base", 
        device="cuda", 
        compute_type="float16",
        device_index=0
    )

    folder_path = "/mnt/c/backup/404Media"
    mp3_files = glob.glob(os.path.join(folder_path, "*.mp3"))

    print(f"Found {len(mp3_files)} MP3 files to process with CUDA")

    for i, mp3_file in enumerate(mp3_files, 1):
        filename = os.path.basename(mp3_file)
        print(f"\n[{i}/{len(mp3_files)}] Processing: {filename}")

        segments, info = model.transcribe(
            mp3_file,
            beam_size=5
        )

        output_path = mp3_file.replace('.mp3', '_transcript.txt')

        with open(output_path, 'w', encoding='utf-8') as f:
            f.write(f"File: {filename}\n")
            f.write(f"Language: {info.language}\n")
            f.write(f"Duration: {info.duration:.2f}s\n\n")

            for segment in segments:
                f.write(f"[{segment.start:.2f}s - {segment.end:.2f}s] {segment.text.strip()}\n")

        print(f"✓ Saved: {os.path.basename(output_path)}")

    print(f"\n🎉 CUDA transcription complete!")

if __name__ == "__main__":
    transcribe_folder()
