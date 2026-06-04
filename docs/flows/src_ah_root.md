# src/\_ah/root.zig flow

## load(self: \*AudioHandler, master_volume)

```mermaid
flowchart TD
    A[load called] --> B[setMasterVolume]
    B --> Z[return]
```

## loadAudio(self: \*AudioHandler, io, audio_type, file_path, key)

```mermaid
flowchart TD
    A[loadAudio called] --> B[dupeZ -> file_path]
    B --> C{dupe success?}
    C -- no --> Z1[return]
    C -- yes --> D[stat file]
    D --> E{stat success and size > 0?}
    E -- no --> Z1
    E -- yes --> F{audio_type}
    F -- Music --> G[unload existing music and set null]
    G --> H[loadMusicStream -> file_path_z] --> Z2[return]
    F -- Sfx --> I[unload existing sfx and set null]
    I --> J[loadSound -> file_path_z] --> Z2
```

## update(self: \*AudioHandler)

```mermaid
flowchart TD
  A[update called] --> B{music exists?}
  B -- yes --> C[updateMusicStream] --> Z[return]
  B -- no --> Z
```

## draw

No draw method exists in this root file.
