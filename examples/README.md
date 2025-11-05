# Example Files 📂

This directory contains sample files showing what to expect during the demo.

## Sample Key Files

### Public Key (payment.vkey)
```json
{
    "type": "PaymentVerificationKeyShelley_ed25519",
    "description": "Payment Verification Key",
    "cborHex": "5820a1b2c3d4e5f67890abcdef1234567890abcdef1234567890abcdef12345678"
}
```

### Private Key (payment.skey)
```json
{
    "type": "PaymentSigningKeyShelley_ed25519", 
    "description": "Payment Signing Key",
    "cborHex": "5840abcdef1234567890abcdef1234567890abcdef1234567890abcdef123456789..."
}
```

**⚠️ Never share your actual private key!**

## Sample Address
```
addr_test1vq9pravx906fy0wqnpgjftyn85dzul4rmghqzd762pl5fhqx3x3gk
```

## Sample UTXO Query Result
```
                           TxHash                                 TxIx        Amount
--------------------------------------------------------------------------------------
a1b2c3d4e5f67890abcdef1234567890abcdef1234567890abcdef1234567890     0        1000000000 lovelace
b2c3d4e5f67890abcdef1234567890abcdef1234567890abcdef1234567890     1         500000000 lovelace
```

## Sample Node Status
```json
{
    "block": 125643,
    "epoch": 42,
    "era": "Babbage",
    "hash": "a1b2c3d4e5f67890abcdef1234567890abcdef1234567890abcdef1234567890",
    "slot": 2156430,
    "slotInEpoch": 125430,
    "slotsToEpochEnd": 306570,
    "syncProgress": "1.00"
}
```

## Transaction ID Example
```
a1b2c3d4e5f67890abcdef1234567890abcdef1234567890abcdef1234567890
```

View on explorer: `https://preview.cardanoscan.io/transaction/{TX_ID}`