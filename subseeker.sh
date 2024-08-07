#!/bin/bash
# subseeker is a command-line tool for subdomain enumeration. 
# It automates the process of gathering subdomains using popular tools such as shuffledns, subfinder, findomain, assetfinder, and amass. 
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

# Define the output file name
OUTPUT_FILE="$DOMAIN-subs.txt"

# Define temporaly file for Amass
#TMP=subs_tmp.txt

# Run Shuffledns and append output to the output file
rm /home/kali/resolvers.txt
wget -q "https://raw.githubusercontent.com/proabiral/Fresh-Resolvers/master/resolvers.txt" -P "/home/$USER/"
printf "Running Shuffledns..\n"
shuffledns -d "$DOMAIN" -w /usr/share/wordlists/seclists/Discovery/DNS/subdomains-top1million-110000.txt -r /home/$USER/resolvers.txt -silent >> "$OUTPUT_FILE"

# Run subfinder and append output to the output file
printf "Running Subfinder..\n"
subfinder -all -d "$DOMAIN" -silent >> "$OUTPUT_FILE"
#cat "$OUTPUT_FILE"

# Run findomain and append output to the output file
printf "Running Findomain..\n"
findomain -t "$DOMAIN" --quiet >> "$OUTPUT_FILE"

# Run assetfinder and append output to the output file
printf "Running Assetfinder..\n"
assetfinder --subs-only "$DOMAIN" >> "$OUTPUT_FILE"

# Run amass and append output to the output file
# Amass is currently a bit broken so very dirty workaround.
#printf "Running Amass..\n"
#amass enum -silent -timeout 5 -passive -d "$DOMAIN" -o "$TMP"
#cat "$TMP" | cut -d " " -f 1 | grep -i "$DOMAIN" >> "$OUTPUT_FILE"
#rm "$TMP"

#amass enum -silent -passive -d "$DOMAIN"
#amass db -names -d "$DOMAIN" >> "$OUTPUT_FILE"

# Remove duplicate entries from the output file
sort -u -o "$OUTPUT_FILE" "$OUTPUT_FILE"

# Filter out lines containing '@' or starting with '_' or ending with 'md'
grep -v '@' "$OUTPUT_FILE" | grep -v '^_' | grep -v '\.md' | grep -v '^*' > "$OUTPUT_FILE-filtered.txt"

# Replace the original output file with the filtered content
mv "$OUTPUT_FILE-filtered.txt" "$OUTPUT_FILE"

# Remove any leading whitespace or blank lines
sed -i '/^[[:space:]]*$/d' "$OUTPUT_FILE"

echo ""
echo "Subdomain enumeration on $DOMAIN completed. Results saved in $OUTPUT_FILE."