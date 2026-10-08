import type { Register, RenderChildren } from 'claude-code'

import { CONDITIONAL, findImprovedRequest } from './parse'

const REPLY_INDENT = 2
const VALUE_INDENT = 2
// Longer than any terminal row: the one-row Box around it clips it to the card's width.
// Drawn on the terminal only, the one surface where that clipping was seen to work.
const RULE = '─'.repeat(400)

// Raw colors, since no theme key is these hues: a lemon-lime band with dark text that reads on it in a light
// theme and in a dark one, a shade under it for the tag and the desktop border, a deeper one for the terminal's
// closing rule (it sits on the terminal's own background, light or dark), and the character's clay.
const BAND = '#DCF368'
const ON_BAND = '#2A3300'
const EDGE = '#C8E34A'
const LINE = '#9DB82F'
const CLAY = '#D77757'
// Claude Code's character, redrawn from its three-row banner art on a 16 x 10 grid (body and arms, four feet,
// two eyes), with three empty rows above and below so the band has room around it.
const CHARACTER =
  '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16" shape-rendering="crispEdges">' +
  `<path fill="${CLAY}" d="M2 3h12v4h2v2h-2v2H2V9H0V7h2zM3 11h1v2H3zM5 11h1v2H5zM10 11h1v2h-1zM12 11h1v2h-1z"/>` +
  `<path fill="${ON_BAND}" d="M4 5h1v2H4zM11 5h1v2h-1z"/></svg>`
// CSS pixels, each way. The band is as tall as this picture.
const CHARACTER_SIZE = 32
// The same character on the terminal: its start-screen art in block glyphs, three rows tall. One row of it
// reads as a bar with two notches, not as the character.
const CHARACTER_ROWS = [' ▐▛███▜▌ ', '▝▜█████▛▘', '  ▘▘ ▝▝  ']
// One code span, kept as it is, or one mark Markdown would read as emphasis, a heading, a quote, a table,
// a link or HTML, which gets a backslash so it shows as typed. List items opened with `-` or a number keep
// their meaning; an item opened with a star shows the star.
const MARKS = /(`[^`\n]+`)|[\\*_~<>#|[\]]/g

const asMarkdown = (value: string): string =>
  value.replace(MARKS, (mark: string, code?: string) => code ?? `\\${mark}`)

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
      const tail = found.after === '' ? null : <Markdown text={found.after} />
      // Inside the card the terminal keeps one column clear at each side, the desktop two.
      const inset = e.surface === 'terminal' ? 1 : 2
      // The band that opens the card on every surface: the character, the title, and the /fable tag.
      const band = (character: RenderChildren) => (
        <Box backgroundColor={BAND} paddingX={inset} justifyContent="space-between" alignItems="center">
          <Box alignItems="center" gap={1}>
            {character}
            <Text bold color={ON_BAND} backgroundColor={BAND}>
              {found.title}
            </Text>
          </Box>
          <Text color={ON_BAND} backgroundColor={EDGE}>
            {' /fable '}
          </Text>
        </Box>
      )
      // The fields, a blank row around and between them, each name in bold over its value; each surface
      // passes the way it draws a value.
      const rows = (drawValue: (value: string, isUnderName: boolean) => RenderChildren) => (
        <Box flexDirection="column" gap={1} paddingX={inset} paddingY={1}>
          {found.fields.map(field =>
            field.label === CONDITIONAL ? (
              <Text dimColor>{field.value}</Text>
            ) : (
              <Box flexDirection="column">
                {field.label !== '' && <Text bold>{field.label}</Text>}
                {field.value !== '' && drawValue(field.value, field.label !== '')}
              </Box>
            ),
          )}
        </Box>
      )

      if (e.surface !== 'terminal') {
        const { Svg } = $.ui.resolve(e)

        // A border is drawn here, not typed, so it can close the card off from the reply text around it
        // without ending up in what a drag copies. The band sits flush inside it; a blank row separates
        // the card from the text on either side. A value reads as Markdown, the way the reply around it does.
        return (
          <Box flexDirection="column">
            {lead}
            <Box
              flexDirection="column"
              borderStyle="round"
              borderColor={EDGE}
              overflow="hidden"
              marginTop={lead === null ? 0 : 1}
              marginBottom={tail === null ? 0 : 1}
            >
              {band(<Svg source={CHARACTER} alt="Claude" width={CHARACTER_SIZE} height={CHARACTER_SIZE} />)}
              {rows(value => <Markdown text={asMarkdown(value)} />)}
            </Box>
            {tail}
          </Box>
        )
      }

      // No side borders on the terminal: they would end up in every line a drag copies from the card.
      // The band opens it with the character as on the start screen, the title level with its middle row,
      // and a rule closes it, indented under the reply bullet. A blank row sets each field apart, as on the
      // desktop. A value shows as typed, so a drag copies the request's own text.
      return (
        <Box flexDirection="column">
          {lead}
          <Box flexDirection="column" marginLeft={REPLY_INDENT}>
            {band(
              <Box flexDirection="column">
                {CHARACTER_ROWS.map(row => (
                  <Text color={CLAY} backgroundColor={BAND}>
                    {row}
                  </Text>
                ))}
              </Box>,
            )}
            {rows((value, isUnderName) => (
              <Box marginLeft={isUnderName ? VALUE_INDENT : 0}>
                <Text>{value}</Text>
              </Box>
            ))}
            <Box height={1} overflow="hidden">
              <Text color={LINE}>{RULE}</Text>
            </Box>
            {tail}
          </Box>
        </Box>
      )
    },
  )
}
