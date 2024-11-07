#!/bin/bash

# Function to detect OS and open required ports
enable_ports() {
    # List of required ports to open
    ports=(22 10001 20001 8545)

    # Check for Linux (Debian/Ubuntu or CentOS/RHEL)
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v ufw &> /dev/null; then
            echo "Detected Debian/Ubuntu. Enabling ports using ufw..."
            sudo ufw allow ssh
            for port in "${ports[@]}"; do
                sudo ufw allow "$port"
            done
            sudo ufw reload
            echo "Ports enabled successfully on Debian/Ubuntu."
        elif command -v firewall-cmd &> /dev/null; then
            echo "Detected CentOS/RHEL. Enabling ports using firewall-cmd..."
            sudo firewall-cmd --permanent --add-service=ssh
            for port in "${ports[@]}"; do
                sudo firewall-cmd --permanent --add-port="${port}/tcp"
            done
            sudo firewall-cmd --reload
            echo "Ports enabled successfully on CentOS/RHEL."
        else
            echo "Firewall management tool not detected. Please enable ports manually."
        fi
    # Check for macOS
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "Detected macOS. Enabling ports using pfctl (macOS firewall)..."
        echo "block in all" | sudo pfctl -ef -
        for port in "${ports[@]}"; do
            echo "pass in proto tcp from any to any port ${port}" | sudo pfctl -ef -
        done
        sudo pfctl -f /etc/pf.conf
        sudo pfctl -e
        echo "Ports enabled successfully on macOS."
    else
        echo "Unsupported OS. Please enable ports manually."
    fi
}

# Enable ports before starting nodes
enable_ports

# Check if node number is provided
if [ "$1" == "daemon" ] && [ -n "$3" ]; then
    node_num="$3"
    service_name="testnet_node${node_num}.service"

    # Shared ports and specific data directory per node
    libp2p_port="10001"
    grpc_port="20001"
    data_dir="node${node_num}"

    # Create the systemd service file for the testnet node
    echo "[Unit]
Description=Testnet Node ${node_num} Service
After=network.target

[Service]
ExecStart=$(pwd)/neth server --chain mainnet.json --libp2p 0.0.0.0:${libp2p_port} --nat 0.0.0.0 --jsonrpc 0.0.0.0:8545 --seal --data-dir=${data_dir} --grpc-address 0.0.0.0:${grpc_port}
Restart=on-failure
WorkingDirectory=$(pwd)
StandardOutput=syslog
StandardError=syslog

[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/$service_name > /dev/null

    # Reload systemd, start the service, enable it on boot, and display logs
    sudo systemctl daemon-reload
    sudo systemctl start $service_name
    sudo systemctl enable $service_name

    echo "Testnet Node ${node_num} service has been created and started as ${service_name}."
    echo "Displaying live logs for ${service_name} (Press Ctrl+C to exit):"

    # Display live logs for the service using journalctl
    sudo journalctl -fu $service_name
else
    echo "Usage: $0 daemon --node <node_number>"
fi
