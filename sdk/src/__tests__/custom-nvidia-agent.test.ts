import { describe, expect, test } from 'bun:test'

import {
  isCustomModel,
  toCustomModelId,
} from '@codebuff/common/constants/custom-model'

describe('custom nvidia agent model routing', () => {
  test('nvidia-llama agent uses the custom provider', () => {
    const model = 'custom/meta/llama-3.1-405b-instruct'

    expect(isCustomModel(model)).toBe(true)
    expect(toCustomModelId(model)).toBe('meta/llama-3.1-405b-instruct')
  })
})
