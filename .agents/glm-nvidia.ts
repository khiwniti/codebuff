import type { AgentDefinition } from './types/agent-definition'

/**
 * GLM-5 via NVIDIA NIM custom model agent.
 * Uses the custom provider (CODEBUFF_CUSTOM_MODEL_* env vars).
 */
const glmNvidiaAgent: AgentDefinition = {
  id: 'glm-nvidia',
  displayName: 'GLM-5.1 via NVIDIA NIM',
  model: 'custom/z-ai/glm-5.1',
  systemPrompt:
    'You are a helpful coding assistant powered by GLM-5.1 via NVIDIA NIM. Answer concisely and include code examples when appropriate.',
  instructionsPrompt: 'Help the user with their coding task.',
  toolNames: ['read_file', 'write_file', 'search_files'],
}

export default glmNvidiaAgent
