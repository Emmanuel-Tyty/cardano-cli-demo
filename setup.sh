#!/bin/bash

# Cardano CLI Demo Setup Script
# Automates the setup process for participants

set -e

echo "🚀 Cardano CLI Demo Setup"
echo "========================"
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to check prerequisites
check_prereqs() {
    echo -e "${BLUE}Checking prerequisites...${NC}"
    
    # Check Docker
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}❌ Docker is not installed${NC}"
        echo "Please install Docker from: https://www.docker.com/products/docker-desktop"
        exit 1
    fi
    
    # Check Docker is running
    if ! docker ps &> /dev/null; then
        echo -e "${RED}❌ Docker is not running${NC}"
        echo "Please start Docker Desktop"
        exit 1
    fi
    
    # Check Git
    if ! command -v git &> /dev/null; then
        echo -e "${RED}❌ Git is not installed${NC}"
        echo "Please install Git from: https://git-scm.com"
        exit 1
    fi
    
    # Check disk space (rough check)
    if [[ "$(uname)" == "Darwin" ]]; then
        AVAILABLE=$(df -h . | tail -1 | awk '{print $4}' | sed 's/Gi//')
    else
        AVAILABLE=$(df -h . | tail -1 | awk '{print $4}' | sed 's/G//')
    fi
    
    echo -e "${GREEN}✅ Docker: $(docker --version | cut -d' ' -f3)${NC}"
    echo -e "${GREEN}✅ Git: $(git --version | cut -d' ' -f3)${NC}"
    echo -e "${GREEN}✅ Available space: ${AVAILABLE}GB${NC}"
    echo ""
}

# Function to setup node
setup_node() {
    echo -e "${BLUE}Setting up Cardano node...${NC}"
    
    # Option 1: Try to use existing cardano-node repo
    if [[ -d "../cardano-node" ]]; then
        echo "Found existing cardano-node repository"
        CARDANO_NODE_PATH="../cardano-node"
        USE_EXTERNAL_NODE=true
    else
        echo "No existing cardano-node found, using built-in setup"
        CARDANO_NODE_PATH="."
        USE_EXTERNAL_NODE=false
    fi
    
    # Start appropriate node
    if [[ "$USE_EXTERNAL_NODE" == "true" ]]; then
        echo "Starting external Cardano node..."
        cd ../cardano-node
        export NETWORK=preview
        export CARDANO_NODE_VERSION=latest
        docker-compose up -d
        cd ../cardano-cli-demo
    else
        echo "Starting built-in Cardano node..."
        docker-compose up -d
    fi
    
    echo -e "${GREEN}✅ Node starting...${NC}"
    echo ""
}

# Function to wait for node
wait_for_node() {
    echo -e "${BLUE}Waiting for node to initialize...${NC}"
    
    # Wait for container to be ready
    sleep 5
    
    # Test connection
    for i in {1..30}; do
        if ./cli.sh query tip --testnet-magic 2 &> /dev/null; then
            echo -e "${GREEN}✅ Node is responding!${NC}"
            break
        fi
        
        if [[ $i -eq 30 ]]; then
            echo -e "${RED}❌ Node failed to start properly${NC}"
            echo "Check logs with: docker-compose logs"
            exit 1
        fi
        
        echo -n "."
        sleep 2
    done
    echo ""
}

# Function to create directories
create_directories() {
    echo -e "${BLUE}Creating workspace directories...${NC}"
    
    mkdir -p keys transactions examples
    
    echo -e "${GREEN}✅ Directories created:${NC}"
    echo "  • keys/         - Your generated keys and addresses"
    echo "  • transactions/ - Transaction files"
    echo "  • examples/     - Sample files"
    echo ""
}

# Function to test CLI
test_cli() {
    echo -e "${BLUE}Testing CLI connection...${NC}"
    
    echo "Node status:"
    ./cli.sh query tip --testnet-magic 2
    echo ""
    
    SYNC_PROGRESS=$(./cli.sh query tip --testnet-magic 2 | grep syncProgress | cut -d'"' -f4)
    
    if (( $(echo "$SYNC_PROGRESS > 0.90" | bc -l) )); then
        echo -e "${GREEN}🎉 Node is synced! Ready for transactions.${NC}"
    else
        echo -e "${YELLOW}⏳ Node is syncing... Progress: $(echo "$SYNC_PROGRESS * 100" | bc -l)%${NC}"
        echo "You can generate keys now, but wait for >90% sync for transactions."
    fi
    echo ""
}

# Function to show final instructions
show_instructions() {
    echo -e "${GREEN}🎉 Setup Complete!${NC}"
    echo "=================="
    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo "1. Open VS Code in this directory to view files"
    echo "2. Bookmark the testnet faucet: https://docs.cardano.org/cardano-testnets/tools/faucet/"
    echo "3. Follow the demo commands in demo-commands.md"
    echo "4. Join the live session!"
    echo ""
    echo -e "${YELLOW}Quick test commands:${NC}"
    echo "• Check node: ./cli.sh query tip --testnet-magic 2"
    echo "• View setup: ls -la"
    echo "• Read guide: cat demo-commands.md"
    echo ""
    echo -e "${YELLOW}Troubleshooting:${NC}"
    echo "• If CLI fails: Check docker-compose ps"
    echo "• If sync slow: Check docker-compose logs -f"
    echo "• If stuck: Ask for help in the live session!"
    echo ""
}

# Main execution
main() {
    check_prereqs
    setup_node
    wait_for_node
    create_directories
    test_cli
    show_instructions
}

# Handle interruption
trap 'echo -e "\n${YELLOW}Setup interrupted. Run ./setup.sh again to retry.${NC}"; exit 1' INT

# Run main function
main "$@"