import type { AgentDefinition } from '@codebuff/common/templates/initial-agents-dir/types/agent-definition'

/**
 * Nvidia Llama‑3.1‑405B custom model agent.
 * Uses the custom provider (CODEBUFF_CUSTOM_MODEL_* env vars).
 */
const nvidiaAgent: AgentDefinition = {
  // Unique identifier for the CLI (--agent) and marketplace
  id: 'nvidia-llama',
  displayName: 'Nvidia Llama‑3.1‑405B (Instruct)',
  // Prefix "custom/" tells Codebuff to route through the custom model provider
  model: 'custom/meta/llama-3.1-405b-instruct',
  systemPrompt:
    'You are a helpful coding assistant powered by Nvidia NIM. Answer concisely and include code examples when appropriate.',
  instructionsPrompt: 'Help the user with their coding task.',
  // Minimal tool set – can be expanded later if needed
  toolNames: ['read_file', 'write_file', 'search_files'],
  // Optional fine‑tuning parameters (keep defaults unless you have a reason)
  // temperature: 0.7,
  // maxTokens: 2048,
};

export default nvidiaAgent;
