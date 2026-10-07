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
    const ui = await $.ui.mount({
      plugin: PLUGIN,
      surface,
      component: 'AssistantMessage',
      props: { text: REPLY, isFirstOfReply: true },
    })

    const title = await ui.find({ type: 'Text', text: '개선된 요청' })
    expect(title?.props).toMatchObject({ bold: true, backgroundColor: 'suggestion' })
    // A side border would end up in every line a drag copies from the card.
    expect((await ui.findAll({ type: 'Box' })).every(box => box.props.borderStyle === undefined)).toBe(true)
    expect(await ui.find({ type: 'Box', text: GOAL })).toBeDefined()
    expect((await ui.findAll({ type: 'Text', text: /^(목표|맥락|범위|완료 기준)$/ })).length).toBe(4)
    expect(await ui.find({ type: 'Text', text: '+ block H' })).toBeDefined()
    expect(await ui.find({ type: 'Markdown', text: '이제 실행합니다.' })).toBeDefined()
    expect(await ui.find({ type: 'Text', text: /^ENGINE 요청을 다듬어/ })).toBeDefined()
    expect(await ui.find({ text: '```' })).toBeUndefined()
    expect((await ui.find({ type: 'Text', text: /^─+$/ })) !== undefined).toBe(surface === 'terminal')
    await ui.unmount()
  }

  expect(engineTexts.every(text => text === '요청을 다듬어 보여드린 뒤 바로 진행합니다.')).toBe(true)
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

test('reads a title written on the fence or above it, in Korean and English', async ($, on) => {
  on('ui.render', { component: 'AssistantMessage' }, ($, e) => {
    const { Text } = $.ui.resolve(e)

    return Text({ children: `ENGINE ${e.props.text}` })
  })

  const onFence = '```개선된 요청\n개선된 요청\n목표: 파일을 읽는다.\n맥락: 없음\n범위: 읽기만\n완료 기준: 원문 인용\n```'
  const above = '**Improved request**\n```text\nImproved request\nGoal: ship it\nContext: none\nScope: one file\nDone criteria: tests pass\n```'

  for (const [text, title, labels] of [
    [onFence, '개선된 요청', /^(목표|맥락|범위|완료 기준)$/],
    [above, 'Improved request', /^(Goal|Context|Scope|Done criteria)$/],
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
