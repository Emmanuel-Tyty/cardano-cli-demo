#!/bin/bash
# Helper script for Cardano CLI demo

# Check if we're using the local docker-compose or external cardano-node
if [[ -d "../cardano-node" ]] && docker-compose -f ../cardano-node/docker-compose.yml ps | grep -q cardano-node; then
    # Use external cardano-node repo
    docker-compose -f ../cardano-node/docker-compose.yml exec -e CARDANO_NODE_SOCKET_PATH=/ipc/node.socket cardano-node cardano-cli "$@"
else
    # Use local docker-compose with mounted directories
    docker-compose exec cardano-node cardano-cli "$@"
fi
