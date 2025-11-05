# Transaction Demo Alternatives 🔄

When your node isn't fully synced (>90%), you have several options for demonstrating transactions:

## Current Sync Status Check
```bash
# Check your current sync progress
./cli.sh query tip --testnet-magic 2

# Monitor sync progress
./check-sync.sh
```

## Option 1: Demo Transaction Building (Always Works) ✅

You can build and sign transactions even with a partially synced node:

```bash
# 1. Generate keys and addresses (works always)
./cli.sh address key-gen --verification-key-file keys/demo.vkey --signing-key-file keys/demo.skey
./cli.sh address build --payment-verification-key-file keys/demo.vkey --testnet-magic 2 --out-file keys/demo.addr

# 2. Create a "mock" UTXO for demo purposes
echo "For demo: pretend we have UTXO abc123#0 with 10 ADA"

# 3. Build transaction (this will work regardless of sync)
./cli.sh transaction build \
  --tx-in "abc123def456789012345678901234567890123456789012345678901234567890#0" \
  --tx-out "$(cat keys/demo.addr)+5000000" \
  --change-address "$(cat keys/demo.addr)" \
  --testnet-magic 2 \
  --out-file transactions/demo.raw 2>/dev/null || echo "Expected error - invalid UTXO"

echo "✅ This shows how transaction building works conceptually"
```

## Option 2: Use External API for Real Demo 🌐

### Blockfrost API (Free Tier Available)
```bash
# Sign up at https://blockfrost.io for free API key
export BLOCKFROST_PROJECT_ID="your_preview_project_id"

# Query real UTXOs
curl -H "project_id: $BLOCKFROST_PROJECT_ID" \
  "https://cardano-preview.blockfrost.io/api/v0/addresses/$WALLET_ADDR/utxos"

# Submit transaction (if you have one ready)
curl -X POST \
  -H "project_id: $BLOCKFROST_PROJECT_ID" \
  -H "Content-Type: application/cbor" \
  --data-binary "@transactions/tx.signed" \
  "https://cardano-preview.blockfrost.io/api/v0/tx/submit"
```

### Koios API (No Auth Required)
```bash
# Query address info
curl -X POST "https://preview.koios.rest/api/v1/address_info" \
  -H "Content-Type: application/json" \
  -d '{"_addresses": ["'$WALLET_ADDR'"]}'

# Query UTXOs
curl -X POST "https://preview.koios.rest/api/v1/address_utxos" \
  -H "Content-Type: application/json" \
  -d '{"_addresses": ["'$WALLET_ADDR'"]}'
```

## Option 3: Educational Focus 📚

Use the sync time as a teaching opportunity:

### 1. Explain Why Sync is Needed
```bash
echo "🔗 Why does Cardano need to sync?"
echo "  • Validates every transaction since genesis"
echo "  • Ensures you have the correct blockchain state"  
echo "  • Prevents double-spending and fraud"
echo "  • Currently at $(./cli.sh query tip --testnet-magic 2 | grep syncProgress | cut -d'"' -f4 | awk '{print $1*100}')%"
```

### 2. Show What Works During Sync
```bash
echo "✅ What works while syncing:"
echo "  • Key generation"
echo "  • Address creation"
echo "  • Transaction building (conceptual)"
echo "  • Understanding UTXO model"
echo ""
echo "⏳ What needs full sync (>90%):"
echo "  • Accurate UTXO queries"
echo "  • Transaction submission"
echo "  • Balance verification"
```

### 3. Demonstrate Security Concepts
```bash
echo "🔐 Security concepts we can show:"
echo "  • Private/public key cryptography"
echo "  • Digital signatures"
echo "  • Address derivation"
echo "  • Transaction structure"
```

## Option 4: Save Transaction for Later ⏰

Build and sign the transaction now, submit when synced:

```bash
# Build transaction now
./cli.sh transaction build \
  --tx-in "$UTXO" \
  --tx-out "$RECIPIENT_ADDR+5000000" \
  --change-address $WALLET_ADDR \
  --testnet-magic 2 \
  --out-file transactions/ready-to-submit.raw

# Sign it now
./cli.sh transaction sign \
  --tx-body-file transactions/ready-to-submit.raw \
  --signing-key-file keys/payment.skey \
  --testnet-magic 2 \
  --out-file transactions/ready-to-submit.signed

echo "✅ Transaction ready! Submit when node is >90% synced:"
echo "   ./cli.sh transaction submit --tx-file transactions/ready-to-submit.signed --testnet-magic 2"

# Save for later
echo "🔖 Bookmark this command for when sync completes"
```

## Option 5: Use Testnet Faucet for Immediate Demo 💧

If you can get to >90% sync before your demo:

```bash
# Fund your address
echo "Fund this address: $WALLET_ADDR"
echo "Faucet: https://docs.cardano.org/cardano-testnets/tools/faucet/"

# Monitor for funding (run this periodically)
./cli.sh query utxo --address $WALLET_ADDR --testnet-magic 2

# When funded and synced, proceed with full demo
```

## Best Demo Strategy 🎯

For your live session:

1. **Start with keys/addresses** (always works)
2. **Explain sync requirement** (educational)  
3. **Show transaction building** (works partially)
4. **Use external API** if needed for real data
5. **Save signed transaction** for later submission
6. **Focus on concepts** rather than live submission

Your audience will learn just as much about Cardano's security model and UTXO system without needing a fully synced node!