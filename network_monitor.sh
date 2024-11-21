# Comprehensive shell script that monitors 10 common networking issues on a Linux host.
# It will continually display status updates on networking problems such as IP configuration, DNS resolution, interface status, and more.
# The script can be run by both root and normal users (with appropriate permissions) and allows users to stop it when needed.


# What the script does:

# 1. Checks IP configuration: Displays IP addresses and settings.

# 2. Verifies DNS resolution: Pings an external domain.

# 3. Monitors network interfaces: Checks if interfaces are up.

# 4. Checks firewall status: Lists active firewall rules.

# 5. Monitors routing: Shows the routing table.

# 6. Checks physical network connectivity: Ensures the physical connection is up.

# 7. Monitors network congestion: Displays network stats for a specific interface.

# 8. Checks DHCP status: Displays DHCP lease info.

# 9. Checks MTU configuration: Displays the MTU value of the network interface.

# 10. Monitors service status: Checks if SSH, HTTP, and FTP services are running.




#!/bin/bash

# Check if the script is running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script can be run by root for full functionality."
    exit 1
fi

# Function to check IP configuration
check_ip_config() {
    echo "Checking IP Configuration:"
    ip addr show
    echo ""
}

# Function to check DNS resolution
check_dns_resolution() {
    echo "Checking DNS Resolution (pinging google.com):"
    if ping -c 1 google.com &> /dev/null; then
        echo "DNS is working fine."
    else
        echo "DNS resolution failed!"
    fi
    echo ""
}

# Function to check if network interface is up
check_network_interface() {
    echo "Checking Network Interface Status:"
    ip link show | grep -i "state UP"
    echo ""
}

# Function to check firewall rules
check_firewall_status() {
    echo "Checking Firewall Status:"
    ufw status || echo "Firewall is not configured with UFW."
    iptables -L || echo "No iptables rules configured."
    echo ""
}

# Function to check routing issues
check_routing() {
    echo "Checking Routing Table:"
    route -n
    echo ""
}

# Function to check physical connectivity
check_physical_connectivity() {
    echo "Checking Physical Network Connectivity (eth0):"
    if [ -f "/sys/class/net/eth0/carrier" ]; then
        carrier=$(cat /sys/class/net/eth0/carrier)
        if [ "$carrier" -eq 1 ]; then
            echo "Physical connection is up."
        else
            echo "No physical connection detected on eth0."
        fi
    else
        echo "Network interface eth0 not found."
    fi
    echo ""
}

# Function to check network congestion
check_network_congestion() {
    echo "Checking for Network Congestion (interface eth0):"
    netstat -i eth0
    echo ""
}

# Function to check DHCP status
check_dhcp_status() {
    echo "Checking DHCP Status:"
    dhclient -v
    echo ""
}

# Function to check MTU configuration
check_mtu() {
    echo "Checking MTU configuration on eth0:"
    ip link show eth0 | grep mtu
    echo ""
}

# Function to check for service misconfigurations (SSH, HTTP, FTP)
check_services() {
    echo "Checking Status of Network Services (SSH, HTTP, FTP):"
    systemctl is-active --quiet ssh && echo "SSH is active."
    systemctl is-active --quiet apache2 && echo "Apache2 HTTP server is active."
    systemctl is-active --quiet vsftpd && echo "FTP service is active."
    echo ""
}

# Display instructions
echo "Network Monitoring Script"
echo "Press [CTRL+C] to stop monitoring."
echo "------------------------------------"
echo ""

# Continuous monitoring loop
while true; do
    check_ip_config
    check_dns_resolution
    check_network_interface
    check_firewall_status
    check_routing
    check_physical_connectivity
    check_network_congestion
    check_dhcp_status
    check_mtu
    check_services
    sleep 10
done
