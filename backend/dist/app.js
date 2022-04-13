"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const ws_1 = require("ws");
const utf_8_validate_1 = __importDefault(require("utf-8-validate"));
const bufferutil_1 = __importDefault(require("bufferutil"));
const port = 9001;
const wss = new ws_1.WebSocketServer({ port: port });
let rooms = [];
let clients = [];
console.log(`Running on ws://127.0.0.1:${port}`);
const clientHasNotConnected = (id) => {
    return clients.filter((c) => c.id == id).length == 0;
};
const getClientFromWs = (socket) => {
    clients.forEach((client) => {
        if (client.socket === socket)
            return client.id;
    });
    return "";
};
wss.on("connection", (ws) => {
    ws.on("message", (message) => {
        console.log("ws connection: ", ws);
        if ((0, utf_8_validate_1.default)(message)) {
            let data2 = bufferutil_1.default.unmask(message);
            let data = JSON.parse(message.toString());
            var id = Math.random().toString(16).slice(2);
            console.log("buff util: ", data2);
            console.log("to string: ", data);
            console.log(`New player, id: ${id}`);
            clients.push(data);
            let payload = {
                type: "connection",
                id: id,
            };
            ws.send(JSON.stringify(payload));
        }
    });
    ws.on("close", (code, reason) => {
        var clientId = getClientFromWs(ws);
        console.log(`player ${clientId} disconnected`);
    });
});
//# sourceMappingURL=app.js.map