#!/usr/bin/env bash
set -euo pipefail

rm -rf .mooncakes.io
moon update
moon remove Luna-Flow/luna-generic
moon remove Luna-Flow/arithmetic
moon add Luna-Flow/luna-generic
moon add Luna-Flow/arithmetic
moon install
