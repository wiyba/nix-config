import http from "node:http";

const HOST = process.env.HOST || "127.0.0.1";
const PORT = Number(process.env.PORT) || 8890;

let nextId = 1;
const clients = new Map();

function broadcast() {
  const list = [...clients.values()].map((c) => ({ name: c.name, ip: c.ip }));
  const frame = `data: ${JSON.stringify(list)}\n\n`;
  for (const c of clients.values()) c.res.write(frame);
}

http
  .createServer((req, res) => {
    const url = new URL(req.url, "http://localhost");
    if (url.pathname !== "/presence") {
      res.writeHead(404);
      res.end();
      return;
    }

    const name =
      (url.searchParams.get("u") || "").trim().slice(0, 32) || "anon";
    const ip = (
      req.headers["x-real-ip"] ||
      req.socket.remoteAddress ||
      ""
    ).toString();

    res.writeHead(200, {
      "Content-Type": "text/event-stream",
      "Cache-Control": "no-cache",
      Connection: "keep-alive",
    });
    res.write("retry: 5000\n\n");

    const id = nextId++;
    clients.set(id, { name, ip, res });
    broadcast();

    const ping = setInterval(() => res.write(": ping\n\n"), 20000);
    req.on("close", () => {
      clearInterval(ping);
      clients.delete(id);
      broadcast();
    });
  })
  .listen(PORT, HOST);
