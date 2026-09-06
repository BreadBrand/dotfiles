-- Bubbles config for lualine
-- Author: lokesh-krishna
-- MIT license, see LICENSE for more details.

local colorsRP = {
  base           = '#191724',
  surface        = '#1f1d2e',
  overlay        = '#26233a',
  muted          = '#6e6a86',
  subtle         = '#908caa',
  text           = '#e0def4',
  love           = '#eb6f92',
  gold           = '#f6c177',
  rose           = '#ebbcba',
  pine           = '#31748f',
  foam           = '#9ccfd8',
  iris           = '#c4a7e7',
  highlight_low  = '#21202e',
  highlight_med  = '#403d52',
  highlight_high = '#524f67',
}

local bubbles_theme = {
  normal = {
    a = { fg = colorsRP.base, bg = colorsRP.pine },
    b = { fg = colorsRP.rose, bg = colorsRP.overlay },
    c = { fg = colorsRP.text },
  },

  insert = { a = { fg = colorsRP.base, bg = colorsRP.rose } },
  visual = { a = { fg = colorsRP.base, bg = colorsRP.foam } },
  replace = { a = { fg = colorsRP.base, bg = colorsRP.love } },

  inactive = {
    a = { fg = colorsRP.text, bg = colorsRP.base },
    b = { fg = colorsRP.text, bg = colorsRP.base },
    c = { fg = colorsRP.text },
  },
}

require('lualine').setup {
  options = {
    theme = bubbles_theme,
    component_separators = '',
    section_separators = { left = '', right = '' },
  },
  sections = {
    lualine_a = { { 'mode', separator = { left = '' }, right_padding = 2 } },
    lualine_b = { { "filename", path = 1 }, { "branch", icon = "" } },
    lualine_c = {
      '%=', --[[ add your center components here in place of this comment ]]
    },
    lualine_x = {},
    lualine_y = { 'filetype', 'progress' },
    lualine_z = {
      { 'location', separator = { right = '' }, left_padding = 2 },
    },
  },
  inactive_sections = {
    lualine_a = { 'filename' },
    lualine_b = {},
    lualine_c = {},
    lualine_x = {},
    lualine_y = {},
    lualine_z = { 'location' },
  },
  tabline = {},
  extensions = {},
}
