/** The label a conditional line (`+ block H`) is filed under. */
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
const TITLE = /^(?:#+\s*|\*\*|__)?(개선된 요청|Improved request)(?:\*\*|__)?\s*[:：]?$/i
const FENCE = /^(`{3,}|~{3,})([^\n]*)\n([\s\S]*?)\n\1[ \t]*$/gm
const FIELD = /^(목표|맥락|범위|완료 기준|완료기준|Goal|Context|Scope|Done criteria|Done)\s*(?:[:：]\s*(.*))?$/i
const EXTRA = /^(\+)\s*(.+)$/

const titleOf = (line = ''): string | undefined => TITLE.exec(line.trim())?.[1]

/** Splits the block's lines into rows: a label or a `+` opens a row, any other line continues the row above. */
function parseBody(lines: readonly string[]): RequestField[] {
  const rows = [{ label: '', lines: [] as string[] }]

  for (const line of lines) {
    const opened = FIELD.exec(line) ?? EXTRA.exec(line)

    if (opened === null) {
      rows.at(-1)?.lines.push(line.trimEnd())
    } else {
      rows.push({ label: opened[1] ?? '', lines: [opened[2] ?? ''] })
    }
  }

  return rows
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
