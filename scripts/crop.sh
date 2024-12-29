#!/bin/bash

# Check if ImageMagick is installed
if ! command -v convert &> /dev/null; then
    echo "Error: ImageMagick is not installed. Please install it first."
    echo "Ubuntu/Debian: sudo apt-get install imagemagick"
    echo "macOS: brew install imagemagick"
    exit 1
fi

# Function to print help message
print_help() {
    echo "Usage: $0 [options] <image_files...>"
    echo "Options:"
    echo "  -h, --help         Show this help message"
    echo "  -t, --top N        Status bar height in pixels (default: 120)"
    echo "  -b, --bottom N     Navigation bar height in pixels (default: 135)"
    echo "  -o, --output DIR   Output directory (default: cropped/)"
}

# Default values
STATUS_BAR_HEIGHT=120
NAV_BAR_HEIGHT=135
OUTPUT_DIR="cropped"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            print_help
            exit 0
            ;;
        -t|--top)
            STATUS_BAR_HEIGHT=$2
            shift 2
            ;;
        -b|--bottom)
            NAV_BAR_HEIGHT=$2
            shift 2
            ;;
        -o|--output)
            OUTPUT_DIR=$2
            shift 2
            ;;
        *)
            break
            ;;
    esac
done

# Check if any files were provided
if [ $# -eq 0 ]; then
    echo "Error: No input files provided"
    print_help
    exit 1
fi

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Process each image
for img in "$@"; do
    if [ ! -f "$img" ]; then
        echo "Warning: File '$img' not found, skipping..."
        continue
    fi
    
    # Get image dimensions
    dimensions=$(identify -format "%wx%h" "$img")
    width=$(echo $dimensions | cut -d'x' -f1)
    height=$(echo $dimensions | cut -d'x' -f2)
    
    # Calculate new height
    new_height=$((height - STATUS_BAR_HEIGHT - NAV_BAR_HEIGHT))
    
    # Generate output filename
    filename=$(basename "$img")
    output_path="$OUTPUT_DIR/$filename"
    
    # Crop the image (remove both top and bottom bars)
    convert "$img" -gravity North -chop 0x${STATUS_BAR_HEIGHT} \
                  -gravity South -chop 0x${NAV_BAR_HEIGHT} \
                  "$output_path"
    
    echo "Processed: $img -> $output_path"
done

echo "Done! Cropped images are saved in the '$OUTPUT_DIR' directory"