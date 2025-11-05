# Quick Demo for Unsynced Nodes 🚀

When your node is still syncing (< 90%), you can still demonstrate key concepts!

## Current Sync Status
```bash
./cli.sh query tip --testnet-magic 2
# Look for "syncProgress": shows percentage (e.g., "0.08" = 8%)
```

## What Works While Syncing ✅

### 1. Key Generation (Always Works)
```bash
# Generate payment keys
./cli.sh address key-gen \
  --verification-key-file keys/payment.vkey \
  --signing-key-file keys/payment.skey

# Show the JSON structure in VS Code
cat keys/payment.vkey
```

### 2. Address Creation (Always Works)  
```bash
# Build address from keys
./cli.sh address build \
  --payment-verification-key-file keys/payment.vkey \
  --testnet-magic 2 \
  --out-file keys/wallet.addr

WALLET_ADDR=$(cat keys/wallet.addr)
echo "Generated address: $WALLET_ADDR"
echo "Address length: ${#WALLET_ADDR} characters"
```

### 3. Multiple Address Types
```bash
# Generate staking keys
./cli.sh stake-address key-gen \
  --verification-key-file keys/stake.vkey \
  --signing-key-file keys/stake.skey

# Build base address (payment + staking)
./cli.sh address build \
  --payment-verification-key-file keys/payment.vkey \
  --stake-verification-key-file keys/stake.vkey \
  --testnet-magic 2 \
  --out-file keys/base.addr

# Build stake address
./cli.sh stake-address build \
  --stake-verification-key-file keys/stake.vkey \
  --testnet-magic 2 \
  --out-file keys/stake.addr

echo "Enterprise address: $(cat keys/wallet.addr)"
echo "Base address: $(cat keys/base.addr)"  
echo "Stake address: $(cat keys/stake.addr)"
```

### 4. Address Analysis (Always Works)
```bash
# Decode address information
./cli.sh address info --address $(cat keys/base.addr)
```

## What Doesn't Work While Syncing ❌

### UTXO Queries (Need >90% sync)
```bash
# This will return empty or fail until synced
./cli.sh query utxo --address $WALLET_ADDR --testnet-magic 2
```

### Transactions (Need >90% sync)  
```bash
# Transaction building/submission requires full sync
# Save these for when node is synced
```

## Demo Strategy for Live Session 📋

### Phase 1: Theory + Key Generation (Works Now)
1. **Explain Concepts**: Private/public keys, addresses, UTXO model
2. **Generate Keys**: Show JSON structure in VS Code
3. **Create Addresses**: Demonstrate different address types
4. **Address Analysis**: Decode and explain components
5. **Show Node Status**: Explain sync process

### Phase 2: Transactions (When Synced)
1. **Fund Wallets**: Use testnet faucet
2. **Query UTXOs**: Show transaction inputs
3. **Build Transactions**: Demonstrate transaction building
4. **Sign & Submit**: Complete the transaction flow

## Alternative: Use Remote API for Demo

For immediate transaction demos, you can use external APIs:

### Blockfrost API Example
```bash
# Set up Blockfrost API key (free tier available)
export BLOCKFROST_PROJECT_ID="your_project_id"

# Query UTXOs via API instead of local node
curl -H "project_id: $BLOCKFROST_PROJECT_ID" \
  "https://cardano-preview.blockfrost.io/api/v0/addresses/$WALLET_ADDR/utxos"
```

### Koios API Example (No auth needed)
```bash
# Query address info via Koios
curl -X POST "https://preview.koios.rest/api/v1/address_info" \
  -H "Content-Type: application/json" \
  -d '{"_addresses": ["'$WALLET_ADDR'"]}'
```

## Presenter Script for Unsynced Demo

```bash
#!/bin/bash
echo "🎯 Cardano CLI Demo - Unsynced Node Version"
echo "============================================"

# Show sync status
echo "📊 Current sync status:"
./cli.sh query tip --testnet-magic 2 | grep syncProgress

echo ""
echo "🔑 What we CAN do while syncing:"
echo "✅ Generate cryptographic keys"
echo "✅ Create addresses" 
echo "✅ Analyze address components"
echo "✅ Explain blockchain concepts"

echo ""
echo "⏳ What we need to wait for:"
echo "❌ Query UTXOs (need >90% sync)"
echo "❌ Build transactions (need >90% sync)" 
echo "❌ Submit to network (need >90% sync)"

echo ""
echo "Let's start with key generation..."
```

## Sync Time Estimates

- **Full sync**: 4-8 hours (depending on hardware/network)
- **Usable for transactions**: When syncProgress > 0.90
- **Preview testnet**: Smaller, syncs faster than mainnet

## Tips for Live Session

1. **Start node early**: Begin sync before session
2. **Prepare both scenarios**: Synced and unsynced demos
3. **Use sync as teaching moment**: Explain blockchain size, verification
4. **Show file creation**: VS Code integration works regardless of sync
5. **Set expectations**: Explain why sync is needed for network queries

## Check Sync Progress Script

```bash
#!/bin/bash
while true; do
    SYNC=$(./cli.sh query tip --testnet-magic 2 | grep syncProgress | cut -d'"' -f4)
    PERCENT=$(echo "$SYNC * 100" | bc -l)
    echo "Sync progress: ${PERCENT}%"
    
    if (( $(echo "$SYNC > 0.90" | bc -l) )); then
        echo "🎉 Ready for transactions!"
        break
    fi
    
    sleep 30
done
```

Your demo will be educational even with an unsynced node - just focus on the cryptographic concepts first!