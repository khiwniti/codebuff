// Minimal server to test Railway deployment
// This will help us verify the deployment works before troubleshooting Next.js

const http = require('http')

const PORT = process.env.PORT || 3000

const server = http.createServer((req, res) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.url}`)

  if (req.url === '/api/healthz') {
    res.writeHead(200, { 'Content-Type': 'application/json' })
    res.end(
      JSON.stringify({ status: 'ok', timestamp: new Date().toISOString() }),
    )
    return
  }

  res.writeHead(200, { 'Content-Type': 'text/html' })
  res.end(`
    <html>
      <body>
        <h1>Codebuff Web - Test Server</h1>
        <p>Server is running on port ${PORT}</p>
        <p>Time: ${new Date().toISOString()}</p>
        <p><a href="/api/healthz">Check Health</a></p>
      </body>
    </html>
  `)
})

server.listen(PORT, '0.0.0.0', () => {
  console.log(`✅ Test server listening on 0.0.0.0:${PORT}`)
  console.log(
    `✅ Health check available at http://localhost:${PORT}/api/healthz`,
  )
})

server.on('error', (err) => {
  console.error('❌ Server error:', err)
  process.exit(1)
})
