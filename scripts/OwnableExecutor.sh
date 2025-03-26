#!/bin/bash

# Load environment variables from .env safely
if [ -f .env ]; then
    set -a  # Export all variables automatically
    source .env
    set +a
fi

# Ensure chain.json exists
CHAIN_JSON="./scripts/assets/chain.json"
if [ ! -f "$CHAIN_JSON" ]; then
    echo "❌ Error: Missing chain.json file!"
    exit 1
fi

jq -c 'to_entries[]' "$CHAIN_JSON" | while IFS= read -r entry; do
    chainID=$(echo "$entry" | jq -r '.key')
    value=$(echo "$entry" | jq -c '.value')

    RPC_URL=$(echo "$value" | jq -c '.url')

    if [[ "$RPC_URL" == "null" || -z "$RPC_URL" ]]; then
        echo "⚠️  Warning: No RPC URL found for Chain ID $CHAIN_ID. Skipping..."
        continue
    fi

    # Replace environment variable placeholders if necessary
    RPC_URL=$(eval echo "$RPC_URL")
    
    if [[ "$RPC_URL" == *"${ALCHEMY_API_KEY}"* && -z "$ALCHEMY_API_KEY" ]]; then
        echo "❌ Error: ALCHEMY_API_KEY is required but not set."
        exit 1
    fi
    echo "RPC_URL: $RPC_URL"

    EXECUTOR_ADDRESS="0x4Fd8d57b94966982B62e9588C27B4171B55E8354"
    CODE=$(cast code $EXECUTOR_ADDRESS --rpc-url "$RPC_URL")
    if [ "$CODE" == "0x" ]; then
        echo "🔄 Deploying Ownable Executor on Chain ID: $chainID"
        cast send 0x000000000069E2a187AEFFb852bF3cCdC95151B2 \
            0x03b79c840000000000000000000000000000000000000000000000000000000000001337dbca873b13c783c0c9c6ddfc4280e505580bf6cc3dac83f8a0f7b44acaafca4f \
            --rpc-url "$RPC_URL" --private-key "$PRIVATE_KEY" || 
            { 
                echo "❌ Failed to deploy Ownable Executor on Chain ID: $chainID" >&2
                exit 1
            }
        echo "✅ Ownable Executor deployed on Chain ID: $chainID"
    else
        echo "✅ Ownable Executor already deployed on Chain ID: $chainID"
    fi
done