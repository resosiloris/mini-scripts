#!/bin/bash

# Get the directory of the script
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Initialize variables
destination_dir=$(pwd)
etherscan_api_key=""
chain_id="1"

# Function to get non-empty input
get_non_empty_input() {
    local prompt="$1"
    local input=""
    while [ -z "$input" ]; do
        read -p "$prompt" input
        if [ -z "$input" ]; then
            echo "This field cannot be empty. Please try again."
        fi
    done
    echo "$input"
}

# Check for .env file and read API key if present
env_file="$script_dir/.env"
if [ -f "$env_file" ]; then
    source "$env_file"
    etherscan_api_key=${ETHERSCAN_API_KEY:-$etherscan_api_key}
fi

# Get required inputs
read -p "Enter destination directory (default: $(pwd)): " user_dir
destination_dir=${user_dir:-$destination_dir}
if [ -z "$etherscan_api_key" ]; then
    etherscan_api_key=$(get_non_empty_input "Enter Etherscan API key: ")
fi
read -p "Enter chain ID (default: 1): " user_chain_id
chain_id=${user_chain_id:-$chain_id}

# Get input with potential addresses
echo "Enter text with addresses (Ctrl+D to finish):"
input=$(cat)

# Extract addresses using regex
inputList=($(echo "$input" | grep -oE '0x[a-fA-F0-9]+'))

# Check if the list is empty
if [ ${#inputList[@]} -eq 0 ]; then
    echo "No valid addresses were found. Exiting."
    exit 1
fi

# Print the number of addresses found
echo "Number of addresses found: ${#inputList[@]}"

# Process each address
total=${#inputList[@]}
for i in "${!inputList[@]}"; do
    address=${inputList[$i]}
    echo "Processing address $((i+1))/$total: $address"
    cast etherscan-source -d "$destination_dir" -e "$etherscan_api_key" -c "$chain_id" "$address"
    echo "Completed processing $address"
    echo "------------------------"
    # sleep 0.5
done

echo "All addresses have been processed."
