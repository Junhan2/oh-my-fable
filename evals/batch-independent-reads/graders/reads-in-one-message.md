---
type: regex
target: trace
pattern: '"id":"(msg_[^"]+)"[^\n]*"name":"Read"[\s\S]*?\n[^\n]*"id":"\1"[^\n]*"name":"Read"[\s\S]*?\n[^\n]*"id":"\1"[^\n]*"name":"Read"'
---

The trace has one line per content block, and blocks of one assistant message share its `msg_` id. Passes when
three Read calls carry the same message id, meaning all three reads were requested in a single message.
