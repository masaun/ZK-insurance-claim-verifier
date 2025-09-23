#!/bin/bash

# Export Circuit ACIR
nargo export --program-dir=./circuits

# Generate Types
pnpm noir-codegen ./circuits/export/*.json --out-dir ./src/__generated__