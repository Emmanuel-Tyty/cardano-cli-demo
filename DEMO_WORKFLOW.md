# Live Demo Workflow Summary 🎬

This document shows the improved workflow with mounted directories.

## ✅ What's New

- **Direct file creation**: All files created directly in host filesystem
- **Instant VS Code visibility**: Files appear immediately as they're created
- **No copying needed**: No more `docker cp` commands
- **Cleaner commands**: Simplified CLI usage

## 🎯 Demo Flow

### 1. Quick Start
```bash
# Clone and setup (one command!)
git clone <your-repo-url>
cd cardano-cli-demo
./setup.sh
```

### 2. Generate Keys (Visible in VS Code immediately!)
```bash
./cli.sh address key-gen \
  --verification-key-file keys/payment.vkey \
  --signing-key-file keys/payment.skey

# Files appear instantly in VS Code!
# Show participants the JSON structure
code keys/payment.vkey
```

### 3. Create Address (Direct to filesystem!)
```bash
./cli.sh address build \
  --payment-verification-key-file keys/payment.vkey \
  --testnet-magic 2 \
  --out-file keys/wallet.addr

# Address is immediately visible
cat keys/wallet.addr
```

### 4. Check Balance & Fund
```bash
WALLET_ADDR=$(cat keys/wallet.addr)
./cli.sh query utxo --address $WALLET_ADDR --testnet-magic 2

# Fund via faucet: https://docs.cardano.org/cardano-testnets/tools/faucet/
```

### 5. Create Recipient & Send Transaction
```bash
# Generate recipient (files appear instantly)
./cli.sh address key-gen \
  --verification-key-file keys/recipient.vkey \
  --signing-key-file keys/recipient.skey

./cli.sh address build \
  --payment-verification-key-file keys/recipient.vkey \
  --testnet-magic 2 \
  --out-file keys/recipient.addr

# Build transaction (protocol.json appears in transactions/)
./cli.sh query protocol-parameters \
  --testnet-magic 2 \
  --out-file transactions/protocol.json

RECIPIENT_ADDR=$(cat keys/recipient.addr)
UTXO=$(./cli.sh query utxo --address $WALLET_ADDR --testnet-magic 2 | grep -o '^[a-f0-9]*#[0-9]*' | head -1)

./cli.sh transaction build \
  --tx-in "$UTXO" \
  --tx-out "$RECIPIENT_ADDR+5000000" \
  --change-address $WALLET_ADDR \
  --testnet-magic 2 \
  --out-file transactions/tx.raw

# Sign (tx.signed appears instantly)
./cli.sh transaction sign \
  --tx-body-file transactions/tx.raw \
  --signing-key-file keys/payment.skey \
  --testnet-magic 2 \
  --out-file transactions/tx.signed

# Submit
./cli.sh transaction submit \
  --tx-file transactions/tx.signed \
  --testnet-magic 2
```

## 👀 VS Code View During Demo

Participants will see files appear in real-time:

```
cardano-cli-demo/
├── keys/
│   ├── payment.vkey      ← Appears after key-gen
│   ├── payment.skey      ← Appears after key-gen  
│   ├── wallet.addr       ← Appears after address build
│   ├── recipient.vkey    ← Appears after recipient key-gen
│   ├── recipient.skey    ← Appears after recipient key-gen
│   └── recipient.addr    ← Appears after recipient address build
└── transactions/
    ├── protocol.json     ← Appears after protocol-parameters
    ├── tx.raw           ← Appears after transaction build
    └── tx.signed        ← Appears after transaction sign
```

## 🎉 Benefits for Live Session

1. **Real-time visibility**: Files appear as commands run
2. **Educational**: Can immediately examine file contents
3. **No confusion**: No "where did my files go?" moments
4. **Interactive**: Participants can edit/examine files
5. **Professional**: Smooth, no technical hiccups

## 💡 Presenter Tips

- **Open VS Code first**: `code .` before starting
- **Show file explorer**: Keep it visible during demo
- **Highlight JSON structure**: When files appear, show their format
- **Explain security**: Point out .skey vs .vkey differences
- **Use address variables**: `WALLET_ADDR=$(cat keys/wallet.addr)`

## 🚀 Ready to Present!

Your demo will be smooth, professional, and educational with:
- ✅ Files appearing instantly in VS Code
- ✅ No technical complexity visible to participants  
- ✅ Clear progression from keys → addresses → transactions
- ✅ Perfect integration with existing workflows