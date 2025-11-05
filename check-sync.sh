#!/bin/bash

# Cardano Node Sync Progress Checker
# Monitors sync progress and notifies when ready for transactions

echo "🔄 Cardano Node Sync Monitor"
echo "=============================="

while true; do
    # Get sync progress
    SYNC_DATA=$(./cli.sh query tip --testnet-magic 2 2>/dev/null)
    
    if [[ $? -ne 0 ]]; then
        echo "❌ Cannot connect to node. Is it running?"
        echo "   Try: docker-compose ps"
        sleep 10
        continue
    fi
    
    SYNC_PROGRESS=$(echo "$SYNC_DATA" | grep syncProgress | cut -d'"' -f4)
    EPOCH=$(echo "$SYNC_DATA" | grep epoch | head -1 | cut -d':' -f2 | tr -d ',' | xargs)
    BLOCK=$(echo "$SYNC_DATA" | grep block | cut -d':' -f2 | tr -d ',' | xargs)
    
    # Calculate percentage
    PERCENT=$(echo "$SYNC_PROGRESS * 100" | bc -l 2>/dev/null || echo "0")
    PERCENT_INT=$(printf "%.1f" "$PERCENT" 2>/dev/null || echo "0")
    
    # Clear line and show progress
    echo -ne "\r🔄 Sync: ${PERCENT_INT}% | Epoch: $EPOCH | Block: $BLOCK"
    
    # Check if ready for transactions
    if (( $(echo "$SYNC_PROGRESS > 0.90" | bc -l 2>/dev/null || echo 0) )); then
        echo ""
        echo ""
        echo "🎉 Node is synced! Ready for transactions!"
        echo "✅ You can now:"
        echo "  • Query UTXOs"
        echo "  • Build transactions" 
        echo "  • Submit to network"
        echo "  • Fund from faucet"
        echo ""
        break
    fi
    
    # Check if getting close
    if (( $(echo "$SYNC_PROGRESS > 0.80" | bc -l 2>/dev/null || echo 0) )); then
        if [[ ! -f .sync-warning-shown ]]; then
            echo ""
            echo "⏰ Almost there! >80% synced"
            echo "   Transactions will work at >90%"
            touch .sync-warning-shown
        fi
    fi
    
    sleep 5
done

echo "🚀 Ready for full Cardano CLI demo!"