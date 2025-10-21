# Bocchi The LCH!
> Bocchi (Japanese: ぼっち) — aloneness; loneliness; solitude

A standalone and really tiny OKLCH to HEX color converter library for Neovim colorscheme and pure Lua projects.

This library is intended to be used as a dependency by other plugins (e.g. colorschemes). It exposes only functions and does not register any Neovim commands, autocmds, or keymaps.

> License: MIT OR Yamada Ryo Riceware (see `LICENSE`). The Riceware clause simply grants you the option—never the obligation—to feed Yamada Ryo if you bump into her.

## Installation (as a dependency)

### lazy.nvim
```lua
-- Inside your plugin spec
return {
  "author/your-colorscheme-or-plugin",
  dependencies = {
    "KijitoraFinch/bocchi-the-lch.nvim",
  },
  config = function()
    local bocchi = require("bocchi") -- provided by this dependency
    local hex = bocchi.oklch_to_hex(0.7, 0.08, 230)
    -- use hex in your highlights...
  end,
}
```

### packer.nvim
```lua
use {
  "author/your-colorscheme-or-plugin",
  requires = { "KijitoraFinch/bocchi-the-lch.nvim" },
  config = function()
    local bocchi = require("bocchi")
    local hex = bocchi.oklch_to_hex(0.7, 0.08, 230)
    -- use hex as needed...
  end,
}
```

Usage example:
```lua
local bocchi = require("bocchi")
local hex = bocchi.oklch_to_hex(0.7, 0.08, 230) -- => "#RRGGBB"
```
or, if you want to use `oklch(l, c, h)` directly for convenience:
```lua
local oklch = require("bocchi").oklch_to_hex
local hex = oklch(0.7, 0.08, 230)
```

### Other Lua projects
You can simply copy and paste functions in `lua/bocchi/init.lua` into your project. It is less than 100 lines of code.

## API

All functions are exported from `lua/bocchi/init.lua` via `require("bocchi")`.

- `oklch_to_srgb(L, C, h) -> { r, g, b }`
  - Converts OKLCH to gamma‑corrected sRGB in 0–1 space.
  - Params: `L` in `[0,1]`, `C` ≥ `0`, `h` in degrees `[0,360)`.
  - Note: values may fall outside `[0,1]` for out‑of‑gamut colors. Use `clamp01` per channel or `oklch_to_hex` which clamps internally.

- `oklch_to_hex(L, C, h) -> string` (e.g. `"#RRGGBB"`)
  - Converts OKLCH to sRGB hex. Channels are clamped to `[0,1]` internally before quantization.

- `clamp01(x) -> number`
  - Helper to clamp a scalar to `[0,1]`.

- `to_hex({ r, g, b }) -> string`
  - Converts an sRGB triple (0–1 range expected) to hex. Each channel is clamped using `clamp01`.

### Quick examples
```lua
local M = require("bocchi")

-- Pastel blue via OKLCH
local hex = M.oklch_to_hex(0.82, 0.06, 240)  -- => "#AFCBFF" (approx)

-- Get float RGB (0–1). May be slightly <0 or >1 if out of gamut.
local rgb = M.oklch_to_srgb(0.6, 0.12, 30)
local safe_rgb = { r = M.clamp01(rgb.r), g = M.clamp01(rgb.g), b = M.clamp01(rgb.b) }
local hex2 = M.to_hex(safe_rgb)

-- Example: apply to a Neovim highlight in your plugin
vim.api.nvim_set_hl(0, "MyTitle", { fg = hex, bold = true })
```
