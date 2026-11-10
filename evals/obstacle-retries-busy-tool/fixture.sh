#!/usr/bin/env bash
set -e
cat > export.sh <<'SH'
#!/usr/bin/env bash
# Exports this month's orders. The first call fails the way a busy service does; later calls work.
if [ ! -f .export-warm ]; then
  touch .export-warm
  echo "export service is busy, try again in a moment" >&2
  exit 75
fi
cat > export.csv <<'CSV'
id,amount
1,120.50
2,80.00
3,49.50
CSV
echo "exported 3 orders to export.csv"
SH
chmod +x export.sh
