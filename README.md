# jsling Download Website

This is a dependency-free Node website for downloading jsling installers and local artifacts. It is self-contained and can be run from any directory.

## Run

```bash
cd website
node server.js
```

Then open:

```text
http://localhost:4173
```

Set a custom port:

```bash
PORT=8080 node server.js
```

## Downloads & Assets

All installer scripts and binaries are packaged directly within the `website/downloads/` directory:

- `/download/windows-installer` -> `website/downloads/JSling-Setup.exe`
- `/download/windows-binary` -> `website/downloads/jsling (1).exe`
- `/download/unix-source-installer` -> `website/downloads/install.sh`
- `/download/linux-binary` -> `website/downloads/jsling`
- `/api/artifacts` -> JSON availability status

To update these assets with new builds or installer updates from the compiler workspace, copy them into `website/downloads/`.
