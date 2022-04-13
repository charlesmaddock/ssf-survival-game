import { WebSocket, WebSocketServer } from "ws";
import isValidUTF8 from "utf-8-validate";
import { IncomingMessage } from "http";

const port = 9001;
const wss = new WebSocketServer({ port: port });

type Class =
  | "Sam the Sniper"
  | "Ryan the Robot"
  | "Anna the Assassin"
  | "Romance Scammer";

enum PacketTypes {
  SERVER_MESSAGE,
  CONNECTED,
  UPDATE_CLIENT_DATA,
  HOST_ROOM,
  ROOM_HOSTED,
  JOIN_ROOM,
  ROOM_JOINED,
  LEAVE_ROOM,
  ROOM_LEFT,
  START_GAME,
  GAME_STARTED,
  SET_INPUT,
  SET_PLAYER_POS,
  FREE_NODE,
  NODE_FREED,
  USE_ABILITY,
  ABILITY_USED,
  SET_HEALTH,
  SHOOT_PROJECTILE,
  START_DOORS,
}

type PacketType = PacketTypes;

interface Room {
  code: string;
  hostId: string;
  clients: Array<Client>;
}

interface Client {
  id: string;
  name: string;
  socket: WebSocket;
  class: Class;
}

interface MinClientData {
  id: string;
  name: string;
  class: Class;
  pos?: { x: number; y: number };
}

let rooms: Array<Room> = [];
let clients: Array<Client> = [];

console.log(`Running on ws://127.0.0.1:${port}`);

const clientHasNotConnected = (id: string): boolean => {
  return clients.filter((c) => c.id == id).length == 0;
};

const getClientsRoom = (c: Client): Room => {
  for (let i = 0; i < rooms.length; i++) {
    const room = rooms[i];
    if (room.clients.includes(c)) {
      return room;
    }
  }
  return null;
};

const getRoomsClient = (room: Room): Client => {
  if (room !== null) {
    for (let i = 0; i < room.clients.length; i++) {
      if (room.clients[i].id == room.hostId) return room.clients[i];
    }
    return null;
  }
  return null;
};

const getRoomWithCode = (code: string): Room => {
  for (let i = 0; i < rooms.length; i++) {
    if (rooms[i].code == code) return rooms[i];
  }
  return null;
};

const getClientFromWs = (socket: WebSocket): Client => {
  for (let i = 0; i < clients.length; i++) {
    if (clients[i].socket === socket) return clients[i];
  }
  return null;
};

wss.on("connection", (ws: WebSocket, req: IncomingMessage) => {
  console.log("ws connection from IP: ", req.socket.remoteAddress);

  ws.on("message", (buff: Buffer) => {
    if (isValidUTF8(buff)) {
      let data = JSON.parse(buff.toString());
      let type: PacketType = data.type;

      if (type !== undefined) {
        switch (type) {
          case PacketTypes.CONNECTED:
            handleConnected(ws);
            break;
          case PacketTypes.UPDATE_CLIENT_DATA:
            handleUpdateClientData(ws, data);
            break;
          case PacketTypes.HOST_ROOM:
            handleHostRoom(ws, getClientFromWs(ws));
            break;
          case PacketTypes.JOIN_ROOM:
            handleJoinRoom(ws, data);
            break;
          case PacketTypes.LEAVE_ROOM:
            handleLeaveRoom(ws);
            break;
          case PacketTypes.START_GAME:
            handleStartGame(ws);
            break;
          case PacketTypes.SET_INPUT:
            handleSetInput(ws, data);
            break;
          case PacketTypes.USE_ABILITY:
            handleUseAbility(ws, data.key);
            break;
          case PacketTypes.SET_PLAYER_POS:
            handleSetPos(ws, data);
            break;
          case PacketTypes.FREE_NODE:
            handleFreeNode(ws, data);
            break;
          case PacketTypes.SET_HEALTH:
            handleSetHealth(ws, data);
            break;
          case PacketTypes.SHOOT_PROJECTILE:
            handleShootProjectile(ws, data);
            break;
          default:
            console.error("Unhandled packet type.");
        }
      } else {
        console.error("Undefined packet type.");
      }
    }
  });

  ws.on("close", (code, reason) => {
    let client: Client = getClientFromWs(ws);
    if (client !== null) {
      let clientsRoom: Room = getClientsRoom(client);
      if (clientsRoom !== null) {
        handleLeaveRoom(client.socket);
      }

      var removeAt = clients.indexOf(client);
      clients.splice(removeAt, 1);
      console.log(
        `player ${client.id} disconnected. Clients.length: ${clients.length}`
      );
    } else {
      console.warn("Couldn't find disconnecting client.");
    }
  });
});

const handleConnected = (ws: WebSocket) => {
  let id: string = Math.random().toString(16).slice(2);
  let names = ["Charles", "Sigge", "Isac", "Johan", "Paul"];
  let name = names[Math.floor(Math.random() * names.length)];
  let newClient: Client = {
    id: id,
    name: name + Math.floor(Math.random() * 100),
    socket: ws,
    class: "Sam the Sniper",
  };

  console.log(`New player, id: ${id}`);

  clients.push(newClient);

  let payload: { type: PacketType; clientData: MinClientData } = {
    type: PacketTypes.CONNECTED,
    clientData: {
      id: newClient.id,
      class: newClient.class,
      name: newClient.name,
    },
  };
  ws.send(JSON.stringify(payload));
};

const handleUpdateClientData = (
  ws: WebSocket,
  packet: { type: number; clientData: MinClientData }
) => {
  let client = getClientFromWs(ws);
  let room: Room = getClientsRoom(client);

  client.class = packet.clientData.class;
  client.name = packet.clientData.name;

  broadcastToRoom(room, packet);
};

const handleHostRoom = (ws: WebSocket, client: Client) => {
  if (client !== null) {
    let time = new Date().getTime();
    let code = time
      .toString(16)
      .slice(String(time).length - 5, String(time).length);

    let newRoom: Room = {
      code: code,
      hostId: client.id,
      clients: [client],
    };
    rooms.push(newRoom);

    ws.send(JSON.stringify({ type: PacketTypes.ROOM_HOSTED }));
    sendJoined(ws, newRoom);
  } else {
    console.error("Client that wants to host a room was null.");
  }
};

const handleJoinRoom = (
  ws: WebSocket,
  packet: { type: number; code: string }
) => {
  let room = null;
  if (packet.code === "random") {
    if (rooms.length > 0) {
      room = rooms[0];
    } else {
      sendError(ws, "No rooms available, host one yourself!");
    }
  } else {
    room = getRoomWithCode(packet.code);
    if (room === null) sendError(ws, "Invalid code.");
  }

  if (room !== null) {
    let joiningClient = getClientFromWs(ws);
    if (joiningClient !== null) {
      room.clients.push(joiningClient);
      room.clients.forEach((client: Client) => {
        sendJoined(client.socket, room);

        // For speeding up development
        if (packet.code === "random") {
          handleStartGame(client.socket);
        }
      });
    }
  }
};

const handleLeaveRoom = (ws: WebSocket) => {
  let leavingClient = getClientFromWs(ws);
  if (leavingClient !== null) {
    let clientsRoom = getClientsRoom(leavingClient);
    if (clientsRoom !== null) {
      console.log(
        "Client with id ",
        leavingClient.id,
        " left the room ",
        clientsRoom.code
      );

      // Remove room if we are the host
      if (clientsRoom.hostId == leavingClient.id) {
        broadcastError(clientsRoom, "Host disconnected, room closed.", true);
        for (let i = clientsRoom.clients.length - 1; i >= 0; i--) {
          leaveRoom(clientsRoom, clientsRoom.clients[i]);
        }
        var removeAt = rooms.indexOf(clientsRoom);
        rooms.splice(removeAt, 1);
        console.log(
          `Room ${clientsRoom.code} was removed. Rooms length: ${rooms.length}`
        );
      } else {
        leaveRoom(clientsRoom, leavingClient);
      }
    }
  }
};

const leaveRoom = (room: Room, client: Client) => {
  let payload = {
    type: PacketTypes.ROOM_LEFT,
    id: client.id,
  };
  broadcastToRoom(room, payload);

  var removeAt = clients.indexOf(client);
  if (removeAt !== -1) {
    room.clients.splice(removeAt, 1);
  }
};

const handleStartGame = (ws: WebSocket) => {
  let startingClient = getClientFromWs(ws);
  if (startingClient !== null) {
    let playerSpawnPoints = [
      {
        x: 266 + (Math.random() - 0.5 * 2),
        y: 410 + (Math.random() - 0.5 * 2),
      },
      {
        x: 974 + (Math.random() - 0.5 * 2),
        y: -27 + (Math.random() - 0.5 * 2),
      },
      {
        x: -437 + (Math.random() - 0.5 * 2),
        y: 146 + (Math.random() - 0.5 * 2),
      },
    ];
    let spawnPosPlayer =
      playerSpawnPoints[Math.floor(Math.random() * playerSpawnPoints.length)];
    rooms.forEach((room: Room) => {
      if (room.hostId === startingClient.id) {
        let spawnPosScammer = {
          x: 128 + (Math.random() - 0.5 * 4),
          y: -265 + (Math.random() - 0.5 * 4),
        };

        let payload: { type: PacketType; players: Array<MinClientData> } = {
          type: PacketTypes.GAME_STARTED,
          players: room.clients.map((c) => ({
            id: c.id,
            name: c.name,
            class: c.class,
            pos:
              c.class == "Romance Scammer" ? spawnPosScammer : spawnPosPlayer,
          })),
        };
        broadcastToRoom(room, payload);

        // Sync doors for all clients, temporary
        setTimeout(() => {
          let doorPayload = {
            type: PacketTypes.START_DOORS,
          };
          broadcastToRoom(room, doorPayload);
        }, 3000);
      }
    });
  }
};

const handleSetInput = (
  ws: WebSocket,
  packet: { type: number; x: number; y: number }
) => {
  let client = getClientFromWs(ws);
  let room: Room = getClientsRoom(client);
  let hostClient = getRoomsClient(room);

  if (hostClient !== null) {
    let payload = {
      ...packet,
      id: client.id,
    };
    hostClient.socket.send(JSON.stringify(payload));
  }
};

const handleUseAbility = (ws: WebSocket, key: string) => {
  let client = getClientFromWs(ws);
  let room: Room = getClientsRoom(client);

  let payload = {
    type: PacketTypes.ABILITY_USED,
    key: key,
    id: client.id,
  };
  broadcastToRoom(room, payload);
};

const handleSetPos = (
  ws: WebSocket,
  packet: { type: number; id: string; x: number; y: number }
) => {
  let client = getClientFromWs(ws);
  let room: Room = getClientsRoom(client);

  broadcastToRoom(room, packet);
};

const handleFreeNode = (
  ws: WebSocket,
  packet: { type: number; id: string }
) => {
  let client = getClientFromWs(ws);
  let room: Room = getClientsRoom(client);

  let payload = {
    type: PacketTypes.NODE_FREED,
    id: packet.id,
  };

  broadcastToRoom(room, payload);
};

const handleSetHealth = (
  ws: WebSocket,
  packet: {
    type: number;
    id: string;
    health: number;
    dirX: number;
    dirY: number;
  }
) => {
  let client = getClientFromWs(ws);
  let room: Room = getClientsRoom(client);

  broadcastToRoom(room, packet);
};

const handleShootProjectile = (ws: WebSocket, packet: any) => {
  let client = getClientFromWs(ws);
  let room: Room = getClientsRoom(client);
  broadcastToRoom(room, packet);
};

const broadcastToRoom = (
  room: Room,
  payload: object,
  excludeId: string = ""
) => {
  if (room !== null) {
    room.clients.forEach((client) => {
      if (client.id !== excludeId) {
        client.socket.send(JSON.stringify(payload));
      }
    });
  }
};

const sendJoined = (ws: WebSocket, room: Room) => {
  let payload: {
    type: PacketType;
    clientData: Array<MinClientData>;
    code: string;
  } = {
    type: PacketTypes.ROOM_JOINED,
    clientData: room.clients.map((c) => ({
      id: c.id,
      name: c.name,
      class: c.class,
    })),
    code: room.code,
  };
  ws.send(JSON.stringify(payload));
};

const broadcastError = (room: Room, text: string, excludeHost: boolean) => {
  let payload = {
    type: PacketTypes.SERVER_MESSAGE,
    msgType: "error",
    text: text,
  };
  broadcastToRoom(room, payload, excludeHost ? room.hostId : "");
};

const sendError = (ws: WebSocket, text: string) => {
  let payload = {
    type: PacketTypes.SERVER_MESSAGE,
    msgType: "error",
    text: text,
  };
  ws.send(JSON.stringify(payload));
};
