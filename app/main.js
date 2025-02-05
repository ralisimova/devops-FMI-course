const express = require('express');
const os = require('os');

const app = express();
const port = 80;

app.get('/', (req, res) => {
    res.send('Hello World!');
});

app.get("/hostname", (req, res) => {
    res.send({ hostname: os.hostname() });
});


app.listen(port, () => {
    console.log(`Server running on http://localhost:${port}`);
});