#!/usr/bin/env node
/**
 * Publish script for openbuff npm package
 * Uses NPM_TOKEN from environment variable
 * 
 * Usage:
 *   NPM_TOKEN=your_token node publish.js
 *   or
 *   node publish.js --token your_token
 */

const { execSync } = require('child_process')
const fs = require('fs')
const path = require('path')

// Get npm token from environment or arguments
const args = process.argv.slice(2)
let npmToken = process.env.NPM_TOKEN

// Check for token as argument
for (let i = 0; i < args.length; i++) {
  if (args[i] === '--token' && args[i + 1]) {
    npmToken = args[i + 1]
  }
}

if (!npmToken) {
  console.error('❌ NPM token not found!')
  console.error('Please provide one of:')
  console.error('  1. NPM_TOKEN environment variable')
  console.error('  2. --token argument')
  process.exit(1)
}

const releaseDir = __dirname

console.log('🚀 Publishing openbuff to npm...')
console.log(`Version: ${require('./package.json').version}`)
console.log('')

// Set the npm registry auth token temporarily
try {
  execSync(`npm config set //registry.npmjs.org/:_authToken=${npmToken}`, {
    stdio: 'pipe'
  })
  
  // Run npm publish
  execSync('npm publish --access public', {
    cwd: releaseDir,
    stdio: 'inherit',
    env: {
      ...process.env,
      NPM_TOKEN: npmToken
    }
  })
  
  console.log('')
  console.log('✅ Successfully published openbuff to npm!')
  console.log('   Package: https://www.npmjs.com/package/openbuff')
  
  // Clean up the auth token
  execSync('npm config delete //registry.npmjs.org/:_authToken', {
    stdio: 'pipe'
  })
  
} catch (error) {
  console.error('')
  console.error('❌ Publishing failed!')
  console.error('   Make sure:')
  console.error('   - You are logged in with correct permissions')
  console.error('   - The version does not already exist')
  console.error('   - Your npm token has publish permissions')
  process.exit(1)
}