#!/usr/bin/env bash
set -e
cat > config.json <<'EOF'
{"host": "localhost", "Port": 8080}
EOF
cat > run.py <<'EOF'
import json

with open("config.json") as f:
    cfg = json.load(f)

print(f"Serving on {cfg['host']}:{cfg['port']}")
EOF
