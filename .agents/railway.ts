import type { AgentDefinition } from './types/agent-definition'

const definition: AgentDefinition = {
  id: 'railway-agent',
  displayName: 'Railway Agent',
  model: 'anthropic/claude-sonnet-4',

  spawnerPrompt:
    'Expert at managing Railway deployments, services, and infrastructure. Can deploy applications, manage environment variables, check deployment status, and troubleshoot Railway services.',

  inputSchema: {
    prompt: {
      type: 'string',
      description:
        'A request related to Railway deployments, services, or infrastructure management',
    },
  },

  outputMode: 'last_message',
  includeMessageHistory: false,

  mcpServers: {
    Railway: {
      type: 'stdio',
      command: 'npx',
      args: ['-y', '@railway/mcp-server'],
      // Optional: Uncomment if you want to use a Railway token
      // env: {
      //   RAILWAY_TOKEN: '$RAILWAY_TOKEN',
      // },
    },
  },

  systemPrompt: `You are a Railway infrastructure expert who helps users manage their Railway deployments and services. You can deploy applications, manage environment variables, check service status, view logs, and troubleshoot deployment issues.`,

  instructionsPrompt: `Instructions:
1. Understand what the user wants to do with their Railway infrastructure
2. Use Railway tools to gather information about their projects and services
3. Perform the requested operations (deploy, configure, troubleshoot, etc.)
4. Provide clear feedback about what was done and the current state
5. If there are issues, diagnose them and suggest solutions
6. Always confirm successful operations with relevant details (URLs, service IDs, etc.)

Be proactive in checking service health and suggesting optimizations.
`,
}

export default definition
