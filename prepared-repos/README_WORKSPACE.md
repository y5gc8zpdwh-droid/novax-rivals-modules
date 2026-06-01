# NovaX Rivals Workspace

Dieser Ordner enthaelt die lokale Arbeitskopie fuer NovaX. Aktiv ist die neue
mehrteilige Loader-Struktur unter `github_push_workspace/novax-*`.

## Aktiver Einstieg

- `novax_xeno_optimized.lua` ist der lokale Entry-Loader.
- `github_push_workspace/novax-loader/loader.lua` ist die GitHub-Version des Entry-Loaders.
- `github_push_workspace/novax-loader/bootstrap.lua` laedt UI, GUI und Kategorie-Loader.

## Aktive Loader-Kette

1. `novax-loader`
2. `novax-ui`
3. `novax-gui`
4. Kategorie-Loader:
   - `novax-combat-loader`
   - `novax-visual-loader`
   - `novax-movement-loader`
   - `novax-misc-loader`
5. gemeinsamer finaler Feature-Loader:
   - `novax-feature-loader`
6. einzelne Feature-Repos, z. B. `novax-aimlock`, `novax-triggerbot`, `novax-esp`.

## Aktive Feature-Repos

- Combat: `novax-aimlock`, `novax-triggerbot`, `novax-silentaim`
- Visual: `novax-esp`, `novax-fov`
- Movement: `novax-speed`, `novax-fly`, `novax-noclip`, `novax-infjump`, `novax-antivoid`, `novax-bunnyhop`
- Misc: `novax-configs`, `novax-name-changer`, `novax-beggerfarm`, `novax-backstab`, `novax-names-orbit`, `novax-antihit`, `novax-control-spoof`

## Aktuelle Runtime-Regeln

- Combat-Features laufen nur ueber den zentralen Round-State-Gate.
- Triggerbot, AimLock, SilentAim und FOV haben eigene Feature-Module.
- Der Runtime-Core enthaelt nur noch gemeinsam genutzte Services, UI-Bindings und Shared-Helper.
- Der alte Dropdown-Code, AutoAim, RageBot und Mouse-AimAssist sind aus dem aktiven Code entfernt.

## Entfernte Altlasten

Die alten aktiven Pfade `novax/`, `github_push_workspace/novax-rivals-loader/`,
`github_push_workspace/novax-rivals-modules/` und
`github_push_workspace/novax-rivals-assets/` wurden aus dem aktiven Workspace
entfernt. Historische Kopien liegen nur noch unter `_archive/`.

## Assets und Ablage

- `_assets/` enthaelt die Logo-/Bildassets, die UI und GUI zuerst suchen.
- `_docs/` enthaelt Nutzungsnotizen und den Luau-Anfaengerleitfaden.
- `_archive/` enthaelt alte Kopien und nicht aktive Quellstaende.
- `_archive/reference-projects/side_project_blueui/` enthaelt das alte separate Referenz-/Nebenprojekt. Es ist nicht Teil der NovaX-Loaderkette.
- `_archive/root-assets/` enthaelt alte Root-Bilddateien, die nicht mehr direkt aus dem Root geladen werden.
