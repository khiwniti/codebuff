#!/usr/bin/env node

/**
 * Openbuff CLI - Full OpenTUI Terminal Interface
 * 
 * This launches the full OpenTUI-based terminal interface
 * Similar to GitHub Copilot's terminal experience.
 */

import { spawn, execSync } from 'child_process'
import { existsSync, readFileSync } from 'fs'
import { join, dirname } from 'path'
import { fileURLToPath } from 'url'
import { homedir } from 'os'

// ES Module equivalent of __dirname
const __filename = fileURLToPath(import.meta.url)
const __dirname = dirname(__filename)

const CONFIG_DIR = join(homedir(), '.openbuff')
const CONFIG_FILE = join(CONFIG_DIR, 'config.json')

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
${C.cyan}║${C.reset}   ${C.bright}Openbuff - Full OpenTUI Terminal${C.reset}                          ${C.cyan}║${C.reset}
${C.cyan}║${C.reset}   ${C.dim}NVIDIA NIM powered • No account required${C.reset}                   ${C.cyan}║${C.reset}
${C.cyan}║${C.reset}                                                                    ${C.cyan}║${C.reset}
${C.cyan}╚════════════════════════════════════════════════════════════════════╝${C.reset}
`

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

// ============================================================================
// TUI Launcher
// ============================================================================

function launchFullTUI(args = []) {
  console.log(BANNER)
  console.log(`${C.green}🚀 Launching Full OpenTUI Terminal...${C.reset}\n`)
  
  // Find the CLI source
  const possiblePaths = [
    join(process.cwd(), 'cli', 'src', 'index.tsx'),
    join(__dirname, 'cli', 'src', 'index.tsx'),
    join(dirname(__dirname), '..', '..', 'cli', 'src', 'index.tsx'),
  ]
  
  let cliPath = null
  for (const p of possiblePaths) {
    if (existsSync(p)) {
      cliPath = p
      break
    }
  }
  
  if (!cliPath) {
    console.log(`${C.red}❌ CLI source not found.${C.reset}`)
    console.log('')
    console.log('The OpenTUI requires the openbuff repository.')
    console.log('Please clone it and run from the repository directory.')
    console.log('')
    showHelp()
    return
  }
  
  console.log(`   CLI Path: ${cliPath}`)
  console.log(`   Working Dir: ${process.cwd()}\n`)
  
  // Set environment for freebuff mode
  const env = {
    ...process.env,
    FREEBUFF_MODE: 'true',
    NEXT_PUBLIC_CB_ENVIRONMENT: 'prod',
    NEXT_PUBLIC_CODEBUFF_APP_URL: 'https://openbuff.dev',
    NEXT_PUBLIC_SUPPORT_EMAIL: 'support@openbuff.dev',
    NEXT_PUBLIC_POSTHOG_API_KEY: 'dummy',
    NEXT_PUBLIC_POSTHOG_HOST_URL: 'https://posthog.openbuff.dev',
  }
  
  // Launch bun with the CLI
  const bunProcess = spawn('bun', ['run', cliPath, ...args], {
    cwd: process.cwd(),
    env,
    stdio: 'inherit',
    shell: false,
  })
  
  bunProcess.on('error', (err) => {
    console.error(`\n${C.red}❌ Error launching TUI:${C.reset}`, err.message)
    console.log('\nMake sure bun is installed:')
    console.log('   curl -fsSL https://bun.sh/install | bash')
  })
  
  bunProcess.on('close', (code) => {
    process.exit(code || 0)
  })
}

// ============================================================================
// Help
// ============================================================================

function showHelp() {
  console.log('Usage:')
  console.log('  openbuff              Launch full OpenTUI (TUI mode)')
  console.log('  openbuff --help      Show this help')
  console.log('')
  console.log('For full OpenTUI:')
  console.log('  1. Install bun: curl -fsSL https://bun.sh/install | bash')
  console.log('  2. cd openbuff && bun run dev')
}

// ============================================================================
// Main
// ============================================================================

function main() {
  const args = process.argv.slice(2)
  
  // Show help if requested
  if (args.includes('--help') || args.includes('-h')) {
    console.log(BANNER)
    showHelp()
    return
  }
  
  // Check if bun is available
  let bunAvailable = false
  try {
    execSync('bun --version', { stdio: 'ignore' })
    bunAvailable = true
  } catch {}
  
  if (bunAvailable) {
    // Launch full TUI
    launchFullTUI(args)
  } else {
    // Bun not available - show message
    console.log(BANNER)
    console.log(`${C.yellow}⚠️  Bun is not installed.${C.reset}`)
    console.log('')
    console.log('The full OpenTUI requires Bun runtime.')
    console.log('')
    console.log('To install Bun:')
    console.log('   curl -fsSL https://bun.sh/install | bash')
    console.log('')
    console.log('Then run: openbuff')
  }
}

main()