# Live Demo Commands 🎯

Follow along with these commands during the live session. Each step includes explanations of what's happening.

## Pre-Demo Check ✅

```bash
# Verify your setup works
./cli.sh query tip --testnet-magic 2

# Should show: block, epoch, era, syncProgress
# If syncProgress < 90%, transactions won't work yet (but we can still generate keys!)
```

## Part 1: Understanding Keys & Addresses 🔐

### Step 1: Generate Your Wallet Keys
```bash
# Generate payment keys (directly in mounted directory)
./cli.sh address key-gen \
  --verification-key-file keys/payment.vkey \
  --signing-key-file keys/payment.skey

echo "✅ Keys generated in keys/ directory!"
echo "💡 Open VS Code to see the files: code ."
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

### Step 3: Create Your Wallet Addresses
```bash
# First, generate staking keys (needed for full functionality)
./cli.sh conway stake-address key-gen \
  --verification-key-file keys/stake.vkey \
  --signing-key-file keys/stake.skey

# Build enterprise address (payment only)
./cli.sh address build \
  --payment-verification-key-file keys/payment.vkey \
  --testnet-magic 2 \
  --out-file keys/enterprise.addr

# Build base address (payment + staking) - RECOMMENDED!
./cli.sh address build \
  --payment-verification-key-file keys/payment.vkey \
  --stake-verification-key-file keys/stake.vkey \
  --testnet-magic 2 \
  --out-file keys/base.addr

# Build stake address (for receiving rewards)
./cli.sh conway stake-address build \
  --stake-verification-key-file keys/stake.vkey \
  --testnet-magic 2 \
  --out-file keys/stake.addr

# Use base address as primary wallet (best practice)
WALLET_ADDR=$(cat keys/base.addr)
echo "🏠 Your main wallet address (base): $WALLET_ADDR"
echo "💡 Address length: ${#WALLET_ADDR} characters"
```


**💡 Address Types Explained**:
- **Enterprise** (`addr_test1v...`): Payment only, smaller, no staking
- **Base** (`addr_test1q...`): Payment + staking, full functionality ✅  
- **Stake** (`stake_test1...`): Receives staking rewards only

```bash
# Compare the different address types
echo "Address Comparison:"
echo "Enterprise (payment only): $(cat keys/enterprise.addr)"
echo "Base (payment + stake): $(cat keys/base.addr)"
echo "Stake (rewards only): $(cat keys/stake.addr)"
```

## Part 2: Checking Balances 💰

### Step 4: Check Your Empty Wallet

⚠️  **NOTE**: UTXO queries work with partial sync but may be incomplete until >90%

```bash
# Check sync status
./cli.sh query tip --testnet-magic 2

# Make sure address variable is set (run this if you're in a new terminal)
WALLET_ADDR=$(cat keys/base.addr)
echo "Checking UTXOs for base address: $WALLET_ADDR"

# Query UTXOs (Unspent Transaction Outputs) = your balance
./cli.sh query utxo --address $WALLET_ADDR --testnet-magic 2

echo "💡 Empty wallet = no UTXOs shown (empty {} or table)"
echo "💡 If recently funded, may take time to appear during sync"
```

**💡 UTXO Explanation**: 
- Cardano uses UTXO model (like physical coins)
- Each UTXO has an amount you can spend
- Transaction = consume UTXOs → create new UTXOs

### Step 5: Get Testnet ADA (Free Money!)
```bash
echo "😰 Fund your base address with testnet faucet:"
echo "1. Visit: https://docs.cardano.org/cardano-testnets/tools/faucet/"
echo "2. Enter your BASE address: $WALLET_ADDR"
echo "3. Complete captcha and request ADA"
echo "4. Wait 30-60 seconds..."
echo ""
echo "💡 Why base address? It can stake for rewards (~5% APY)"
echo "💡 Bookmark this address: $WALLET_ADDR"
```

**During the wait, let's create a second wallet...**

## Part 3: Create a Recipient Wallet 👥

### Step 6: Generate Recipient Keys
```bash
# Generate second wallet keys
./cli.sh address key-gen \
  --verification-key-file keys/recipient.vkey \
  --signing-key-file keys/recipient.skey

# Build recipient address
./cli.sh address build \
  --payment-verification-key-file keys/recipient.vkey \
  --testnet-magic 2 \
  --out-file keys/recipient.addr

# Set recipient address variable
RECIPIENT_ADDR=$(cat keys/recipient.addr)
echo "👤 Recipient address: $RECIPIENT_ADDR"
echo "📁 Files saved in keys/ directory"
echo "💡 Recipient address length: ${#RECIPIENT_ADDR} characters"
```

### Step 7: Check If Funding Arrived
```bash
echo "💰 Checking your base address balance..."
# Ensure variable is set
WALLET_ADDR=$(cat keys/base.addr)
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

⚠️  **SYNC REQUIREMENT**: Your node must be >90% synced for transactions to work.
```bash
# Check sync status first
./cli.sh query tip --testnet-magic 2
# Look for "syncProgress" - need >0.90 (90%)

# If not synced enough, you can still demo transaction building (it will work)
# But submission will fail until >90% synced

# Ensure variables are set (important if starting fresh terminal)
WALLET_ADDR=$(cat keys/base.addr)  # Use base address (staking-enabled)
RECIPIENT_ADDR=$(cat keys/recipient.addr)
echo "Sender (base address): $WALLET_ADDR"
echo "Recipient: $RECIPIENT_ADDR"

# Get protocol parameters (fees, limits, etc.)
./cli.sh query protocol-parameters --testnet-magic 2 --out-file transactions/protocol.json

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
  --out-file transactions/tx.raw

echo "✅ Transaction built in transactions/ directory!"
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
  --tx-body-file transactions/tx.raw \
  --signing-key-file keys/payment.skey \
  --testnet-magic 2 \
  --out-file transactions/tx.signed

echo "✅ Transaction signed!"
```

**💡 Digital Signature**: Proves you own the UTXO without revealing your private key.

### Step 10: Submit to the Network

⚠️  **This will only work if your node is >90% synced!**

```bash
# Check sync status again before submitting
SYNC_STATUS=$(./cli.sh query tip --testnet-magic 2 | grep syncProgress | cut -d'"' -f4)
echo "Current sync progress: $(echo "$SYNC_STATUS * 100" | bc -l)%"

if (( $(echo "$SYNC_STATUS > 0.90" | bc -l) )); then
    echo "✅ Node is synced! Submitting transaction..."
    ./cli.sh transaction submit \
      --tx-file transactions/tx.signed \
      --testnet-magic 2
    
    echo "🎉 Transaction submitted!"
    
    # Get the transaction ID for tracking
    TX_ID=$(./cli.sh transaction txid --tx-file transactions/tx.signed)
    echo "🆔 Transaction ID: $TX_ID"
    echo "🔍 View on explorer: https://preview.cardanoscan.io/transaction/$TX_ID"
else
    echo "⏳ Node is still syncing (${SYNC_STATUS})"  
    echo "Transaction built and signed successfully, but submission requires >90% sync"
    echo "You can:"
    echo "  1. Wait for sync to complete (./check-sync.sh to monitor)"
    echo "  2. Submit later when synced"
    echo "  3. Use the transaction as a teaching example"
fi
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
├── stake.vkey        # ✅ Your staking public key
├── stake.skey        # ❌ Your staking private key (SECRET!)
├── enterprise.addr   # 🏠 Enterprise address (payment only)
├── base.addr         # 🏠 Base address (payment + staking) ✅
├── stake.addr        # 🎯 Stake address (rewards)
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
./cli.sh conway stake-address key-gen \
  --verification-key-file keys/stake.vkey \
  --signing-key-file keys/stake.skey

# Build base address (payment + staking)
./cli.sh address build \
  --payment-verification-key-file keys/payment.vkey \
  --stake-verification-key-file keys/stake.vkey \
  --testnet-magic 2 \
  --out-file keys/base.addr

echo "🎯 Base address (with staking): $(cat keys/base.addr)"
```

### Explore the Blockchain
```bash
# Query current stake pools
./cli.sh query stake-pools --testnet-magic 2 | head -5

# Query protocol parameters
./cli.sh query protocol-parameters --testnet-magic 2 | jq '.minFeeA, .minFeeB'
```

## Troubleshooting 🔧

### Address Variable Issues
```bash
# If you get "unexpected -" error, your address variable isn't set:
echo "WALLET_ADDR='$WALLET_ADDR'"  # Should show your address

# Fix by reloading from file:
WALLET_ADDR=$(cat keys/base.addr)  # Use base address
RECIPIENT_ADDR=$(cat keys/recipient.addr)

# Verify they're set:
echo "Wallet: $WALLET_ADDR"
echo "Recipient: $RECIPIENT_ADDR"
```

### Transaction Failed
```bash
# Check if UTXO still exists (not already spent)
WALLET_ADDR=$(cat keys/base.addr)  # Ensure variable is set
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