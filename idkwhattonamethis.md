# "Mod Songs and Sh*t" Implementation Checklist

This is the concrete source-change plan once the Funkin source is present locally.

## UI / Menu
- Add a new main menu entry: `Mod Songs and Sh*t`.
- Route that entry to a new state/screen (ex: `ModSongsState`).

## Mods Folder
- Add runtime scan for a `mods/` folder at game root.
- Detect per-mod song packs (example: `mods/<modName>/songs/<songId>/`).

## JSON Schema
Each mod song should define a metadata file (example `song.json`):

```json
{
  "id": "my-song-id",
  "displayName": "My Song",
  "week": "mod-week-1",
  "difficulties": ["easy", "normal", "hard"],
  "chart": "charts/normal.json",
  "audio": {
    "inst": "audio/Inst.ogg",
    "voices": "audio/Voices.ogg"
  }
}
```

## Assets
- Load chart/audio/preview assets from mod path first.
- Keep fallback to base game assets for missing optional resources.

## Weeks Integration
- Support optional custom week JSON in each mod.
- Merge mod weeks into week selection list without breaking vanilla weeks.

## Play Flow
- Selecting a mod song should launch play state using mod chart + audio references.
- Validate missing files gracefully (show error, don't crash).
