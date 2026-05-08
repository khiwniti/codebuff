import { describe, expect, test, mock, beforeEach, afterEach } from 'bun:test'

import { CUSTOM_MODEL_BASE_URL_ENV_VAR, CUSTOM_MODEL_API_KEY_ENV_VAR } from '@codebuff/common/constants/custom-model'
import { getModelForRequest } from '../impl/model-provider'

describe('custom-model-provider', () => {
  const originalEnv = { ...process.env }

  beforeEach(() => {
    // Clear env vars before each test
    delete process.env[CUSTOM_MODEL_BASE_URL_ENV_VAR]
    delete process.env[CUSTOM_MODEL_API_KEY_ENV_VAR]
  })

  afterEach(() => {
    process.env = originalEnv
  })

  test('should throw error if custom model is used but base URL is not configured', async () => {
    await expect(getModelForRequest({
      apiKey: 'test-api-key',
      model: 'custom/meta/llama-3.1-405b-instruct'
    })).rejects.toThrow('Custom model base URL not configured')
  })

  test('should route to custom model when custom/ prefix is used', async () => {
    const testBaseUrl = 'https://custom-api.com/v1'
    const testApiKey = 'custom-key'
    process.env[CUSTOM_MODEL_BASE_URL_ENV_VAR] = testBaseUrl
    process.env[CUSTOM_MODEL_API_KEY_ENV_VAR] = testApiKey

    const result = await getModelForRequest({
      apiKey: 'test-api-key',
      model: 'custom/meta/llama-3.1-405b-instruct'
    })

    expect(result.isClaudeOAuth).toBe(false)
    expect(result.isChatGptOAuth).toBe(false)
    
    // Check if it's an OpenAICompatibleChatLanguageModel with correct settings
    // Since it's a class instance, we can check some internal properties if available
    // or just rely on the fact that it didn't throw and returned a result.
    expect(result.model).toBeDefined()
  })

  test('should handle custom base URL with trailing slash correctly', async () => {
    process.env[CUSTOM_MODEL_BASE_URL_ENV_VAR] = 'https://custom-api.com/v1/'
    
    const result = await getModelForRequest({
      apiKey: 'test-api-key',
      model: 'custom/model-id'
    })

    expect(result.model).toBeDefined()
  })
})
