# Creditcoin Docker

This project is a collection of scripts for easily setting up and managing Creditcoin nodes using Docker in an **Asahi Linux** ARM-based environment.

## Important! System Requirements

- **Asahi Linux** ARM-based Ubuntu
- Optimized for Apple Silicon Mac hardware (M1/M2)
- Docker and Docker Compose
- Minimum 16GB RAM (Recommended for Creditcoin nodes: 32GB)
- Sufficient storage space

## Key Features

- Creditcoin 3.0 node setup and management (`add3node.sh`)
- Creditcoin 2.0 legacy node setup and management (`add2node.sh`)
- Node cleanup and removal (`cleanup2.sh`, `cleanup3.sh`)
- Various options support: telemetry activation/deactivation, custom node names, pruning settings, etc.

## Installation

```bash
# Clone the repository
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

## Asahi Linux Considerations

This project is specially optimized for Asahi Linux installed on Apple Silicon (M1/M2) Macs. Asahi Linux leverages the ARM architecture natively, delivering optimal performance without x86 emulation.

While Asahi Linux may have limited support for some I/O devices (especially GPUs), this does not affect Creditcoin node operations.

## General Precautions

- Cleanup scripts delete all related containers, images, volumes, and directories. Backing up your data before use is recommended.
- Sufficient system resources are required for node operation.
- When telemetry is enabled, node information is made public to the Creditcoin network.

## License

This project is proprietary software with all rights reserved. Unauthorized copying, distribution, or modification is prohibited. For usage permissions, please contact the author.

© 2025 sigmo2nd. All Rights Reserved.

## Contributing

If you wish to contribute, you can participate in the following ways:

1. **Issue Reporting**: If you discover bugs or have improvement suggestions, please let us know through GitHub issues.
2. **Documentation**: You can contribute by improving documentation or adding usage examples.
3. **Testing**: Test in various environments and share your results.
4. **Optimization**: Script optimization and performance improvement suggestions are welcome.

All contributions are subject to review and approval by the administrator. Please contact the administrator before contributing.
