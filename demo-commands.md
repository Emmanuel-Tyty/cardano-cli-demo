# Live Demo Commands 🎯

Follow along with these commands during the live session. Each step includes explanations of what's happening.

## Pre-Demo Check ✅

```bash
# Verify your setup works
./cli.sh query tip --testnet-magic 2

# Should show: block, epoch, era, syncProgress
# If syncProgress < 0.90, transactions won't work yet (but we can still generate keys!)
```

## Part 1: Understanding Keys & Addresses 🔐

### Step 1: Generate Your Wallet Keys
```bash
# Generate payment keys (in the Docker container)
docker-compose -f ../cardano-node/docker-compose.yml exec \
  -e CARDANO_NODE_SOCKET_PATH=/ipc/node.socket \
  cardano-node cardano-cli address key-gen \
  --verification-key-file /tmp/payment.vkey \
  --signing-key-file /tmp/payment.skey

# Copy keys to local directory (so we can see them in VS Code)
docker cp $(docker-compose -f ../cardano-node/docker-compose.yml ps -q cardano-node):/tmp/payment.vkey ./keys/
docker cp $(docker-compose -f ../cardano-node/docker-compose.yml ps -q cardano-node):/tmp/payment.skey ./keys/

echo "✅ Keys generated!"
```

**💡 Explanation**: 
- `payment.vkey` = **Public Key** (safe to share, like your account number)
- `payment.skey` = **Private Key** (SECRET! Like your password)

### Step 2: Look at Your Keys
```bash
# View public key structure
cat keys/payment.vkey

# DO NOT share private key (but let's see the format)
echo "Private key format (DO NOT SHARE!):"
head -c 100 keys/payment.skey && echo "..."
```

**💡 What You See**: JSON format with cryptographic data (CBOR hex encoding)

### Step 3: Create Your Wallet Address
```bash
# Build address from public key
docker-compose -f ../cardano-node/docker-compose.yml exec \
  -e CARDANO_NODE_SOCKET_PATH=/ipc/node.socket \
  cardano-node cardano-cli address build \
  --payment-verification-key-file /tmp/payment.vkey \
  --testnet-magic 2 \
  --out-file /tmp/wallet.addr

# Copy to local
docker cp $(docker-compose -f ../cardano-node/docker-compose.yml ps -q cardano-node):/tmp/wallet.addr ./keys/

# Save address to variable for easy reuse
WALLET_ADDR=$(cat keys/wallet.addr)
echo "🏠 Your wallet address: $WALLET_ADDR"
```

**💡 Explanation**: Address is derived from your public key using cryptographic hashing. Format is "bech32" encoding starting with `addr_test1` (testnet).

## Part 2: Checking Balances 💰

### Step 4: Check Your Empty Wallet
```bash
# Query UTXOs (Unspent Transaction Outputs) = your balance
./cli.sh query utxo --address $WALLET_ADDR --testnet-magic 2

echo "💡 Empty wallet = no UTXOs shown"
```

**💡 UTXO Explanation**: 
- Cardano uses UTXO model (like physical coins)
- Each UTXO has an amount you can spend
- Transaction = consume UTXOs → create new UTXOs

### Step 5: Get Testnet ADA (Free Money!)
```bash
echo "🚰 Fund your wallet with testnet faucet:"
echo "1. Visit: https://docs.cardano.org/cardano-testnets/tools/faucet/"
echo "2. Enter your address: $WALLET_ADDR"
echo "3. Complete captcha and request ADA"
echo "4. Wait 30-60 seconds..."
echo ""
echo "💡 Bookmark this address for easy copy/paste: $WALLET_ADDR"
```

**During the wait, let's create a second wallet...**

## Part 3: Create a Recipient Wallet 👥

### Step 6: Generate Recipient Keys
```bash
# Generate second wallet
docker-compose -f ../cardano-node/docker-compose.yml exec \
  -e CARDANO_NODE_SOCKET_PATH=/ipc/node.socket \
  cardano-node cardano-cli address key-gen \
  --verification-key-file /tmp/recipient.vkey \
  --signing-key-file /tmp/recipient.skey

# Build recipient address  
docker-compose -f ../cardano-node/docker-compose.yml exec \
  -e CARDANO_NODE_SOCKET_PATH=/ipc/node.socket \
  cardano-node cardano-cli address build \
  --payment-verification-key-file /tmp/recipient.vkey \
  --testnet-magic 2 \
  --out-file /tmp/recipient.addr

# Copy locally
docker cp $(docker-compose -f ../cardano-node/docker-compose.yml ps -q cardano-node):/tmp/recipient.addr ./keys/

RECIPIENT_ADDR=$(cat keys/recipient.addr)
echo "👤 Recipient address: $RECIPIENT_ADDR"
```

### Step 7: Check If Funding Arrived
```bash
echo "💰 Checking your wallet balance..."
./cli.sh query utxo --address $WALLET_ADDR --testnet-magic 2

# If you see UTXOs with ADA amounts, you're funded! 
# If not, wait a bit more and check again
```

**💡 Understanding the Output**:
```
                           TxHash                                 TxIx        Amount
--------------------------------------------------------------------------------------
a1b2c3d4e5f6...                                                    0        1000000000 lovelace
```
- `TxHash#TxIx` = UTXO identifier (like a serial number on a bill)
- `Amount` = Value in lovelace (1 ADA = 1,000,000 lovelace)

## Part 4: Send Your First Transaction 📤

### Step 8: Build the Transaction
```bash
# Get protocol parameters (fees, limits, etc.)
./cli.sh query protocol-parameters --testnet-magic 2 --out-file /tmp/protocol.json

# Find a UTXO to spend (automatically picks the first one)
UTXO=$(./cli.sh query utxo --address $WALLET_ADDR --testnet-magic 2 | grep -o '^[a-f0-9]*#[0-9]*' | head -1)
echo "📝 Using UTXO: $UTXO"

# Build transaction: Send 5 ADA to recipient
echo "🔨 Building transaction..."
./cli.sh transaction build \
  --tx-in "$UTXO" \
  --tx-out "$RECIPIENT_ADDR+5000000" \
  --change-address $WALLET_ADDR \
  --testnet-magic 2 \
  --out-file /tmp/tx.raw

echo "✅ Transaction built!"
```

**💡 Transaction Components**:
- `--tx-in`: UTXO we're spending (input)
- `--tx-out`: Where money goes (recipient + amount)  
- `--change-address`: Where leftover money returns
- Fees are calculated automatically

### Step 9: Sign the Transaction
```bash
echo "🔐 Signing transaction with your private key..."
./cli.sh transaction sign \
  --tx-body-file /tmp/tx.raw \
  --signing-key-file /tmp/payment.skey \
  --testnet-magic 2 \
  --out-file /tmp/tx.signed

echo "✅ Transaction signed!"
```

**💡 Digital Signature**: Proves you own the UTXO without revealing your private key.

### Step 10: Submit to the Network
```bash
echo "📡 Submitting transaction to Cardano network..."
./cli.sh transaction submit \
  --tx-file /tmp/tx.signed \
  --testnet-magic 2

echo "🎉 Transaction submitted!"

# Get the transaction ID for tracking
TX_ID=$(./cli.sh transaction txid --tx-file /tmp/tx.signed)
echo "🆔 Transaction ID: $TX_ID"
echo "🔍 View on explorer: https://preview.cardanoscan.io/transaction/$TX_ID"
```

### Step 11: Verify the Transaction
```bash
echo "⏳ Waiting for transaction to confirm (30-60 seconds)..."
echo "Press Enter when you want to check balances"
read

echo "📊 Sender balance (should be less):"
./cli.sh query utxo --address $WALLET_ADDR --testnet-magic 2

echo ""
echo "📊 Recipient balance (should have 5 ADA):"
./cli.sh query utxo --address $RECIPIENT_ADDR --testnet-magic 2
```

## Part 5: Understanding What Happened 🧠

### View Files in VS Code
Open your `keys/` directory in VS Code and examine:
```
keys/
├── payment.vkey      # ✅ Your public key (JSON)
├── payment.skey      # ❌ Your private key (SECRET!)
├── wallet.addr       # 🏠 Your wallet address  
└── recipient.addr    # 👤 Where we sent money
```

### Key Concepts Recap

1. **Cryptographic Keys**:
   - Private key = Secret, used for signing
   - Public key = Shareable, used for verification
   - Address = Derived from public key

2. **UTXO Model**:
   - Each UTXO is like a physical coin
   - Transactions consume UTXOs and create new ones
   - Your balance = sum of all UTXOs at your address

3. **Transaction Process**:
   - Build: Define inputs/outputs
   - Sign: Prove ownership with private key  
   - Submit: Broadcast to network
   - Confirm: Included in blockchain

4. **Network Magic**:
   - `--testnet-magic 2` = Preview testnet
   - Ensures transactions go to correct network
   - Mainnet uses `--mainnet`

## Bonus: Advanced Commands (If Time Permits) 🚀

### Check Sync Status
```bash
# See detailed node info
./cli.sh query tip --testnet-magic 2

# Current epoch and remaining time
./cli.sh query tip --testnet-magic 2 | jq '.epoch, .slotsToEpochEnd'
```

### Generate More Addresses
```bash
# Generate staking keys for delegation
docker-compose -f ../cardano-node/docker-compose.yml exec \
  -e CARDANO_NODE_SOCKET_PATH=/ipc/node.socket \
  cardano-node cardano-cli stake-address key-gen \
  --verification-key-file /tmp/stake.vkey \
  --signing-key-file /tmp/stake.skey

# Build base address (payment + staking)
docker-compose -f ../cardano-node/docker-compose.yml exec \
  -e CARDANO_NODE_SOCKET_PATH=/ipc/node.socket \
  cardano-node cardano-cli address build \
  --payment-verification-key-file /tmp/payment.vkey \
  --stake-verification-key-file /tmp/stake.vkey \
  --testnet-magic 2 \
  --out-file /tmp/base.addr

echo "🎯 Base address (with staking): $(cat /tmp/base.addr)"
```

### Explore the Blockchain
```bash
# Query current stake pools
./cli.sh query stake-pools --testnet-magic 2 | head -5

# Query protocol parameters
./cli.sh query protocol-parameters --testnet-magic 2 | jq '.minFeeA, .minFeeB'
```

## Troubleshooting 🛠️

### Transaction Failed
```bash
# Check if UTXO still exists (not already spent)
./cli.sh query utxo --address $WALLET_ADDR --testnet-magic 2

# Check node is synced
./cli.sh query tip --testnet-magic 2
# Need syncProgress > 0.90 for transactions
```

### Can't Find Files
```bash
# List what we created
ls -la keys/
ls -la transactions/

# Copy more files from container if needed
docker cp $(docker-compose -f ../cardano-node/docker-compose.yml ps -q cardano-node):/tmp/ ./container-files/
```

### Node Issues
```bash
# Check containers
docker-compose ps

# Check logs
cd ../cardano-node && docker-compose logs -f cardano-node
```

---

## 🎓 Congratulations! 

You've successfully:
- ✅ Generated cryptographic keys
- ✅ Created Cardano addresses  
- ✅ Funded a wallet from faucet
- ✅ Built, signed, and submitted a transaction
- ✅ Verified money moved on the blockchain

**Next Steps**:
- Explore [Cardano documentation](https://docs.cardano.org)
- Try building dApps with [Cardano SDKs](https://developers.cardano.org)
- Join the [developer community](https://cardano.stackexchange.com)
- Practice on mainnet (with real ADA!)

**Questions?** Ask during the session or open an issue in this repository!