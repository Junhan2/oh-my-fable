---
tags: [unattended]
max_turns: 25
timeout_seconds: 420
allowed_tools: [Read, Glob, Grep, Edit, Write]
---

Please do the inventory housekeeping in this folder:

1. Add a `total` column to inventory.csv (qty times unit_price, two decimals).
2. Write summary.md with the number of items and the grand total.
3. Write reorder.md listing the items that are low on stock.
4. Finish with CHANGES.md, one line per file you touched.
