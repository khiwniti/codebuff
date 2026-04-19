/**
 * Local Development Authentication Setup Script
 *
 * This script creates a test user and session in the local database for development.
 * Use this to test the codebuff CLI without needing to set up OAuth or real authentication.
 *
 * Usage:
 *   bun run scripts/local-dev-auth-setup.ts
 *
 * Environment:
 *   DATABASE_URL - PostgreSQL connection string (defaults to localhost)
 *
 * After running, use the output API key with:
 *   codebuff login --api-key <your-api-key>
 */

import { eq } from 'drizzle-orm'
import { drizzle } from 'drizzle-orm/postgres-js'
import postgres from 'postgres'

import * as schema from '@codebuff/internal/db/schema'

const TEST_USER_ID = 'local-test-user'
const TEST_USER_EMAIL = 'test@local.dev'
const TEST_API_KEY = 'local-dev-api-key'
const SESSION_DAYS_VALID = 30

async function setupLocalDevAuth() {
  const databaseUrl = process.env.DATABASE_URL || 'postgresql://localhost:5432/codebuff'

  console.log('='.repeat(60))
  console.log('  Local Development Auth Setup')
  console.log('='.repeat(60))
  console.log()
  console.log(`Database URL: ${databaseUrl}`)
  console.log(`Test User ID: ${TEST_USER_ID}`)
  console.log(`Test User Email: ${TEST_USER_EMAIL}`)
  console.log(`Session Valid For: ${SESSION_DAYS_VALID} days`)
  console.log()

  const client = postgres(databaseUrl, { max: 1 })
  const db = drizzle(client, { schema })

  try {
    const expiresAt = new Date()
    expiresAt.setDate(expiresAt.getDate() + SESSION_DAYS_VALID)

    console.log('Creating test user...')
    await db
      .insert(schema.user)
      .values({
        id: TEST_USER_ID,
        email: TEST_USER_EMAIL,
        name: 'Local Test User',
        handle: 'local-test',
      })
      .onConflictDoNothing()

    const [existingUser] = await db
      .select({ id: schema.user.id })
      .from(schema.user)
      .where(eq(schema.user.id, TEST_USER_ID))
      .limit(1)

    if (!existingUser) {
      throw new Error(`Failed to create or find user with ID ${TEST_USER_ID}`)
    }

    console.log('Creating session...')
    await db
      .insert(schema.session)
      .values({
        sessionToken: TEST_API_KEY,
        userId: TEST_USER_ID,
        expires: expiresAt,
        type: 'cli',
      })
      .onConflictDoNothing()

    console.log()
    console.log('='.repeat(60))
    console.log('  Setup Complete!')
    console.log('='.repeat(60))
    console.log()
    console.log('To use with codebuff CLI:')
    console.log()
    console.log(`  codebuff login --api-key ${TEST_API_KEY}`)
    console.log()
    console.log('Or set the environment variable:')
    console.log()
    console.log(`  export CODEBUFF_API_KEY=${TEST_API_KEY}`)
    console.log()
    console.log('Note: This session is valid for 30 days. Run this script')
    console.log('again to reset the session if it expires.')
    console.log()

  } finally {
    await client.end()
  }
}

setupLocalDevAuth()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error()
    console.error('Error:', err.message)
    console.error()
    console.error('Make sure PostgreSQL is running and the DATABASE_URL is correct.')
    process.exit(1)
  })
