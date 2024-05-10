#!/bin/bash

# Directory where the .tgz files are stored
TGZ_DIR="/home/groups/STAT_DSCP/boss/tgz"
# Directory to store the extracted .fits files
OUTPUT_DIR="./extracted_fits"

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# List of fits files you need, specified manually from your top 10 list
fits_files=(
  "spec-5315-55978-0779.fits"
  "spec-6813-56419-0172.fits"
  "spec-4240-55455-0517.fits"
  "spec-6699-56411-0980.fits"
  "spec-7431-57162-0517.fits"
  "spec-5209-56002-0734.fits"
  "spec-6713-56402-0294.fits"
  "spec-4498-55615-0808.fits"
  "spec-5713-56686-0001.fits"
  "spec-6489-56329-0866.fits"
)

# Loop through each fits file
for fits_file in "${fits_files[@]}"; do
  # Extract the numeric ID from the file name to determine the corresponding .tgz file
  numeric_id=$(echo "$fits_file" | sed -E 's/spec-([0-9]+)-.*/\1/')
  archive_name="${numeric_id}.tgz"

  # Full path to the tgz archive
  archive_path="$TGZ_DIR/$archive_name"

  # Path to extract from within the archive, assuming directory structure
  directory_within_archive="${numeric_id}/$fits_file"

  # Check if the archive exists
  if [ -f "$archive_path" ]; then
    # Extract only the needed .fits file
    tar -xzf "$archive_path" -C "$OUTPUT_DIR" "$directory_within_archive"
  else
    echo "Archive $archive_path does not exist."
  fi
done

echo "Extraction complete. Files are in $OUTPUT_DIR."
