#!/usr/bin/env bash
set -e
cat > calc.py <<'EOF'
"""Small arithmetic helpers."""


def add(a, b):
    return a - b


def negate(a):
    return -a
EOF
