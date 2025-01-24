#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Function to download and save the self-signed certificate
grab_certificate() {
    local cert_file="$1"
    local host="$2"

    if [[ ! -f "$cert_file" ]]; then
        echo "Fetching the certificate from $host..."
        echo -n | openssl s_client -connect "$host:443" -servername "$host" \
        | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > "$cert_file"

        if [[ $? -ne 0 ]]; then
            echo "Error: Failed to fetch the certificate from $host."
            return 1
        fi

        echo "Certificate saved to $cert_file."
    else
        echo "Certificate file $cert_file already exists."
    fi
}

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo "Footer template missing. Skipping..."
fi

