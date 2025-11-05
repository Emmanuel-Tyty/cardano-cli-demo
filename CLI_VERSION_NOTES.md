# Cardano CLI Version Differences 📝

## Command Structure Changes

In newer versions of cardano-cli (10.x+), some commands have moved to era-specific subcommands:

### Stake Address Commands
**Old syntax (doesn't work):**
```bash
cardano-cli stake-address key-gen ...
cardano-cli stake-address build ...
```

**New syntax (works):**
```bash
cardano-cli conway stake-address key-gen ...
cardano-cli conway stake-address build ...
```

### Why the Change?
1. **Era-specific features**: Different Cardano eras have different staking capabilities
2. **Conway governance**: Latest era introduces governance features
3. **Better organization**: Commands grouped by blockchain era for clarity

### Era Commands Available
- `byron` - Byron era (original Cardano)
- `shelley` - Shelley era (staking introduced)  
- `allegra` - Allegra era (native tokens)
- `mary` - Mary era (multi-asset)
- `alonzo` - Alonzo era (smart contracts)
- `babbage` - Babbage era (Plutus V2)
- `conway` - Conway era (governance) ← **Current**

### Address Types Generated
Using the correct commands, you can create:

1. **Enterprise Address** (payment only):
   ```
   addr_test1vpcln6ynvv57g4c27yr2r2ankx9wfxmczxtpeatewr8vuks3f6a5z
   ```

2. **Base Address** (payment + staking):
   ```
   addr_test1qpcln6ynvv57g4c27yr2r2ankx9wfxmczxtpeatewr8vuk5y99ft63fpu23he8guvusmcx5epg3n35yp0vncef2nw2hs7zu3x8
   ```

3. **Stake Address** (rewards only):
   ```
   stake_test1uzzzj54ag5s79gmun5wxwgdur2vs5gec6zqhkfuv54fh9tccvxgha
   ```

### Notice the Prefixes
- Enterprise: `addr_test1v...` (payment only)
- Base: `addr_test1q...` (payment + stake) 
- Stake: `stake_test1u...` (rewards)

The different prefixes help identify the address type immediately!