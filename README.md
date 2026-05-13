# NovaX Rivals Modules

This repository is structured for RawGitHub loading.

Current module mode:

- `manifest.lua` points to `init.lua`.
- `init.lua` loads `core/runtime.lua` first, then starts each feature module from the manifest.
- Feature modules keep their own `Start(ctx)` entry and use separate runtime loops where the feature needs a loop.
- `ui/config_manager.lua` registers the Config Manager as a loadable UI-lib module; `CreateConfigList` stays in `ui/NovaPremiumUI.lua` for the Saved Configs selector.
- `bootstrap/novax_xeno_optimized.lua` stays available as a fallback copy of the full working script.

Raw base:

```text
https://raw.githubusercontent.com/y5gc8zpdwh-droid/novax-rivals-modules/main/
```
