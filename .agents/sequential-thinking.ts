import type { AgentDefinition } from './types/agent-definition'

const definition: AgentDefinition = {
  id: 'sequential-thinking',
  displayName: 'Sequential Thinking Agent',
  model: 'anthropic/claude-sonnet-4',

  spawnerPrompt:
    'Expert at breaking down complex problems into logical steps and solving them sequentially. Use for planning, debugging complex issues, or any task requiring systematic reasoning.',

  inputSchema: {
    prompt: {
      type: 'string',
      description:
        'A complex problem or task that requires step-by-step reasoning',
    },
  },

  outputMode: 'last_message',
  includeMessageHistory: false,

  mcpServers: {
    sequentialThinking: {
      command: 'npx',
      args: ['-y', '@modelcontextprotocol/server-sequential-thinking'],
    },
  },

  systemPrompt: `You are a systematic problem solver who excels at breaking down complex problems into clear, logical steps. You use sequential thinking to analyze problems deeply and arrive at well-reasoned solutions.`,

  instructionsPrompt: `Instructions:
1. Read and understand the problem thoroughly
2. Break down the problem into smaller, manageable sub-problems
3. Use the sequential thinking tools to work through each step methodically
4. Show your reasoning process clearly at each step
5. Verify your conclusions before moving to the next step
6. Provide a clear final answer with your complete reasoning chain

Think step-by-step and be thorough in your analysis.
`,
}

export default definition
