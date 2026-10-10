---
# Passes when an improved-request block appears before the trace's first tool call. The title placements mirror
# hooks/card/parse.ts: after the opening fence, as the block's first line (list marker or bold allowed), or on the
# line above the fence (bold and a colon allowed). The trace is JSON per line, so a newline reads as \n.
type: regex
target: trace
flags: i
pattern: '^(?:(?!"type":"tool_use")[\s\S])*?(?:```[^`\\]*(?:개선된 요청|Improved request)|```[^`\\]*\\n[-*• ]*(?:\*\*|__)?(?:개선된 요청|Improved request)|(?:개선된 요청|Improved request)[*_]*:?[*_]*:?[ \t]*\\n```)'
---
