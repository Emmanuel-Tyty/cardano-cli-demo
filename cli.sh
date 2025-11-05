#!/bin/bash
# Helper script for Cardano CLI demo
docker-compose -f /Users/tyty/Desktop/intersect/cardano-node/docker-compose.yml exec -e CARDANO_NODE_SOCKET_PATH=/ipc/node.socket cardano-node cardano-cli "$@"
