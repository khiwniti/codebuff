#!/usr/bin/env bun

/**
 * Openbuff CLI - Standalone AI Coding Agent
 * 
 * Full OpenTUI Terminal with NVIDIA NIM support
 * No account required!
 */

import { spawn, execSync } from 'child_process'
import { existsSync, readFileSync, mkdirSync, writeFileSync } from 'fs'
import { join, dirname } from 'path'
import { fileURLToPath } from 'url'
import { homedir } from 'os'

// ES Module equivalent of __dirname
const __filename = fileURLToPath(import.meta.url)
const __dirname = dirname(__filename)

// ============================================================================
// ANSI Colors
// ============================================================================

const C = {
  cyan: '\x1b[36m',
  reset: '\x1b[0m',
  bright: '\x1b[1m',
  dim: '\x1b[2m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  red: '\x1b[31m',
}

const BANNER = `

${C.cyan}╔════════════════════════════════════════════════════════════════════╗${C.reset}
${C.cyan}║${C.reset}                                                                    ${C.cyan}║${C.reset}
${C.cyan}║${C.reset}   ${C.bright}${C.cyan}██████╗  ██████╗ ██████╗ ██████╗${C.reset}                       ${C.cyan}║${C.reset}
${C.cyan}║${C.reset}   ${C.bright}${C.cyan}██╔════╝ ██╔══██╗██╔══██╗██╔══██╗${C.reset}                       ${C.cyan}║${C.reset}
${C.cyan}║${C.reset}   ${C.bright}${C.cyan}██║  ████╔╝██████╔╝██║  ██║${C.reset}                       ${C.cyan}║${C.reset}
${C.cyan}║${C.reset}   ${C.bright}${C.cyan}██║   ██║██╔══██║██║  ██║${C.reset}                       ${C.cyan}║${C.reset}
${C.cyan}║${C.reset}   ${C.bright}${C.cyan}╚██████╔╝██║  ██║╚██████╔╝${C.reset}                       ${C.cyan}║${C.reset}
${C.cyan}║${C.reset}   ${C.dim} ╚═════╝ ╚═╝  ╚═╝ ╚═════╝${C.reset}                        ${C.cyan}║${C.reset}
${C.cyan}║${C.reset}                                                                    ${C.cyan}║${C.reset}
${C.cyan}║${C.reset}   ${C.bright}Openbuff - AI Coding Assistant${C.reset}                            ${C.cyan}║${C.reset}
${C.cyan}║${C.reset}   ${C.dim}NVIDIA NIM powered • No account required${C.reset}                   ${C.cyan}║${C.reset}
${C.cyan}║${C.reset}                                                                    ${C.cyan}║${C.reset}
${C.cyan}╚════════════════════════════════════════════════════════════════════╝${C.reset}
`

// ============================================================================
// Paths
// ============================================================================

const CONFIG_DIR = join(homedir(), '.openbuff')
const CONFIG_FILE = join(CONFIG_DIR, 'config.json')

// ============================================================================
// Config Management  
// ============================================================================

function loadConfig() {
  try {
    if (existsSync(CONFIG_FILE)) {
      return JSON.parse(readFileSync(CONFIG_FILE, 'utf8'))
    }
  } catch {}
  return { providers: {}, defaultModel: null }
}

function saveConfig(config) {
  try {
    if (!existsSync(CONFIG_DIR)) {
      mkdirSync(CONFIG_DIR, { recursive: true })
    }
    writeFileSync(CONFIG_FILE, JSON.stringify(config, null, 2), 'utf8')
  } catch (e) {
    // ignore
  }
}

// ============================================================================
// NVIDIA NIM API
// ============================================================================

async function nvidiaComplete(prompt, model = 'nvidia/llama-3.3-nemotron-super-49b-v1') {
  const config = loadConfig()
  const apiKey = config.providers?.nvidia || process.env.NVIDIA_API_KEY
  
  if (!apiKey) {
    throw new Error('NVIDIA API key not configured. Run "openbuff init" first.')
  }

  const response = await fetch('https://integrate.api.nvidia.com/v1/chat/completions', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${apiKey}`,
    },
    body: JSON.stringify({
      model: model,
      messages: [
        { role: 'system', content: `You are Openbuff, an expert AI coding assistant.

You help users with:
- Writing new code in any language
- Debugging and fixing bugs  
- Refactoring and improving code
- Adding tests
- Explaining code
- Running shell commands

Be concise but thorough. Focus on what the user asked for.` },
        { role: 'user', content: prompt }
      ],
      max_tokens: 8192,
      temperature: 0.5,
    }),
  })

  if (!response.ok) {
    const error = await response.text()
    throw new Error(`NVIDIA API error: ${response.status} - ${error}`)
  }

  const data = await response.json()
  return data.choices[0].message.content
}

// ============================================================================
// Simple Interactive Mode
// ============================================================================

async function runInteractive(config) {
  console.log(BANNER)
  console.log(`${C.green}✨ Welcome to Openbuff!${C.reset}\n`)
  console.log(`Model: nvidia/llama-3.3-nemotron-super-49b-v1`)
  console.log(`Type "exit" to quit, "clear" to clear chat\n`)
  
  const history = []
  
  while (true) {
    process.stdout.write(`${C.cyan}> ${C.reset}`)
    
    const input = await new Promise((resolve) => {
      process.stdin.once('data', (data) => {
        resolve(data.toString().trim())
      })
    })
    
    if (!input) continue
    
    if (input.toLowerCase() === 'exit') {
      console.log(`\n${C.green}Goodbye!${C.reset}`)
      break
    }
    
    if (input.toLowerCase() === 'clear') {
      history.length = 0
      console.log('Chat cleared.\n')
      continue
    }
    
    history.push({ role: 'user', content: input })
    
    console.log(`\n${C.dim}Thinking...${C.reset}\n`)
    
    try {
      const response = await nvidiaComplete(input)
      console.log(response)
      history.push({ role: 'assistant', content: response })
    } catch (error) {
      console.log(`${C.red}Error: ${error.message}${C.reset}`)
    }
    
    console.log()
  }
}

// ============================================================================
// Simple Command Mode
// ============================================================================

async function runCommand(prompt) {
  console.log(BANNER)
  console.log(`💭 ${prompt}\n`)
  console.log('─'.repeat(60) + '\n')
  
  try {
    const response = await nvidiaComplete(prompt)
    console.log(response)
  } catch (error) {
    console.log(`${C.red}Error: ${error.message}${C.reset}`)
    console.log('\n💡 Make sure you have configured your API key:')
    console.log('   openbuff init')
  }
}

// ============================================================================
// Init Command
// ============================================================================

async function cmdInit() {
  console.log(BANNER)
  console.log('🔧 Openbuff Configuration\n')
  
  const config = { providers: {}, defaultModel: null }
  
  // NVIDIA API Key
  const nvidiaKey = process.env.NVIDIA_API_KEY
  if (nvidiaKey?.startsWith('nvapi-')) {
    console.log(`${C.green}✅ NVIDIA API key found in environment${C.reset}`)
    config.providers.nvidia = nvidiaKey
  } else {
    console.log('📌 NVIDIA NIM API Key')
    console.log('   Get free key at: https://ngc.nvidia.com/setup/api-key')
    console.log(`   Or set: export NVIDIA_API_KEY=your_key_here`)
    console.log()
  }
  
  saveConfig(config)
  console.log(`\n${C.green}✅ Configuration saved to ${CONFIG_FILE}${C.reset}`)
}

// ============================================================================
// Status Command
// ============================================================================

function cmdStatus() {
  console.log(BANNER)
  console.log('📊 Openbuff Status\n')
  
  const config = loadConfig()
  
  if (config.providers?.nvidia) {
    console.log(`${C.green}✅ NVIDIA NIM configured${C.reset}`)
  } else {
    console.log(`${C.yellow}⚠️  NVIDIA NIM not configured${C.reset}`)
  }
  
  console.log(`\nConfig: ${CONFIG_FILE}`)
}

// ============================================================================
// Help
// ============================================================================

function showHelp() {
  console.log(BANNER)
  console.log(`
${C.bright}Usage:${C.reset}
  openbuff              Start interactive mode
  openbuff "prompt"     Run single command
  openbuff init         Configure API keys
  openbuff status       Show configuration
  openbuff --help       Show this help

${C.bright}Quick Start:${C.reset}
  1. openbuff init
  2. openbuff

${C.bright}Models:${C.reset}
  - nvidia/llama-3.3-nemotron-super-49b-v1 (default, free)

${C.bright}For Full OpenTUI:${C.reset}
  Clone the repository and run:
  git clone https://github.com/khiwniti/codebuff.git
  cd codebuff && bun run dev
`)
}

// ============================================================================
// Main
// ============================================================================

async function main() {
  const args = process.argv.slice(2)
  
  // Show help
  if (args.includes('--help') || args.includes('-h')) {
    showHelp()
    return
  }
  
  // Init command
  if (args[0] === 'init') {
    await cmdInit()
    return
  }
  
  // Status command
  if (args[0] === 'status') {
    cmdStatus()
    return
  }
  
  // Single prompt command
  if (args.length > 0 && !args[0].startsWith('-')) {
    await runCommand(args.join(' '))
    return
  }
  
  // Interactive mode
  await runInteractive(loadConfig())
}

main().catch(console.error)