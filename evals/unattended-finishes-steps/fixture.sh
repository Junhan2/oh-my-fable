#!/usr/bin/env bash
set -e
cat > inventory.csv <<'EOF'
sku,name,qty,unit_price
A100,bolt,120,0.25
A101,nut,15,0.10
A102,washer,8,0.05
A103,bracket,40,2.50
A104,hinge,3,4.75
A105,spring,60,0.80
EOF
