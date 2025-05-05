# Creditcoin Docker

This project is a collection of scripts for easily setting up and managing Creditcoin nodes using Docker in an **Asahi Linux Ubuntu** environment on Apple Silicon hardware.

## Important! System Requirements

- **Asahi Linux Ubuntu** on Apple Silicon
- Optimized for Apple Silicon Mac hardware (M1/M2)
- Docker and Docker Compose
- Minimum 16GB RAM (Recommended for Creditcoin nodes: 32GB)
- Sufficient storage space

## Key Features

- Creditcoin 3.0 node setup and management (`add3node.sh`)
- Creditcoin 2.0 legacy node setup and management (`add2node.sh`)
- Node cleanup and removal (`cleanup2.sh`, `cleanup3.sh`)
- Various options support: telemetry activation/deactivation, custom node names, pruning settings, etc.

## Prerequisites

Before proceeding with the installation of this project, ensure you have:

1. Asahi Linux Ubuntu installed on your Apple Silicon Mac (M1/M2)
2. Docker and Docker Compose installed:
```bash
# Install required packages
sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

# Add Docker repository
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=arm64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Install Docker
sudo apt update
sudo apt install -y docker-ce docker-compose

# Start Docker service and enable autostart
sudo systemctl start docker
sudo systemctl enable docker

# Add current user to docker group (allows using docker commands without sudo)
sudo usermod -aG docker $USER
```

## Installation
```bash
git clone https://github.com/sigmo2nd/creditcoin-docker.git
cd creditcoin-docker
```

## Usage

### Creditcoin 3.0 Node Creation

```bash
./add3node.sh <node_number> [options]

# Options:
#   -v, --version      Node version (default: 3.32.0-mainnet)
#   -t, --telemetry    Enable telemetry (default: disabled)
#   -n, --name         Node name (default: 3Node<number>)
#   -p, --pruning      Pruning value setting (default: 0, no option added if 0)

# Usage examples:
./add3node.sh 0                      # Create node with default settings
./add3node.sh 1 -v 3.39.0-mainnet    # Create node with latest version
./add3node.sh 2 -t                   # Create node with telemetry enabled
./add3node.sh 3 -n ValidatorA        # Create node with specified name
./add3node.sh 4 -p 1000              # Create node with pruning value 1000
```

### Creditcoin 2.0 Legacy Node Creation

```bash
./add2node.sh <node_number> [options]

# Options:
#   -v, --version      Node version (default: 2.230.2-mainnet)
#   -t, --telemetry    Enable telemetry (default: disabled)
#   -n, --name         Node name (default: 3Node<number>)

# Usage examples:
./add2node.sh 0                        # Create node with default settings
./add2node.sh 1 -t -n ValidatorLegacy  # Create node with telemetry enabled and specified name
```

### Node Cleanup

```bash
# Creditcoin 2.0 legacy node cleanup
./cleanup2.sh

# Creditcoin 3.0 node cleanup
./cleanup3.sh
```

## Asahi Linux Ubuntu Considerations

This project is specially optimized for Asahi Linux Ubuntu installed on Apple Silicon (M1/M2) Macs. Asahi Linux Ubuntu leverages the ARM architecture natively, delivering optimal performance without x86 emulation.

While Asahi Linux Ubuntu may have limited support for some I/O devices (especially GPUs), this does not affect Creditcoin node operations.

## General Precautions

- Cleanup scripts delete all related containers, images, volumes, and directories. Backing up your data before use is recommended.
- Sufficient system resources are required for node operation.
- When telemetry is enabled, node information is made public to the Creditcoin network.

## License

This project is proprietary software with all rights reserved. Unauthorized copying, distribution, or modification is prohibited. For usage permissions, please contact the author.

© 2025 sigmo2nd. All Rights Reserved.

## Utility Scripts

This repository includes a `setup.sh` utility script that adds convenient shortcuts for managing Creditcoin Docker nodes. After running the script, the following commands become available:

### Docker Management Commands
- `cdcd` - Navigate to the Creditcoin Docker directory
- `dps` - List running containers
- `dpsa` - List all containers (including stopped ones)
- `dstats` - Show resource usage of containers
- `drestart [container]` - Restart a container
- `dstop [container]` - Stop a container
- `dstart [container]` - Start a container
- `dlog [container]` - Show container logs

### Creditcoin Node Commands
- `genkey [container]` - Generate node keys inside a container
- `rotatekey [number]` - Rotate session keys for 3.0 node (e.g., rotatekey 0)
- `rotatekeyLegacy [number]` - Rotate session keys for 2.0 node
- `payoutAll` - Execute payouts for all running 3.0 nodes
- `payoutAllLegacy` - Execute payouts for all running 2.0 nodes

### System Commands
- `journalcall [service]` - View service logs
- `jc [service]` - Shorthand for journalcall
- `cdsys` - Navigate to /etc/systemd/system
- `sysdr` - Run systemctl daemon-reload
- `sysre [service]` - Restart a service
- `sysen [service]` - Enable a service
- `sysst [service]` - Check service status
- `updateb` - Reload ~/.bashrc
- `editb` - Edit ~/.bashrc
- `nanocall [service]` - Edit service file
- `nn [service]` - Shorthand for nanocall

### Installation

To install these utilities:

```bash
./setup.sh
source ~/.bashrc
```

## Contributing

If you wish to contribute, you can participate in the following ways:

1. **Issue Reporting**: If you discover bugs or have improvement suggestions, please let us know through GitHub issues.
2. **Documentation**: You can contribute by improving documentation or adding usage examples.
3. **Testing**: Test in various environments and share your results.
4. **Optimization**: Script optimization and performance improvement suggestions are welcome.

All contributions are subject to review and approval by the administrator. Please contact the administrator before contributing.
