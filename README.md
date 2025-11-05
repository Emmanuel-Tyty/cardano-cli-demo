# Cardano CLI Demo 🚀

Welcome to the Cardano CLI hands-on demo! This repository contains everything you need to follow along with creating wallets, generating addresses, and sending transactions using the Cardano CLI.

## 📋 Prerequisites

- **Docker** installed and running
- **Git** for cloning this repository  
- **VS Code** or text editor for viewing files
- **Terminal** access
- ~20GB free disk space for blockchain data

## 🚀 Quick Start

### 1. Clone This Repository
```bash
git clone https://github.com/your-username/cardano-cli-demo.git
cd cardano-cli-demo
```

### 2. Setup Node (Two Options)

#### Option A: Use Intersect Cardano Node (Recommended)
```bash
# Clone the official node repository
git clone https://github.com/IntersectMBO/cardano-node.git
cd cardano-node

# Start preview testnet
export NETWORK=preview
export CARDANO_NODE_VERSION=latest
docker-compose up -d

cd ../cardano-cli-demo
```

#### Option B: Use Provided Docker Compose
```bash
# Use the included docker-compose.yml
docker-compose up -d
```

### 3. Verify Setup
```bash
# Check node is running
docker-compose ps

# Create demo workspace
mkdir keys transactions
```

## 📚 Demo Guide

Follow these guides in order:

1. **[Setup Guide](./setup.md)** - Get your environment ready
2. **[Live Demo Commands](./demo-commands.md)** - Step-by-step CLI commands  
3. **[Key Concepts](./concepts.md)** - Understanding what we're doing

## 🎯 What You'll Learn

- ✅ How to generate cryptographic keys
- ✅ Create Cardano addresses  
- ✅ Check wallet balances
- ✅ Build and sign transactions
- ✅ Send ADA on the testnet
- ✅ Verify transactions on the blockchain

## 📁 Repository Structure

```
cardano-cli-demo/
├── README.md              # This file
├── setup.md               # Environment setup guide
├── demo-commands.md       # Live demo commands
├── concepts.md            # Key concepts explained
├── docker-compose.yml     # Alternative node setup
├── cli.sh                 # Helper script for CLI commands
├── keys/                  # Generated keys (created during demo)
├── transactions/          # Transaction files (created during demo)
└── examples/              # Example outputs and files
    ├── sample-keys/
    ├── sample-addresses/
    └── sample-transactions/
```

## 🔧 Helper Scripts

- **`./cli.sh`** - Simplified CLI command wrapper
- **`./setup.sh`** - Automated environment setup

## 🌐 Useful Links

- [Cardano Documentation](https://docs.cardano.org)
- [Developer Portal](https://developers.cardano.org)
- [Testnet Faucet](https://docs.cardano.org/cardano-testnets/tools/faucet/)
- [Preview Explorer](https://preview.cardanoscan.io/)
- [Intersect Developer Experience](https://github.com/IntersectMBO/developer-experience)

## 🆘 Troubleshooting

### Node Won't Start
- Check Docker has enough resources (4GB+ RAM)
- Verify port 3001 is available
- Check disk space (~20GB needed)

### CLI Commands Fail  
- Wait for node to sync (check with `./cli.sh query tip --testnet-magic 2`)
- Ensure Docker containers are running
- Check the troubleshooting section in `setup.md`

### Can't Fund Wallet
- Visit the [testnet faucet](https://docs.cardano.org/cardano-testnets/tools/faucet/)
- Wait 30-60 seconds for transactions to confirm
- Check your address is correctly formatted

## 🤝 Contributing

Found an issue or want to improve the demo? 
1. Fork this repository
2. Make your changes
3. Submit a pull request

## 📞 Support

- **During Live Session**: Ask questions in the chat
- **GitHub Issues**: Report problems or suggestions
- **Community**: Join the [Intersect Discord](https://members.intersectmbo.org)

---

**Ready to dive into Cardano CLI?** Start with the [Setup Guide](./setup.md)! 🎉