import { expect, test } from 'claude-code/testing'

const PLUGIN = 'oh-my-fable'
const GOAL = '로그인 버튼을 누르면 /api/login 이 호출되고, 성공하면 /dashboard 로 이동하게 한다.'
const BLOCK = [
  '```',
  '개선된 요청',
  `목표: ${GOAL}`,
  '맥락: src/components/LoginButton.tsx, 콘솔 오류 "TypeError: onSubmit is not a function".',
  '범위: 이 버튼과 그 핸들러만. 다른 오류는 후속 과제로 보고.',
  '완료 기준: 실제 클릭을 재현해 /dashboard 이동 확인, 콘솔 오류 0.',
  '+ block H',
  '```',
].join('\n')
const REPLY = `요청을 다듬어 보여드린 뒤 바로 진행합니다.\n\n${BLOCK}\n\n이제 실행합니다.`

test('draws the improved request as a card on every surface', async ($, on) => {
  const engineTexts: string[] = []
  on('ui.render', { component: 'AssistantMessage' }, ($, e) => {
    engineTexts.push(e.props.text)
    const { Text } = $.ui.resolve(e)

    return Text({ children: `ENGINE ${e.props.text}` })
  })

  for (const surface of ['terminal', 'desktop', 'vscode', 'mobile'] as const) {
    const onTerminal = surface === 'terminal'
    const ui = await $.ui.mount({
      plugin: PLUGIN,
      surface,
      component: 'AssistantMessage',
      props: { text: REPLY, isFirstOfReply: true },
    })

    const title = await ui.find({ type: 'Text', text: '개선된 요청' })
    const boxes = await ui.findAll({ type: 'Box' })
    // The same lemon-lime band opens the card on every surface, and a blank row sets each field apart.
    expect(title?.props).toMatchObject({ bold: true, backgroundColor: '#DCF368' })
    expect(boxes.some(box => box.props.gap === 1 && box.props.paddingY === 1)).toBe(true)

    if (onTerminal) {
      // The character in the start screen's block glyphs and a rule, indented under the reply bullet, each value
      // as typed. No border: its side strokes would end up in every line a drag copies from the card.
      for (const row of [' ▐▛███▜▌ ', '▝▜█████▛▘', '  ▘▘ ▝▝  ']) {
        expect(await ui.find({ type: 'Text', text: row })).toBeDefined()
      }
      expect(boxes.every(box => box.props.borderStyle === undefined)).toBe(true)
      expect(boxes.some(box => box.props.flexDirection === 'column' && box.props.marginLeft === 2)).toBe(true)
      expect(await ui.find({ type: 'Text', text: GOAL })).toBeDefined()
    } else {
      // One drawn border closes the card off from the reply text, a blank row above and below it;
      // the character as a picture, each value as Markdown.
      expect(boxes.filter(box => box.props.borderStyle !== undefined).length).toBe(1)
      expect(boxes.find(box => box.props.borderStyle === 'round')?.props).toMatchObject({ marginTop: 1, marginBottom: 1 })
      expect((await ui.findAll({ type: 'Svg' })).map(svg => svg.props.alt).join()).toBe('Claude')
      expect(await ui.find({ type: 'Markdown', text: GOAL })).toBeDefined()
    }

    expect((await ui.findAll({ type: 'Text', text: /^(목표|맥락|범위|완료 기준)$/ })).length).toBe(4)
    expect(await ui.find({ type: 'Text', text: '+ block H' })).toBeDefined()
    expect(await ui.find({ type: 'Markdown', text: '이제 실행합니다.' })).toBeDefined()
    expect(await ui.find({ type: 'Text', text: /^ENGINE 요청을 다듬어/ })).toBeDefined()
    expect(await ui.find({ text: '```' })).toBeUndefined()
    expect((await ui.find({ type: 'Text', text: /^─+$/ })) !== undefined).toBe(onTerminal)
    await ui.unmount()
  }

  // With no text around the block there is nothing to set the card apart from.
  const alone = await $.ui.mount({
    plugin: PLUGIN,
    surface: 'desktop',
    component: 'AssistantMessage',
    props: { text: BLOCK, isFirstOfReply: true },
  })
  const aloneBoxes = await alone.findAll({ type: 'Box' })
  expect(aloneBoxes.some(box => box.props.marginTop === 1 || box.props.marginBottom === 1)).toBe(false)
  await alone.unmount()

  expect(engineTexts.every(text => text === '요청을 다듬어 보여드린 뒤 바로 진행합니다.')).toBe(true)
})

test('off the terminal, draws a value as written', async $ => {
  const text = [
    '```',
    '개선된 요청',
    '목표: src/**/*.ts 의 __init__ 호출을 `run_all(*args)` 로 바꾼다.',
    '범위:',
    '- 첫째 항목',
    '```',
  ].join('\n')
  const ui = await $.ui.mount({
    plugin: PLUGIN,
    surface: 'desktop',
    component: 'AssistantMessage',
    props: { text, isFirstOfReply: true },
  })

  // Outside a code span each mark gets a backslash, so Markdown shows it and does not read it as emphasis.
  const shown = 'src/\\*\\*/\\*.ts 의 \\_\\_init\\_\\_ 호출을 `run_all(*args)` 로 바꾼다.'
  expect(await ui.find({ type: 'Markdown', text: shown })).toBeDefined()
  expect(await ui.find({ type: 'Markdown', text: '- 첫째 항목' })).toBeDefined()
  await ui.unmount()
})

test('reads 배경 as a field name, as a real /fable run wrote it in place of 맥락', async $ => {
  const text = ['```', '개선된 요청', '목표: 한 줄', '배경:', '- 첫째 이유', '```'].join('\n')

  for (const surface of ['terminal', 'desktop'] as const) {
    const ui = await $.ui.mount({
      plugin: PLUGIN,
      surface,
      component: 'AssistantMessage',
      props: { text, isFirstOfReply: true },
    })

    expect(await ui.find({ type: 'Text', text: /^배경$/ })).toBeDefined()
    await ui.unmount()
  }
})

test('reads fields written as list items and sets the guide line apart, as a real /fable run wrote them', async $ => {
  const guide = "Report your findings and stop. Don't apply a fix until they ask for one."
  const text = [
    '```개선된 요청',
    '- 목표: 출시 전에 할 검증 항목과 마지막 개선안을 제안한다.',
    '- 맥락: 지금 상태는 PR #77, 체험은 금요일 오전까지.',
    '- 범위: 제안만 하고 코드는 고치지 않는다.',
    '- 완료 기준: 항목마다 맡을 사람과 통과 기준이 있다.',
    guide,
    '```',
  ].join('\n')

  for (const surface of ['terminal', 'desktop'] as const) {
    const ui = await $.ui.mount({
      plugin: PLUGIN,
      surface,
      component: 'AssistantMessage',
      props: { text, isFirstOfReply: true },
    })

    expect((await ui.findAll({ type: 'Text', text: /^(목표|맥락|범위|완료 기준)$/ })).length).toBe(4)
    expect((await ui.find({ type: 'Text', text: guide }))?.props).toMatchObject({ dimColor: true })
    await ui.unmount()
  }
})

test('reads a field name however a run decorates it: indented, as a list item, bold or as a heading', async $ => {
  const text = ['```', '개선된 요청', '  - 목표: 한 줄', '* **맥락**: 두 줄', '## 범위', '세 줄', '1. 완료 기준: 네 줄', '```'].join(
    '\n',
  )
  const ui = await $.ui.mount({
    plugin: PLUGIN,
    surface: 'terminal',
    component: 'AssistantMessage',
    props: { text, isFirstOfReply: true },
  })

  expect((await ui.findAll({ type: 'Text', text: /^(목표|맥락|범위|완료 기준)$/ })).length).toBe(4)
  await ui.unmount()
})

test('shows a block as written when it holds fewer than two of the field names the card knows', async $ => {
  // Japanese: only 背景 is a name the card knows, shared with Chinese.
  const body = '目的：ログイン後に移動する。\n背景：コンソールのエラー。\n範囲：このボタンだけ。'
  const ui = await $.ui.mount({
    plugin: PLUGIN,
    surface: 'terminal',
    component: 'AssistantMessage',
    props: { text: '```\nImproved request\n' + body + '\n```', isFirstOfReply: true },
  })

  expect(await ui.find({ type: 'Text', text: /^背景$/ })).toBeUndefined()
  expect(await ui.find({ type: 'Text', text: body })).toBeDefined()
  await ui.unmount()
})

test('leaves an ordinary reply, another code block and a summary row to the engine', async ($, on) => {
  on('ui.render', { component: 'AssistantMessage' }, ($, e) => {
    const { Text } = $.ui.resolve(e)

    return Text({ children: `ENGINE ${e.props.text}` })
  })

  const others = [
    { text: '그냥 답변입니다.', isFirstOfReply: true },
    { text: '```ts\nconst goal = 1\n```', isFirstOfReply: true },
    { text: REPLY, isFirstOfReply: false, isSummary: true as const },
  ]

  for (const props of others) {
    const ui = await $.ui.mount({ plugin: PLUGIN, surface: 'terminal', component: 'AssistantMessage', props })

    expect(await ui.find({ type: 'Text', text: `ENGINE ${props.text}` })).toBeDefined()
    expect(await ui.find({ type: 'Text', text: '/fable' })).toBeUndefined()
    await ui.unmount()
  }
})

test('reads labels written as headings, as a real /fable run printed them', async ($, on) => {
  on('ui.render', { component: 'AssistantMessage' }, ($, e) => {
    const { Text } = $.ui.resolve(e)

    return Text({ children: `ENGINE ${e.props.text}` })
  })

  const headings = [
    '```text',
    '개선된 요청',
    '',
    '목표',
    '함수 하나를 작성한다.',
    '',
    '맥락:',
    '- 가정 1: F(0)=0 으로 센다.',
    '- 가정 2: 반복문으로 계산한다.',
    '+ 가정은 바꿀 수 있다.',
    '',
    '범위',
    '- 포함: 함수 하나.',
    '',
    '완료 기준',
    '아래를 실행해 통과한다.',
    '',
    'After writing the function, review it: are there any bugs?',
    '```',
  ].join('\n')
  const ui = await $.ui.mount({
    plugin: PLUGIN,
    surface: 'terminal',
    component: 'AssistantMessage',
    props: { text: headings, isFirstOfReply: true },
  })
  const labels = await ui.findAll({ type: 'Text', text: /^(목표|맥락|범위|완료 기준)$/ })

  expect(labels.length).toBe(4)
  expect(labels.every(label => label.props.bold === true)).toBe(true)
  expect(await ui.find({ type: 'Text', text: '- 가정 1: F(0)=0 으로 센다.\n- 가정 2: 반복문으로 계산한다.' })).toBeDefined()
  expect(
    await ui.find({ type: 'Text', text: '아래를 실행해 통과한다.\n\nAfter writing the function, review it: are there any bugs?' }),
  ).toBeDefined()

  // A conditional line stays where it was written, between the rows around it.
  const shown = (await ui.findAll({ type: 'Text' })).map(text => text.text)
  const conditionalAt = shown.indexOf('+ 가정은 바꿀 수 있다.')
  expect(conditionalAt > shown.indexOf('맥락') && conditionalAt < shown.indexOf('범위')).toBe(true)
  await ui.unmount()
})

test('reads a title written on the fence, inside or above it, with field names in Korean, English and Chinese', async ($, on) => {
  on('ui.render', { component: 'AssistantMessage' }, ($, e) => {
    const { Text } = $.ui.resolve(e)

    return Text({ children: `ENGINE ${e.props.text}` })
  })

  const onFence = '```개선된 요청\n개선된 요청\n목표: 파일을 읽는다.\n맥락: 없음\n범위: 읽기만\n완료 기준: 원문 인용\n```'
  const above = '**Improved request**\n```text\nImproved request\nGoal: ship it\nContext: none\nScope: one file\nDone criteria: tests pass\n```'
  // /fable writes the field names in the user's language.
  const inside = '```\nImproved request\n目标：调用 /api/login。\n上下文：控制台错误。\n范围：只改这个按钮。\n完成标准：控制台错误为 0。\n```'

  for (const [text, title, labels] of [
    [onFence, '개선된 요청', /^(목표|맥락|범위|완료 기준)$/],
    [above, 'Improved request', /^(Goal|Context|Scope|Done criteria)$/],
    [inside, 'Improved request', /^(目标|上下文|范围|完成标准)$/],
  ] as const) {
    const ui = await $.ui.mount({
      plugin: PLUGIN,
      surface: 'terminal',
      component: 'AssistantMessage',
      props: { text, isFirstOfReply: true },
    })

    expect((await ui.findAll({ type: 'Text', text: title })).length).toBe(1)
    expect((await ui.findAll({ type: 'Text', text: labels })).length).toBe(4)
    expect(await ui.find({ type: 'Text', text: /^ENGINE/ })).toBeUndefined()
    await ui.unmount()
  }
})

test('draws no card when the card option is off', { options: { card: false } }, async ($, on) => {
  on('ui.render', { component: 'AssistantMessage' }, ($, e) => {
    const { Text } = $.ui.resolve(e)

    return Text({ children: `ENGINE ${e.props.text}` })
  })

  const ui = await $.ui.mount({
    plugin: PLUGIN,
    surface: 'terminal',
    component: 'AssistantMessage',
    props: { text: REPLY, isFirstOfReply: true },
  })

  expect(await ui.find({ type: 'Text', text: `ENGINE ${REPLY}` })).toBeDefined()
  expect(await ui.find({ type: 'Text', text: '/fable' })).toBeUndefined()
  await ui.unmount()
})
