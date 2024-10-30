#!/bin/bash

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
ExecStart=$(pwd)/neth server --chain testnet.json --libp2p 0.0.0.0:${libp2p_port} --nat 0.0.0.0 --jsonrpc 0.0.0.0:8545 --seal --data-dir=${data_dir} --grpc-address 0.0.0.0:${grpc_port}
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
