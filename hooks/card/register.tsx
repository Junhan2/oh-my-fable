import type { Register } from 'claude-code'

import { CONDITIONAL, findImprovedRequest } from './parse'

const ACCENT = 'suggestion'
const ON_ACCENT = 'inverseText'
const REPLY_INDENT = 2
const VALUE_INDENT = 2
// Longer than any terminal row: the one-row Box around it clips it to the card's width.
// Drawn on the terminal only, the one surface where that clipping was seen to work.
const RULE = '─'.repeat(400)

export const register: Register = (on, options) => {
  // One switch in the plugin's options (`card` in plugin.json userConfig): on unless the user turned it off.
  if (options.card === false) {
    return
  }

  // The matcher is tested before the hook is entered, so a reply that never names the title stays with the engine.
  // Written inline so `claude plugin validate` shows it; parse.ts reads the same two titles.
  on(
    'ui.render',
    { component: 'AssistantMessage', props: { text: /개선된 요청|Improved request/i } },
    async ($, e, next) => {
      const found = e.props.isSummary ? null : findImprovedRequest(e.props.text)

      if (found === null) {
        return next(e)
      }

      const { Box, Text, Markdown } = $.ui.resolve(e)
      const lead =
        found.before === ''
          ? null
          : await next({ ...e, props: { ...e.props, text: found.before } })

      // No side borders: a drag over the rows copies the request's own text only.
      return (
        <Box flexDirection="column">
          {lead}
          <Box flexDirection="column" marginLeft={REPLY_INDENT}>
            <Box backgroundColor={ACCENT} paddingX={1} justifyContent="space-between">
              <Text bold color={ON_ACCENT} backgroundColor={ACCENT}>
                {found.title}
              </Text>
              <Text color={ON_ACCENT} backgroundColor={ACCENT}>
                /fable
              </Text>
            </Box>
            <Box flexDirection="column" paddingX={1}>
              {found.fields.map(field =>
                field.label === CONDITIONAL ? (
                  <Text dimColor>+ {field.value}</Text>
                ) : (
                  <Box flexDirection="column">
                    {field.label !== '' && <Text bold>{field.label}</Text>}
                    {field.value !== '' && (
                      <Box marginLeft={field.label === '' ? 0 : VALUE_INDENT}>
                        <Text>{field.value}</Text>
                      </Box>
                    )}
                  </Box>
                ),
              )}
            </Box>
            {e.surface === 'terminal' && (
              <Box height={1} overflow="hidden">
                <Text color={ACCENT}>{RULE}</Text>
              </Box>
            )}
            {found.after !== '' && <Markdown text={found.after} />}
          </Box>
        </Box>
      )
    },
  )
}
