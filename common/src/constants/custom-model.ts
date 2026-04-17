/**
 * Custom OpenAI-compatible model constants.
 * Allows users to provide their own base URL and API key for local or specialized models.
 */

/** Environment variable for custom provider base URL. */
export const CUSTOM_MODEL_BASE_URL_ENV_VAR = 'CODEBUFF_CUSTOM_MODEL_BASE_URL'

/** Environment variable for custom provider API key. */
export const CUSTOM_MODEL_API_KEY_ENV_VAR = 'CODEBUFF_CUSTOM_MODEL_API_KEY'

/** Prefix for models that should use the custom provider. */
export const CUSTOM_MODEL_PREFIX = 'custom/'

/**
 * Check if a model should use the custom provider.
 */
export function isCustomModel(model: string): boolean {
  return model.startsWith(CUSTOM_MODEL_PREFIX)
}

/**
 * Extract the actual model ID from a custom model string.
 * Example: "custom/meta-llama/llama-3-70b-instruct" => "meta-llama/llama-3-70b-instruct"
 */
export function toCustomModelId(model: string): string {
  if (!isCustomModel(model)) {
    throw new Error(`Not a custom model: ${model}`)
  }
  return model.slice(CUSTOM_MODEL_PREFIX.length)
}
