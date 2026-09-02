#!/bin/bash
set -e

# FLAC + CUE splitter with real-time monitoring
# Supports nested directory structures and preserves metadata

INPUT_DIR="${INPUT_DIR:-/input}"
OUTPUT_DIR="${OUTPUT_DIR:-/output}"
LOG_FILE="${LOG_FILE:-/var/log/flac-splitter.log}"

# Setup logging
mkdir -p "$(dirname "$LOG_FILE")"
exec > >(tee -a "$LOG_FILE") 2>&1

log_info() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] INFO: $*"
}

log_error() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $*" >&2
}

log_info "FLAC Splitter started"
log_info "Input directory: $INPUT_DIR"
log_info "Output directory: $OUTPUT_DIR"

# Create directories if they don't exist
mkdir -p "$INPUT_DIR" "$OUTPUT_DIR"

# Function to check if directory was already processed
is_processed() {
    local dir="$1"
    [ -f "$dir/.processed" ]
}

# Function to mark directory as processed
mark_as_processed() {
    local dir="$1"
    touch "$dir/.processed"
}

# Function to check if all files in a pair are complete (no .!qB extensions)
is_complete() {
    local dir="$1"
    
    # Check if any .!qB files exist
    if find "$dir" -maxdepth 1 -name "*.!qB" 2>/dev/null | grep -q .; then
        return 1
    fi
    return 0
}

# Function to check if directory contains multiple FLAC files
has_multiple_flacs() {
    local dir="$1"
    local flac_count
    flac_count=$(find "$dir" -maxdepth 1 -name "*.flac" -o -name "*.FLAC" 2>/dev/null | wc -l)
    [ "$flac_count" -gt 1 ]
}

# Function to find FLAC files in a directory (single level)
find_flacs_single_level() {
    local dir="$1"
    find "$dir" -maxdepth 1 -type f \( -name "*.flac" -o -name "*.FLAC" \)
}

# Function to find CUE files in a directory (single level)
find_cues_single_level() {
    local dir="$1"
    find "$dir" -maxdepth 1 -type f \( -name "*.cue" -o -name "*.CUE" \)
}

# Function to check if a file is UTF-8 encoded
is_utf8() {
    local file_path="$1"
    iconv -f UTF-8 -t UTF-8 "$file_path" >/dev/null 2>&1
}

# Normalize CUE encoding to UTF-8 before feeding it to shnsplit
convert_cue_to_utf8() {
    local cue_file="$1"
    local tmp_file
    local charset
    local enc

    if is_utf8 "$cue_file"; then
        return 0
    fi

    charset=$(file -bi "$cue_file" | sed 's/.*charset=//')
    if [ -n "$charset" ] && [ "$charset" != "unknown-8bit" ] && [ "$charset" != "binary" ]; then
        tmp_file="$(mktemp "${cue_file}.XXXXXX")"
        if iconv -f "$charset" -t UTF-8 "$cue_file" > "$tmp_file" 2>/dev/null; then
            mv "$tmp_file" "$cue_file"
            log_info "Converted CUE file to UTF-8: $cue_file"
            return 0
        fi
        rm -f "$tmp_file"
    fi

    for enc in WINDOWS-1251 CP1251 ISO-8859-1 UTF-16LE UTF-16BE; do
        tmp_file="$(mktemp "${cue_file}.XXXXXX")"
        if iconv -f "$enc" -t UTF-8 "$cue_file" > "$tmp_file" 2>/dev/null; then
            mv "$tmp_file" "$cue_file"
            log_info "Converted CUE file to UTF-8 using $enc: $cue_file"
            return 0
        fi
        rm -f "$tmp_file"
    done

    log_error "Unable to convert CUE file to UTF-8: $cue_file"
    return 1
}

# Function to process a directory with split-ready FLAC+CUE
process_flac_cue_split() {
    local src_dir="$1"
    local rel_path="$2"
    local flac_file
    local cue_file
    local output_subdir
    
    # Find FLAC file
    flac_file=$(find_flacs_single_level "$src_dir" | head -1)
    if [ -z "$flac_file" ]; then
        return
    fi
    
    # Find CUE file
    cue_file=$(find_cues_single_level "$src_dir" | head -1)
    if [ -z "$cue_file" ]; then
        log_info "No CUE file found for $flac_file, skipping split"
        return
    fi
    
    # Check if files are complete
    if ! is_complete "$src_dir"; then
        log_info "Files still downloading in $src_dir, skipping"
        return
    fi

    if ! convert_cue_to_utf8 "$cue_file"; then
        log_error "Skipping split for $flac_file because the CUE file could not be converted to UTF-8"
        return
    fi
    
    output_subdir="$OUTPUT_DIR/$rel_path"
    mkdir -p "$output_subdir"
    
    log_info "Splitting: $flac_file with $(basename "$cue_file")"
    
    # Use shnsplit to split FLAC by CUE with metadata preservation
    # -f: input CUE sheet
    # -t %n-%t: output filename format (track number - track title)
    # -o flac: output FLAC format (inherits metadata)
    if shnsplit -f "$cue_file" -t "%n-%t" -o flac "$flac_file" 2>&1; then
        log_info "Successfully split $(basename "$flac_file")"
        
        # Move split files to output directory
        for split_file in split-track-*.flac; do
            if [ -f "$split_file" ]; then
                mv "$split_file" "$output_subdir/"
            fi
        done
        
        # Mark directory as processed
        mark_as_processed "$src_dir"
        
        log_info "Moved split tracks to $output_subdir"
    else
        log_error "Failed to split $(basename "$flac_file")"
    fi
}

# Function to scan and process directories recursively
scan_and_process() {
    local base_dir="$1"
    
    # Find all directories (up to 10 levels deep)
    find "$base_dir" -maxdepth 10 -type d | while read -r dir; do
        # Skip the base directory itself
        if [ "$dir" = "$base_dir" ]; then
            continue
        fi
        
        # Check if already processed
        if is_processed "$dir"; then
            continue
        fi
        
        # Check if directory contains FLAC files
        flac_count=$(find_flacs_single_level "$dir" | wc -l)
        if [ "$flac_count" -eq 0 ]; then
            continue
        fi
        
        # Calculate relative path for output structure
        rel_path="${dir#$base_dir/}"
        
        # Skip already split FLAC albums without copying them to the output directory
        if has_multiple_flacs "$dir"; then
            log_info "Directory $dir already contains multiple FLAC files; skipping"
            mark_as_processed "$dir"
            continue
        fi

        # Check for CUE file to split
        if find_cues_single_level "$dir" | grep -q .; then
            # Change to source directory for shnsplit (it outputs in current dir)
            cd "$dir" || continue
            process_flac_cue_split "$dir" "$rel_path"
            cd "$INPUT_DIR" || continue
        else
            log_info "Directory $dir has FLAC but no CUE file, skipping"
        fi
    done
}

# Initial scan on startup
log_info "Performing initial scan..."
scan_and_process "$INPUT_DIR"

# Main monitoring loop
log_info "Starting real-time monitoring of $INPUT_DIR..."
inotifywait -m -r -e close_write,moved_to \
    --format '%T %e %w%f' \
    --timefmt '%Y-%m-%d %H:%M:%S' \
    "$INPUT_DIR" 2>/dev/null | while read -r timestamp event filepath; do
    
    # Only process FLAC and CUE files
    case "$filepath" in
        *.flac|*.FLAC|*.cue|*.CUE)
            log_info "Detected change: $event on $filepath"
            
            # Get the directory containing the file
            dir=$(dirname "$filepath")
            
            # Skip if already processed
            if is_processed "$dir"; then
                continue
            fi
            
            # Wait a moment for all related files to be written
            sleep 2
            
            # Check if this directory is ready for processing
            if is_complete "$dir"; then
                rel_path="${dir#$INPUT_DIR/}"
                
                if has_multiple_flacs "$dir"; then
                    log_info "Directory $dir already contains multiple FLAC files; skipping"
                    mark_as_processed "$dir"
                    continue
                fi

                if find_cues_single_level "$dir" | grep -q .; then
                    cd "$dir" || continue
                    process_flac_cue_split "$dir" "$rel_path"
                    cd "$INPUT_DIR" || continue
                fi
            else
                log_info "Files still downloading in $dir, will retry"
            fi
            ;;
    esac
done
