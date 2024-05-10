# Name: Jacob Christensen
# Email: Jrchristens2@wisc.edu

# Clear the environment
rm(list = ls())

# Load necessary libraries and install if they are not installed
if (!requireNamespace("FITSio", quietly = TRUE)) {
  install.packages("FITSio")
}
library(FITSio)

# Function definitions for standardization and shifted distance calculation

# Function to standardize a vector
standardize_vector <- function(vec) {
  (vec - mean(vec, na.rm = TRUE)) / sd(vec, na.rm = TRUE)
}

# Function to calculate correlation with shifts and return as a distance
calculate_shifted_distance <- function(vec1, vec2) {
  max_correlation <- -Inf
  best_shift <- NA
  len_diff <- length(vec2) - length(vec1)
  
  for (shift in 0:len_diff) {
    # Attempt to compute the correlation, handling cases with no complete pairs
    tryCatch({
      correlation <- cor(vec1, vec2[(1 + shift):(length(vec1) + shift)], use = "complete.obs")
      if (!is.na(correlation) && correlation > max_correlation) {
        max_correlation <- correlation
        best_shift <- shift
      }
    }, warning = function(w) {
      # Handle the case where no complete pairs exist
    }, error = function(e) {
      # Handle errors during correlation calculation
    })
  }
  
  # Return negative correlation as distance (higher correlation = smaller distance)
  return(list(distance = 1 - max_correlation, shift = best_shift))
}

# Read command-line arguments
args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 2) {
  stop("Usage: Rscript hw4.R <template spectrum> <data directory>", call. = FALSE)
}
template_spectrum_file <- args[1]
data_directory <- args[2]

# Read the template data and standardize
template_data <- readFrameFromFITS(template_spectrum_file)
template_flux_standardized <- standardize_vector(template_data$FLUX)

# Processing all .fits files in the directory
files <- list.files(path = data_directory, pattern = "\\.fits$", full.names = TRUE)
results <- data.frame(distance = numeric(), spectrumID = character(), i = integer())
for (file in files) {
  spectrum_data <- readFrameFromFITS(file)
  sdss_flux_standardized <- standardize_vector(spectrum_data$flux)
  shift_result <- calculate_shifted_distance(template_flux_standardized, sdss_flux_standardized)
  results <- rbind(results, data.frame(distance = shift_result$distance, spectrumID = basename(file), i = shift_result$shift))
}

# Sort the results by increasing distance
results <- results[order(results$distance), ]

# Output results to a CSV file
output_file_name <- paste0(data_directory, ".csv")
write.csv(results, output_file_name, row.names = FALSE, quote = TRUE)
