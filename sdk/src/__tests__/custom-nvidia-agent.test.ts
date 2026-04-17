const CUSTOM_MODEL_PREFIX = 'custom/'
const isCustomModel = (model) => model.startsWith(CUSTOM_MODEL_PREFIX)
const toCustomModelId = (model) =>
  model.startsWith(CUSTOM_MODEL_PREFIX)
    ? model.slice(CUSTOM_MODEL_PREFIX.length)
    : model

describe('custom nvidia agent model routing', () => {
  test('nvidia-llama agent uses the custom provider', () => {
    const model = 'custom/meta/llama-3.1-405b-instruct'

    expect(isCustomModel(model)).toBe(true)
    expect(toCustomModelId(model)).toBe('meta/llama-3.1-405b-instruct')
  })
})
