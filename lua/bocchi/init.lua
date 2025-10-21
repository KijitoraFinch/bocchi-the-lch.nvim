-- Bocchi The LCH
--
-- SPDX-License-Identifier: MIT OR LicenseRef-Yamada-Ryo-Riceware
-- Copyright (c) 2025 標準偏差/KijitoraFinch

local M = {}

local function deg2rad(d) return d * math.pi / 180 end
local function rad2deg(r) return r * 180 / math.pi end

---------------------------------------------------------
-- OKLab → linear sRGB
---------------------------------------------------------
local function oklab_to_linear_srgb(c)
    local l_ = c.L + 0.3963377774 * c.a + 0.2158037573 * c.b
    local m_ = c.L - 0.1055613458 * c.a - 0.0638541728 * c.b
    local s_ = c.L - 0.0894841775 * c.a - 1.2914855480 * c.b

    local l = l_ * l_ * l_
    local m = m_ * m_ * m_
    local s = s_ * s_ * s_

    return {
        r = 4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s,
        g = -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s,
        b = -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s,
    }
end

---------------------------------------------------------
-- Linear sRGB → gamma-corrected sRGB
---------------------------------------------------------
local function linear_to_srgb(x)
    if x <= 0.0031308 then
        return 12.92 * x
    else
        return 1.055 * (x) ^ (1 / 2.4) - 0.055
    end
end

---------------------------------------------------------
-- OKLCH → OKLab
---------------------------------------------------------
local function oklch_to_oklab(c)
    local a = c.C * math.cos(deg2rad(c.h))
    local b = c.C * math.sin(deg2rad(c.h))
    return { L = c.L, a = a, b = b }
end

---------------------------------------------------------
-- OKLab → OKLCH
---------------------------------------------------------
local function oklab_to_oklch(c)
    local C = math.sqrt(c.a * c.a + c.b * c.b)
    local h = rad2deg(math.atan2(c.b, c.a))
    if h < 0 then h = h + 360 end
    return { L = c.L, C = C, h = h }
end

---------------------------------------------------------
-- OKLCH → sRGB (0–1)
---------------------------------------------------------
function M.oklch_to_srgb(L, C, h)
    local lab = oklch_to_oklab { L = L, C = C, h = h }
    local rgb_lin = oklab_to_linear_srgb(lab)
    return {
        r = linear_to_srgb(rgb_lin.r),
        g = linear_to_srgb(rgb_lin.g),
        b = linear_to_srgb(rgb_lin.b),
    }
end

---------------------------------------------------------
-- OKLCH → sRGB hex
---------------------------------------------------------
function M.oklch_to_hex(L, C, h)
    local rgb = M.oklch_to_srgb(L, C, h)
    return M.to_hex(rgb)
end

---------------------------------------------------------
-- Clamp helper
---------------------------------------------------------
function M.clamp01(x)
    if x < 0 then return 0 elseif x > 1 then return 1 else return x end
end

---------------------------------------------------------
-- Convert to hex
---------------------------------------------------------
function M.to_hex(rgb)
    local function to8bit(x) return math.floor(M.clamp01(x) * 255 + 0.5) end
    return string.format("#%02X%02X%02X", to8bit(rgb.r), to8bit(rgb.g), to8bit(rgb.b))
end

return M
