#!/bin/bash

# Load environment variables from .env file
if [ ! -f ".env" ]; then
    echo ".env file not found."
    exit 1
fi

# Export all the variables present in the .env file
export $(grep -v '^#' .env | xargs)

# Ensure SUBDOMAINS variable is set
if [ -z "$SUBDOMAINS" ]; then
    echo "SUBDOMAINS variable not set in .env file."
    exit 1
fi

# Ensure Certbot is installed
if ! command -v certbot &> /dev/null
then
    echo "Certbot could not be found, installing..."
    sudo apt-get update
    sudo apt-get install -y certbot
fi

# Read subdomains from the SUBDOMAINS variable and generate certificates
IFS=',' read -ra ADDR <<< "$SUBDOMAINS"
for subdomain in "${ADDR[@]}"; do
    subdomain=$(echo $subdomain | xargs)  # Trim spaces
    echo "Simulating certificate generation for $subdomain"
    sudo certbot certonly --standalone -d "$subdomain" --agree-tos --non-interactive --email your-email@example.com --dry-run
    if [ $? -ne 0 ]; then
        echo "Failed to simulate certificate generation for $subdomain"
    else
        echo "Successfully simulated certificate generation for $subdomain"
    fi
done

echo "Certificate simulation process completed."
