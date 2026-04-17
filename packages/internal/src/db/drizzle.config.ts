import path from 'path'

import { defineConfig } from 'drizzle-kit'

import { env } from '@codebuff/internal/env'

console.log('Drizzle Config DATABASE_URL:', env.DATABASE_URL)
export default defineConfig({
  dialect: 'postgresql',
  schema: path.join(__dirname, 'schema.ts').replace(/\\/g, '/'),
  out: 'src/db/migrations',
  dbCredentials: {
    url: env.DATABASE_URL,
  },
  tablesFilter: ['*', '!pg_stat_statements', '!pg_stat_statements_info'],
})
