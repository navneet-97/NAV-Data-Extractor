#!/bin/bash

# AMFI NAV Data Extractor
# Extracts Scheme Name and Asset Value from AMFI NAV data
# Usage: ./amfi_extractor.sh [output_format]
# output_format: tsv (default) or json

set -e  # Exit on any error

# Configuration
AMFI_URL="https://www.amfiindia.com/spages/NAVAll.txt"
OUTPUT_FORMAT="${1:-tsv}"
TSV_OUTPUT="amfi_nav_data.tsv"
JSON_OUTPUT="amfi_nav_data.json"
TEMP_FILE="nav_data_temp.txt"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if required tools are available
check_dependencies() {
    print_status "Checking dependencies..."
    
    if ! command -v curl &> /dev/null; then
        print_error "curl is required but not installed."
        exit 1
    fi
    
    if ! command -v awk &> /dev/null; then
        print_error "awk is required but not installed."
        exit 1
    fi
    
    if [[ "$OUTPUT_FORMAT" == "json" ]] && ! command -v jq &> /dev/null; then
        print_warning "jq is not installed. Installing jq is recommended for JSON formatting."
        print_warning "Proceeding with basic JSON format..."
    fi
    
    print_status "Dependencies check completed."
}

# Function to download AMFI data
download_data() {
    print_status "Downloading AMFI NAV data from: $AMFI_URL"
    
    if curl -s -f -o "$TEMP_FILE" "$AMFI_URL"; then
        print_status "Data downloaded successfully."
        print_status "File size: $(wc -c < "$TEMP_FILE") bytes"
        print_status "Total lines: $(wc -l < "$TEMP_FILE") lines"
    else
        print_error "Failed to download data from AMFI website."
        exit 1
    fi
}

# Function to extract data to TSV format
extract_to_tsv() {
    print_status "Extracting data to TSV format..."
    
    # Create TSV header
    echo -e "Scheme_Name\tAsset_Value" > "$TSV_OUTPUT"
    
    # Process the data
    # AMFI NAV file format typically has:
    # Lines starting with scheme codes contain the actual data
    # Format: SchemeCode;ISIN;SchemeName;NetAssetValue;RepurchasePrice;SalePrice;Date
    
    awk -F';' '
    BEGIN {
        count = 0
    }
    # Skip empty lines and header lines
    /^$/ { next }
    /^Scheme Code/ { next }
    /^Open Ended Schemes/ { next }
    /^Close Ended Schemes/ { next }
    /^Interval Fund Schemes/ { next }
    
    # Process data lines (lines with semicolon-separated values)
    NF >= 4 && $1 ~ /^[0-9]+$/ {
        scheme_name = $3
        asset_value = $4
        
        # Clean up the data
        gsub(/^[ \t]+|[ \t]+$/, "", scheme_name)  # Trim whitespace
        gsub(/^[ \t]+|[ \t]+$/, "", asset_value)  # Trim whitespace
        
        # Skip if essential data is missing
        if (scheme_name == "" || asset_value == "") next
        
        # Replace tabs and newlines in scheme name
        gsub(/[\t\n\r]/, " ", scheme_name)
        
        print scheme_name "\t" asset_value
        count++
    }
    
    END {
        print "Total records processed: " count > "/dev/stderr"
    }
    ' "$TEMP_FILE" >> "$TSV_OUTPUT"
    
    local record_count=$(tail -n +2 "$TSV_OUTPUT" | wc -l)
    print_status "TSV extraction completed. Records extracted: $record_count"
    print_status "Output saved to: $TSV_OUTPUT"
}

# Function to extract data to JSON format
extract_to_json() {
    print_status "Extracting data to JSON format..."
    
    # Create JSON structure
    echo '[' > "$JSON_OUTPUT"
    
    # Process the data and convert to JSON
    awk -F';' '
    BEGIN {
        count = 0
        first_record = 1
    }
    # Skip empty lines and header lines
    /^$/ { next }
    /^Scheme Code/ { next }
    /^Open Ended Schemes/ { next }
    /^Close Ended Schemes/ { next }
    /^Interval Fund Schemes/ { next }
    
    # Process data lines
    NF >= 4 && $1 ~ /^[0-9]+$/ {
        scheme_name = $3
        asset_value = $4
        
        # Clean up the data
        gsub(/^[ \t]+|[ \t]+$/, "", scheme_name)
        gsub(/^[ \t]+|[ \t]+$/, "", asset_value)
        
        # Skip if essential data is missing
        if (scheme_name == "" || asset_value == "") next
        
        # Escape quotes in scheme name for JSON
        gsub(/"/, "\\\"", scheme_name)
        gsub(/[\n\r]/, " ", scheme_name)
        
        # Add comma before record (except first)
        if (!first_record) print ","
        first_record = 0
        
        printf "  {\n"
        printf "    \"scheme_name\": \"%s\",\n", scheme_name
        printf "    \"asset_value\": \"%s\"\n", asset_value
        printf "  }"
        
        count++
    }
    
    END {
        print ""
        print "Total records processed: " count > "/dev/stderr"
    }
    ' "$TEMP_FILE" >> "$JSON_OUTPUT"
    
    echo ']' >> "$JSON_OUTPUT"
    
    # Format JSON if jq is available
    if command -v jq &> /dev/null; then
        print_status "Formatting JSON with jq..."
        jq '.' "$JSON_OUTPUT" > "${JSON_OUTPUT}.tmp" && mv "${JSON_OUTPUT}.tmp" "$JSON_OUTPUT"
    fi
    
    local record_count=$(jq length "$JSON_OUTPUT" 2>/dev/null || echo "Unknown")
    print_status "JSON extraction completed. Records extracted: $record_count"
    print_status "Output saved to: $JSON_OUTPUT"
}

# Function to display sample data
show_sample() {
    if [[ "$OUTPUT_FORMAT" == "tsv" ]]; then
        print_status "Sample TSV data (first 5 records):"
        head -6 "$TSV_OUTPUT" | column -t -s $'\t'
    else
        print_status "Sample JSON data (first 2 records):"
        if command -v jq &> /dev/null; then
            jq '.[0:2]' "$JSON_OUTPUT"
        else
            head -20 "$JSON_OUTPUT"
        fi
    fi
}

# Function to cleanup temporary files
cleanup() {
    if [[ -f "$TEMP_FILE" ]]; then
        rm "$TEMP_FILE"
        print_status "Cleaned up temporary files."
    fi
}

# Main execution
main() {
    print_status "AMFI NAV Data Extractor Starting..."
    print_status "Output format: $OUTPUT_FORMAT"
    
    # Set up cleanup trap
    trap cleanup EXIT
    
    # Execute steps
    check_dependencies
    download_data
    
    case "$OUTPUT_FORMAT" in
        "tsv")
            extract_to_tsv
            show_sample
            ;;
        "json")
            extract_to_json
            show_sample
            ;;
        *)
            print_error "Invalid output format: $OUTPUT_FORMAT"
            print_error "Supported formats: tsv, json"
            exit 1
            ;;
    esac
    
    print_status "Extraction completed successfully!"
}

# Show usage if help is requested
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo "AMFI NAV Data Extractor"
    echo "Usage: $0 [output_format]"
    echo ""
    echo "Parameters:"
    echo "  output_format    Output format: 'tsv' (default) or 'json'"
    echo ""
    echo "Examples:"
    echo "  $0              # Extract to TSV format"
    echo "  $0 tsv          # Extract to TSV format"
    echo "  $0 json         # Extract to JSON format"
    echo ""
    echo "Output files:"
    echo "  amfi_nav_data.tsv   # TSV format output"
    echo "  amfi_nav_data.json  # JSON format output"
    exit 0
fi

# Run main function
main