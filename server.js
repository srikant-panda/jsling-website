const http = require("node:http");
const fs = require("node:fs");
const path = require("node:path");
const { URL } = require("node:url");

const PORT = Number(process.env.PORT || 4173);
const HOST = process.env.HOST || "127.0.0.1";
const DOWNLOADS_DIR = path.join(process.cwd(), "downloads");
const PUBLIC_DIR = path.join(process.cwd(), "dist");

const mimeTypes = new Map([
  [".html", "text/html; charset=utf-8"],
  [".css", "text/css; charset=utf-8"],
  [".js", "text/javascript; charset=utf-8"],
  [".json", "application/json; charset=utf-8"],
  [".txt", "text/plain; charset=utf-8"],
  [".sh", "text/x-shellscript; charset=utf-8"],
  [".ps1", "text/plain; charset=utf-8"],
  [".exe", "application/vnd.microsoft.portable-executable"],
  [".svg", "image/svg+xml"],
  ["", "application/octet-stream"]
]);

const downloads = {
  "/download/windows-installer": {
    file: path.join(DOWNLOADS_DIR, "JSling-Setup.exe"),
    name: "JSling-Setup.exe"
  },
  "/download/windows-ps1": {
    file: path.join(DOWNLOADS_DIR, "install-windows.ps1"),
    name: "install-windows.ps1"
  },
  "/download/unix-local-installer": {
    file: path.join(DOWNLOADS_DIR, "install-local.sh"),
    name: "install-local.sh"
  },
  "/download/unix-source-installer": {
    file: path.join(DOWNLOADS_DIR, "install.sh"),
    name: "install.sh"
  },
  "/download/linux-binary": {
    file: path.join(DOWNLOADS_DIR, "jsling"),
    name: "jsling-linux"
  }
};

function send(res, status, headers, body) {
  res.writeHead(status, headers);
  res.end(body);
}

function sendJson(res, status, data) {
  send(res, status, { "content-type": "application/json; charset=utf-8" }, JSON.stringify(data, null, 2));
}

function sendFile(res, filePath, downloadName) {
  fs.stat(filePath, (statError, stat) => {
    if (statError || !stat.isFile()) {
      sendJson(res, 404, {
        error: "Artifact not found",
        hint: "Build jsling first if you are trying to download a binary."
      });
      return;
    }

    const ext = path.extname(filePath);
    const headers = {
      "content-type": mimeTypes.get(ext) || mimeTypes.get(""),
      "content-length": stat.size,
      "content-disposition": `attachment; filename="${downloadName || path.basename(filePath)}"`
    };

    res.writeHead(200, headers);
    fs.createReadStream(filePath).pipe(res);
  });
}

function sendStaticFile(res, filePath) {
  fs.stat(filePath, (statError, stat) => {
    if (statError || !stat.isFile()) {
      sendJson(res, 404, { error: "Not found" });
      return;
    }

    const ext = path.extname(filePath);
    res.writeHead(200, {
      "content-type": mimeTypes.get(ext) || mimeTypes.get(""),
      "content-length": stat.size
    });
    fs.createReadStream(filePath).pipe(res);
  });
}

function listArtifacts() {
  return Object.entries(downloads).map(([route, item]) => ({
    route,
    name: item.name,
    available: fs.existsSync(item.file)
  }));
}

function safePublicPath(pathname) {
  const requested = pathname === "/" ? "/index.html" : pathname;
  const normalized = path.normalize(decodeURIComponent(requested)).replace(/^(\.\.[/\\])+/, "");
  const filePath = path.join(PUBLIC_DIR, normalized);
  if (!filePath.startsWith(PUBLIC_DIR)) return null;
  return filePath;
}

const handler = (req, res) => {
  if (!req.url) {
    sendJson(res, 400, { error: "Bad request" });
    return;
  }

  const url = new URL(req.url, `http://${req.headers.host || "localhost"}`);

  if (url.pathname === "/api/artifacts") {
    sendJson(res, 200, { artifacts: listArtifacts() });
    return;
  }

  if (downloads[url.pathname]) {
    const item = downloads[url.pathname];
    sendFile(res, item.file, item.name);
    return;
  }

  const filePath = safePublicPath(url.pathname);
  if (!filePath) {
    sendJson(res, 403, { error: "Forbidden" });
    return;
  }

  fs.stat(filePath, (statError, stat) => {
    if (statError || !stat.isFile()) {
      sendStaticFile(res, path.join(PUBLIC_DIR, "index.html"));
      return;
    }

    const ext = path.extname(filePath);
    res.writeHead(200, { "content-type": mimeTypes.get(ext) || mimeTypes.get("") });
    fs.createReadStream(filePath).pipe(res);
  });
};

module.exports = handler;

if (require.main === module) {
  const server = http.createServer(handler);
  server.listen(PORT, HOST, () => {
    console.log(`jsling download site running at http://${HOST}:${PORT}`);
  });
}
