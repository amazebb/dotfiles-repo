#!/bin/bash

# Function to get the MAC address using ARP
get_mac_address() {
    arp -n "$1" | awk '{print $4}'
}

# Ask the user for the base IP address, start range, and end range with defaults
read -p "Enter the base IP address (default is 192.168.1): " base_ip
base_ip="${base_ip:-192.168.1}"

read -p "Enter the start of the IP range (default is 11): " start_range
start_range="${start_range:-11}"

read -p "Enter the end of the IP range (default is 254): " end_range
end_range="${end_range:-254}"

# Ask the user for the MAC address to match
read -p "Enter the MAC address to match (default is 3c:37:86:2c:93:71): " target_mac
target_mac="${target_mac:-3c:37:86:2c:93:71}"

# Function to process each IP address
process_ip() {
    local ip="${base_ip}.${1}"
    
    # Ping the current IP address with a timeout of less than 1 second
    if ping -c 1 -W 1 "$ip" > /dev/null 2>&1; then
        # Get the MAC address for the successfully pinged IP
        mac_address=$(get_mac_address "$ip")
        
        # Check if the MAC address matches the target MAC
        if [[ "$mac_address" == "$target_mac" ]]; then
            echo "Match found: IP $ip has MAC address $mac_address"
            exit 0
        fi
    fi
    #else
        # Handle the case where ping fails (e.g., No route to host)
        # echo "Ping to $ip failed."
    #fi
}

# Export the function so GNU Parallel can see it
export -f process_ip
export -f get_mac_address
export base_ip
export target_mac

# Generate the list of IPs and use GNU parallel to process them in parallel
seq "$start_range" "$end_range" | parallel -j+0 --bar 'process_ip {}'

echo "No matching MAC address found in the range."
exit 1

