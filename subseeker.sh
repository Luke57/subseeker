#!/bin/bash
# subseeker is a command-line tool for subdomain enumeration. 
# It automates the process of gathering subdomains using popular tools such as subfinder, findomain, assetfinder, and amass. 
# The tool allows you to specify a target domain and tool wil generate a subdomain txt file.
# author Luke57

# Check if the target domain is provided as a command-line argument
if [ $# -eq 0 ]; then
    echo "Please provide the target domain."
    echo "Usage: ./subseeker.sh <DOMAIN>"
    exit 1
fi

# Get the target domain from the command-line argument
DOMAIN=$1

# Define the output file names
OUTPUT_FILE="$DOMAIN-subs.txt"
OLD_OUTPUT_FILE="$DOMAIN-subs.old.txt"

# Remove the old output file if it exists
if [ -f "$OLD_OUTPUT_FILE" ]; then
    rm "$OLD_OUTPUT_FILE"
fi

# Run subfinder and append output to the output file
subfinder -d "$DOMAIN" -silent >> "$OUTPUT_FILE"

# Run findomain and append output to the output file
findomain -t "$DOMAIN" -u "$OUTPUT_FILE" --quiet >/dev/null

# Run assetfinder and append output to the output file
assetfinder --subs-only "$DOMAIN" >> "$OUTPUT_FILE"

# Run amass and append output to the output file
amass enum -silent -passive -d "$DOMAIN" -o "$OUTPUT_FILE"

# Remove duplicate entries from the output file
sort -u -o "$OUTPUT_FILE" "$OUTPUT_FILE"

echo ""
echo "Subdomain enumeration on $DOMAIN completed. Results saved in $OUTPUT_FILE."

