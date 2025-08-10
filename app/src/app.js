const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

app.get('/', (req, res) => {
  res.send(`
    <h1>TechNova Solutions</h1>
    <p>Welcome to our handcrafted goods e-commerce platform!</p>
    <p>Version: ${process.env.APP_VERSION || '1.0.0'}</p>
    <p>Server: ${process.env.HOSTNAME || 'local'}</p>
  `);
});

app.get('/health', (req, res) => {
  res.json({ status: 'healthy', timestamp: new Date() });
});

app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});

module.exports = app; // For testing