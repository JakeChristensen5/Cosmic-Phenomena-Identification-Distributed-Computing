#!/bin/bash

# Define the output file for the merged results and the file with the top 100 entries
output_file="merged.csv"
sorted_file="hw4best100.csv"

# Remove existing files if they exist to start fresh
[ -f "$output_file" ] && rm "$output_file"
[ -f "$sorted_file" ] && rm "$sorted_file"

# Echo the header to the output file
echo "distance,spectrumID,i" > $output_file

# Use a temporary file to store all data
temp_file="all_data_temp.csv"

# Append all CSV file data, skipping the header from each and replacing 'Inf' with a large number
for file in *.csv; do
    if [ "$file" == "$output_file" ] || [ "$file" == "$temp_file" ]; then
        continue
    fi
    # Append data to temporary file after processing with awk to replace 'Inf' values and skip zero distances
    tail -n +2 "$file" | awk 'BEGIN {FS=OFS=","} {if ($1=="Inf") $1="9999999999"; if ($1+0 != 0) print}' >> $temp_file
done

# Sort the temporary file by the distance and append sorted data to the final merged file, excluding the header
sort -t, -k1,1n $temp_file >> $output_file

# Extract the top 100 entries after merging
head -n 101 $output_file > $sorted_file

# Cleanup the temporary file
rm $temp_file

echo "Top 100 entries sorted by distance have been saved in $sorted_file"
