import os
import subprocess
import json
import argparse
import shutil
from multiprocessing import Pool, cpu_count
from collections import defaultdict

# --- CONFIGURATION ---
SOURCE_DIR = "/mnt/hgst-1tb/MEDIA/Movies"
TARGET_DIR = "/mnt/hgst-1tb/MEDIA/Heavy_Media"
CORRUPT_DIR = "/mnt/hgst-1tb/MEDIA/Corrupt_Media"
LOG_FILE = "heavy_media_report.txt"

# Criteria for "Heavy" files
MAX_RESOLUTION_HEIGHT = 1080
ALLOWED_VIDEO_CODECS = ["h264"]
MAX_BITRATE_MBPS = 15
IMAGE_SUBTITLE_FORMATS = ["pgs", "vobsub", "dvd_subtitle", "hdmv_pgs_subtitle"]
ALLOWED_AUDIO_CODECS = ["aac", "ac3", "mp3", "mp2", "vorbis", "opus"]
MAX_AUDIO_CHANNELS = 6
INCOMPATIBLE_EXTENSIONS = {'.avi', '.wmv'}

# Filename keywords that usually indicate "Heavy" files
HEAVY_KEYWORDS = ["4k", "2160p", "hevc", "x265", "10bit", "uhd", "av1", "hi10p"]

def get_video_metadata(file_path, deep=False):
    """Uses ffprobe to get metadata. 'deep' mode uses larger probes for problematic files."""
    try:
        # Standard light probe
        probesize = "2M" if deep else "1M"
        duration = "2M" if deep else "1M"
        
        cmd = [
            "ffprobe", 
            "-v", "error", 
            "-probesize", probesize,
            "-analyzeduration", duration,
            "-show_streams", 
            "-show_entries", "stream=width,height,codec_name,pix_fmt,bit_rate,channels,codec_type",
            "-show_entries", "format=bit_rate,size,format_name",
            "-print_format", "json", 
            file_path
        ]
        
        # Longer timeout for deep probes
        timeout = 60 if deep else 30
        result = subprocess.run(cmd, capture_output=True, text=True, check=True, timeout=timeout)
        return json.loads(result.stdout)
    except Exception:
        return None

def analyze_file(file_path):
    if not file_path:
        return None, None, "Invalid File Path"
        
    filename = os.path.basename(file_path).lower()
    ext = os.path.splitext(file_path)[1].lower()
    reasons = []

    # 1. Incompatible Containers (AVI/WMV)
    if ext in INCOMPATIBLE_EXTENSIONS:
        reasons.append(f"Incompatible Container ({ext})")

    # 2. Filename keyword check (as a hint)
    hint_reasons = [k for k in HEAVY_KEYWORDS if k in filename]

    # 3. Probing
    metadata = get_video_metadata(file_path, deep=False)
    if not metadata or not any(s.get('codec_type') == 'video' for s in metadata.get('streams', [])):
        metadata = get_video_metadata(file_path, deep=True)

    if not metadata:
        if hint_reasons:
            reasons.append(f"Likely Heavy (Filename hint: {', '.join(hint_reasons)})")
            return file_path, reasons, "Probing Failed (Using Hints)"
        return file_path, None, "Probing Error or Timeout (Corrupt?)"

    streams = metadata.get('streams', [])
    video_stream = next((s for s in streams if s.get('codec_type') == 'video'), None)
    audio_streams = [s for s in streams if s.get('codec_type') == 'audio']
    format_info = metadata.get('format', {}) or {}
    
    # Robustly get format name and file size
    try:
        file_size = int(format_info.get('size', 0))
    except (ValueError, TypeError):
        file_size = 0
        
    format_name = str(format_info.get('format_name', '')).lower()
    
    if not video_stream:
        if file_size > 50_000_000:
            return file_path, None, "No Video Stream Found (Possibly Corrupt)"
        return file_path, None, "No Video Stream Found (Audio/Small File)"

    # 4. Resolution
    height = 0
    try:
        height = int(video_stream.get('height', 0))
    except (ValueError, TypeError):
        pass
        
    if height > MAX_RESOLUTION_HEIGHT:
        reasons.append(f"High Resolution ({height}p)")

    # 5. Video Codec
    codec = video_stream.get('codec_name', '').lower()
    
    # AV1 is a special "CPU Killer"
    if codec == 'av1':
        reasons.append("CPU Killer (AV1 Codec - Zero hardware support)")
    elif codec not in ALLOWED_VIDEO_CODECS:
        reasons.append(f"Heavy Video Codec ({codec})")

    # 6. Bit Depth & "CPU Killer" checks
    pix_fmt = video_stream.get('pix_fmt', '')
    is_10bit = pix_fmt and ('10' in pix_fmt or 'hi10' in pix_fmt)
    
    if is_10bit:
        if codec == 'h264':
            reasons.append(f"CPU Killer (10-bit H.264 / Hi10P - No hardware decoder)")
        elif codec == 'hevc' and height > 1080:
            reasons.append(f"CPU Killer (10-bit HEVC @ 4K - Struggles on Pi 4)")
        else:
            reasons.append(f"10-bit Color ({pix_fmt})")

    # 7. Bitrate
    bitrate_str = video_stream.get('bit_rate') or format_info.get('bit_rate')
    if bitrate_str and str(bitrate_str) != "N/A":
        try:
            bitrate = int(bitrate_str) / 1_000_000
            if bitrate > MAX_BITRATE_MBPS:
                reasons.append(f"High Total Bitrate ({bitrate:.2f} Mbps)")
        except (ValueError, TypeError):
            pass

    # 8. Audio Compatibility (DTS, TrueHD, etc.)
    for a_stream in audio_streams:
        a_codec = a_stream.get('codec_name', '').lower()
        if a_codec and a_codec not in ALLOWED_AUDIO_CODECS:
            reasons.append(f"Incompatible Audio ({a_codec})")
        
        channels = a_stream.get('channels')
        if channels:
            try:
                if int(channels) > MAX_AUDIO_CHANNELS:
                    reasons.append(f"Too Many Audio Channels ({channels})")
            except (ValueError, TypeError):
                pass

    # 9. Subtitle Traps (PGS/VOBSUB)
    if 'matroska' in format_name or ext == '.mkv':
        try:
            # Check for image-based subtitles
            cmd = [
                "ffprobe", "-v", "error", 
                "-probesize", "1M", "-analyzeduration", "1M",
                "-select_streams", "s", 
                "-show_entries", "stream=codec_name", 
                "-print_format", "json", file_path
            ]
            sub_res = subprocess.run(cmd, capture_output=True, text=True, timeout=15)
            sub_data = json.loads(sub_res.stdout)
            for s in sub_data.get('streams', []):
                sub_codec = s.get('codec_name', '').lower()
                if any(fmt in sub_codec for fmt in IMAGE_SUBTITLE_FORMATS):
                    reasons.append(f"Subtitle Trap ({sub_codec} image subtitles)")
                    break
        except Exception:
            pass

    return file_path, reasons, None

def main():
    parser = argparse.ArgumentParser(description="Identify and move heavy/corrupt media files.")
    parser.add_argument("--dry-run", action="store_true", help="Report only, do not move files.")
    parser.add_argument("--move-heavy", action="store_true", help="Move heavy files to TARGET_DIR.")
    parser.add_argument("--move-corrupt", action="store_true", help="Move corrupt files to CORRUPT_DIR.")
    parser.add_argument("--move-all", action="store_true", help="Move both heavy and corrupt files.")
    parser.add_argument("--source", default=SOURCE_DIR, help="Source directory to scan.")
    parser.add_argument("--target", default=TARGET_DIR, help="Target directory for heavy files.")
    parser.add_argument("--corrupt", default=CORRUPT_DIR, help="Target directory for corrupt files.")
    parser.add_argument("--workers", type=int, default=cpu_count(), help="Number of parallel workers.")
    parser.add_argument("--limit", type=int, default=0, help="Limit the number of files to scan (0 for all).")
    args = parser.parse_args()

    # Determine move settings
    should_move_heavy = args.move_heavy or args.move_all
    should_move_corrupt = args.move_corrupt or args.move_all
    
    if args.dry_run:
        should_move_heavy = False
        should_move_corrupt = False

    if not os.path.exists(args.source):
        print(f"Source directory {args.source} does not exist.")
        return

    video_exts = {'.mp4', '.mkv', '.avi', '.m4v', '.mov', '.wmv'}
    all_files = []
    for root, dirs, files in os.walk(args.source):
        for file in files:
            if os.path.splitext(file)[1].lower() in video_exts:
                all_files.append(os.path.join(root, file))

    if args.limit > 0:
        all_files = all_files[:args.limit]
        print(f"Limiting scan to the first {args.limit} files.")

    print(f"Found {len(all_files)} video files. Analyzing using {args.workers} workers...")

    # Parallel processing
    with Pool(processes=args.workers) as pool:
        results = pool.map(analyze_file, all_files)

    report = []
    mode_str = "DRY RUN"
    if should_move_heavy and should_move_corrupt: mode_str = "LIVE MOVE ALL"
    elif should_move_heavy: mode_str = "LIVE MOVE HEAVY"
    elif should_move_corrupt: mode_str = "LIVE MOVE CORRUPT"
    
    report.append(f"--- MEDIA ANALYSIS REPORT ({mode_str}) ---\n")
    
    heavy_count = 0
    error_count = 0
    for path, reasons, error in results:
        if error:
            error_count += 1
            report.append(f"[ERROR] {path}: {error}")
            
            if should_move_corrupt:
                rel_path = os.path.relpath(path, args.source)
                dest_path = os.path.join(args.corrupt, rel_path)
                os.makedirs(os.path.dirname(dest_path), exist_ok=True)
                try:
                    shutil.move(path, dest_path)
                    report.append(f"        MOVED to Corrupt Folder: {dest_path}")
                except Exception as e:
                    report.append(f"        MOVE FAILED: {e}")
        elif reasons:
            heavy_count += 1
            reason_str = ", ".join(reasons)
            report.append(f"[HEAVY] {path}")
            report.append(f"        Reasons: {reason_str}")
            
            if should_move_heavy:
                rel_path = os.path.relpath(path, args.source)
                dest_path = os.path.join(args.target, rel_path)
                os.makedirs(os.path.dirname(dest_path), exist_ok=True)
                try:
                    shutil.move(path, dest_path)
                    report.append(f"        MOVED to: {dest_path}")
                except Exception as e:
                    report.append(f"        MOVE FAILED: {e}")

    report.append(f"\nSummary:")
    report.append(f"Total files scanned: {len(all_files)}")
    report.append(f"Heavy files identified: {heavy_count}")
    report.append(f"Corrupt/Error files identified: {error_count}")

    with open(LOG_FILE, "w") as f:
        f.write("\n".join(report))
    
    print(f"\nDone! Scanned {len(all_files)} files.")
    print(f"Found {heavy_count} heavy files and {error_count} corrupt files.")
    print(f"Full report in {LOG_FILE}")

if __name__ == "__main__":
    main()
