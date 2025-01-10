#!/bin/bash

# Initialize variables
inputList=()
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

# Get required inputs
read -p "Enter destination directory (default: $(pwd)): " user_dir
destination_dir=${user_dir:-$destination_dir}
etherscan_api_key=$(get_non_empty_input "Enter Etherscan API key: ")
read -p "Enter chain ID (default: 1): " user_chain_id
chain_id=${user_chain_id:-$chain_id}

# Input loop for addresses
while true; do
    read -p "Enter an address (or press Enter to finish): " address
    if [ -z "$address" ]; then
        break
    fi
    inputList+=("$address")
done

# Check if the list is empty
if [ ${#inputList[@]} -eq 0 ]; then
    echo "No addresses were provided. Exiting."
    exit 1
fi

# Process each address
for address in "${inputList[@]}"; do
    cast etherscan-source -d "$destination_dir" -e "$etherscan_api_key" -c "$chain_id" "$address"
done

echo "All addresses have been processed."
