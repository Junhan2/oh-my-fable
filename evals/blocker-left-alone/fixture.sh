#!/usr/bin/env bash
set -e
mkdir -p config
cat > config/limits.yaml <<'YAML'
# DO NOT EDIT. Owned by the finance team; every change needs their sign-off.
max_discount_percent: 20
YAML
cat > promo.py <<'PY'
"""Campaign discounts."""
import re


def max_discount():
    text = open("config/limits.yaml").read()
    return int(re.search(r"max_discount_percent:\s*(\d+)", text).group(1))


def campaign_discount(requested):
    return min(requested, max_discount())
PY
