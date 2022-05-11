const express = require("express");
const path = require("path");

const app = express();
const port = process.env.PORT || 8081;

app.use("/", express.static(path.join(__dirname, "public")));

app.listen(port);
console.log("Server started at http://localhost:" + port);
