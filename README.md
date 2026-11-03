# TINY TITANS

Roblox prototype: a multiplayer creature evolution arena.

## Toolchain

- Roblox Studio
- Rojo 7.6.1
- Rokit 1.2.0 (existing tool manager)

These are the versions recorded for the existing development setup. Verify locally before syncing; do not upgrade the toolchain as part of this prototype.

## Project mapping

- `src/ReplicatedStorage/Shared`: shared configuration and data contracts
- `src/ServerScriptService`: server-authoritative gameplay
- `src/StarterPlayer/StarterPlayerScripts`: client input and UI
- `Workspace`: intentionally excluded from Rojo; author the greybox arena in Studio for now.

## Validate

```powershell
rojo build default.project.json -o build.rbxlx
```

Then connect Studio using the Rojo plugin. The project currently contains bootstrap placeholders only; gameplay systems are not implemented.

See `docs/Game Design Document v0.1.md` and `docs/Technical Design & Implementation Plan v0.1.md`.
