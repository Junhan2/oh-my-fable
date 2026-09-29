---
type: regex
target: { source: file, path: calc.py }
pattern: 'def add\(a, b\):\s*\n\s+return (a \+ b|b \+ a)\s*$'
flags: m
---
