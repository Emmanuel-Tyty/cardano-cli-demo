# Setup Guide 🛠️

This guide will get you ready for the Cardano CLI demo session.

## Prerequisites Check ✅

Before starting, make sure you have:

```bash
# Check Docker is installed
docker --version

# Check Docker is running
docker ps

# Check you have enough disk space (~20GB needed)
df -h

# Check Git is available
git --version
```

All commands should work without errors.

## Quick Setup (Recommended)

### 1. Clone Repositories
```bash
# Clone this demo repository
git clone https://github.com/your-username/cardano-cli-demo.git
cd cardano-cli-demo

# Clone the official Cardano node (in a sibling directory)
cd ..
git clone https://github.com/IntersectMBO/cardano-node.git
cd cardano-cli-demo
```

### 2. Start the Cardano Node
```bash
# Navigate to cardano-node
cd ../cardano-node

# Set environment for preview testnet
export NETWORK=preview
export CARDANO_NODE_VERSION=latest

# Start the node (this will take a few minutes to download)
docker-compose up -d

# Check it's running
docker-compose ps
```

### 3. Setup Demo Environment
```bash
# Return to demo directory
cd ../cardano-cli-demo

# Create directories for our files
mkdir keys transactions

# Make the CLI helper script executable
chmod +x cli.sh

# Test connection to node
./cli.sh query tip --testnet-magic 2
```

If the last command shows network information (block, epoch, sync progress), you're ready! 🎉

## Alternative Setup (If Above Doesn't Work)

### Use Included Docker Compose
```bash
# Use the simpler included setup
docker-compose up -d

# Wait a moment, then test
docker-compose ps
./cli.sh query tip --testnet-magic 2
```

## Verification

Your setup is correct when:

1. **Docker containers running**: `docker-compose ps` shows cardano-node running
2. **CLI working**: `./cli.sh query tip --testnet-magic 2` returns network data
3. **Directories created**: `keys/` and `transactions/` folders exist
4. **VS Code ready**: You can open this directory in your code editor

## Common Issues & Fixes

### Docker Issues
```bash
# If Docker isn't running
# Start Docker Desktop application

# If port conflicts
docker-compose down
lsof -i :3001  # Check what's using the port
# Kill the process or change ports
```

### Disk Space Issues
```bash
# Check available space
df -h

# Clean Docker if needed
docker system prune -a
```

### Node Sync Issues
```bash
# Check sync progress
./cli.sh query tip --testnet-magic 2

# Check logs if not syncing
cd ../cardano-node
docker-compose logs -f cardano-node
```

The node will show increasing sync progress (0.01 → 0.10 → 0.50 → 1.00). You can follow along even while it's syncing, but transactions need >90% sync.

### CLI Helper Script Issues
```bash
# If ./cli.sh doesn't work, use full commands:
docker-compose -f ../cardano-node/docker-compose.yml exec \
  -e CARDANO_NODE_SOCKET_PATH=/ipc/node.socket \
  cardano-node cardano-cli query tip --testnet-magic 2
```

## What Happens During Sync?

The Cardano node will download and verify the blockchain. This shows as:
- **0-10%**: Initial connection and headers
- **10-50%**: Downloading blocks  
- **50-90%**: Verifying transactions
- **90-100%**: Caught up with network

You'll see progress in the logs:
```bash
cd ../cardano-node
docker-compose logs -f cardano-node | grep -i sync
```

## Ready for Demo! 

Once setup is complete:

1. **Keep Docker running** throughout the session
2. **Open VS Code** in this directory to view files we create
3. **Have the testnet faucet ready**: https://docs.cardano.org/cardano-testnets/tools/faucet/
4. **Follow along** with the [Demo Commands](./demo-commands.md)
