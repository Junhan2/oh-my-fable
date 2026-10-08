/** The label a conditional line is filed under: a guide line /fable appends after the four fields, or a `+` line. */
export const CONDITIONAL = '+'

/** One row of the improved request: a field name, CONDITIONAL, or '' for text under no label. */
export type RequestField = { label: string; value: string }

/** The improved request found in one assistant message, with the reply text around it. */
export type ImprovedRequest = {
  title: string
  fields: RequestField[]
  before: string
  after: string
}

// The two titles are also written in register.tsx, in the matcher that decides which replies reach the hook.
const TITLE = /^(개선된 요청|Improved request)\s*[:：]?$/i
const FENCE = /^(`{3,}|~{3,})([^\n]*)\n([\s\S]*?)\n\1[ \t]*$/gm
// A field name opens its row, alone or before a colon. /fable writes the names in the user's language.
const FIELD =
  /^(목표|맥락|배경|범위|완료 기준|완료기준|Goal|Context|Background|Scope|Done criteria|Done|目标|上下文|背景|范围|完成标准)\s*(?:[:：]\s*(.*))?$/i
// A conditional line: one opened with `+`, or one of the English guide lines /fable appends after the fields,
// known by how it opens (skills/fable/SKILL.md and references/prompt-blocks.md). The lines under it stay with it.
const EXTRA =
  /^(?:\+\s*\S|Report your findings and stop|Exception: when the user is describing|Please remove all mannered prose|Mannered prose substitutes|Everything produced in one reply|When a query centers on a name|Use the search tool to check specifics|<example>)/

/** A line's words without the marks that vary between runs: indentation, a list marker, a heading's #, bold around its start. */
const plain = (line: string): string =>
  line
    .trim()
    .replace(/^(?:[-*•]\s+|\d+[.)]\s+|#+\s*)/, '')
    .replace(/^(\*\*|__)(.+?)\1/, '$2')

const titleOf = (line = ''): string | undefined => TITLE.exec(plain(line))?.[1]

/** Splits the block's lines into rows: a field name or a conditional line opens a row, any other line continues the row above. */
function parseBody(lines: readonly string[]): RequestField[] {
  const rows = [{ label: '', lines: [] as string[] }]

  for (const line of lines) {
    const words = plain(line)
    const field = FIELD.exec(words)

    if (field !== null) {
      rows.push({ label: field[1] ?? '', lines: [field[2] ?? ''] })
    } else if (EXTRA.test(words)) {
      rows.push({ label: CONDITIONAL, lines: [words] })
    } else {
      rows.at(-1)?.lines.push(line.trimEnd())
    }
  }

  // A name another language happens to share (背景 in Japanese, 上下文 in Traditional Chinese) would file the lines
  // after it under the wrong field, so a block with fewer than two of the names this card knows shows as written.
  const isNamed = rows.filter(row => row.label !== '' && row.label !== CONDITIONAL).length >= 2
  const shown = isNamed ? rows : [{ label: '', lines: lines.map(line => line.trimEnd()) }]

  return shown
    .map(row => ({ label: row.label, value: row.lines.join('\n').replace(/^\n+|\n+$/g, '') }))
    .filter(row => row.label !== '' || row.value !== '')
}

/**
 * Finds the fenced block /fable prints. Real runs write its title in three
 * places, sometimes in two of them at once: after the opening fence, as the
 * block's first line, or on the line right above the fence. Returns null for
 * any other reply.
 */
export function findImprovedRequest(text: string): ImprovedRequest | null {
  for (const fence of text.matchAll(FENCE)) {
    const bodyLines = (fence[3] ?? '').split('\n')
    const aboveLines = text.slice(0, fence.index).trimEnd().split('\n')
    const inside = titleOf(bodyLines[0])
    const above = titleOf(aboveLines.at(-1))
    const title = titleOf(fence[2]) ?? inside ?? above

    if (title === undefined) {
      continue
    }

    return {
      title,
      fields: parseBody(inside === undefined ? bodyLines : bodyLines.slice(1)),
      before: (above === undefined ? aboveLines : aboveLines.slice(0, -1)).join('\n').trim(),
      after: text.slice(fence.index + fence[0].length).trim(),
    }
  }

  return null
}
