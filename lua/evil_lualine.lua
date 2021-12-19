--  Eviline config for lualine
-- Author: shadmansaleh
-- Credit: glepnir
local lualine = require 'lualine'
local gps = require("nvim-gps")

-- require("lualine").setup({
-- 	sections = {
-- 			lualine_c = {
-- 				{ gps.get_location, cond = gps.is_available },
-- 			}
-- 	}
-- })
-- Color table for highlights
local colors = {
  bg = '#202328',
  fg = '#bbc2cf',
  yellow = '#ECBE7B',
  cyan = '#008080',
  darkblue = '#081633',
  green = '#98be65',
  orange = '#FF8800',
  violet = '#a9a1e1',
  magenta = '#c678dd',
  blue = '#51afef',
  red = '#ec5f67'
}

local conditions = {
  buffer_not_empty = function() return vim.fn.empty(vim.fn.expand('%:t')) ~= 1 end,
  hide_in_width = function() return vim.fn.winwidth(0) > 80 end,
  check_git_workspace = function()
    local filepath = vim.fn.expand('%:p:h')
    local gitdir = vim.fn.finddir('.git', filepath .. ';')
    return gitdir and #gitdir > 0 and #gitdir < #filepath
  end
}

-- Config
local config = {
  options = {
    -- Disable sections and component separators
    component_separators = "",
    section_separators = "",
    theme = {
      -- We are going to use lualine_c an lualine_x as left and
      -- right section. Both are highlighted by c theme .  So we
      -- are just setting default looks o statusline
      normal = {c = {fg = colors.fg, bg = colors.bg}},
      inactive = {c = {fg = colors.fg, bg = colors.bg}}
    }
  },
  sections = {
    -- these are to remove the defaults
    lualine_a = {},
    lualine_b = {},
    lualine_y = {},
    lualine_z = {},
    -- These will be filled later
    lualine_c = {
        {gps.get_location , cond=gps.is_available},
    },
    lualine_x = {}
  },
  inactive_sections = {
    -- these are to remove the defaults
    lualine_a = {},
    lualine_v = {},
    lualine_y = {},
    lualine_z = {},
    lualine_c = {},
    lualine_x = {}
  }
}

-- Inserts a component in lualine_c at left section
local function ins_left(component)
  table.insert(config.sections.lualine_c, component)
end

-- Inserts a component in lualine_x ot right section
local function ins_right(component)
  table.insert(config.sections.lualine_x, component)
end

ins_left {
  function() return '▊' end,
  color = {fg = colors.blue}, -- Sets highlighting of component
  left_padding = 0 -- We don't need space before this
}

ins_left {
  -- mode component
  function()
    -- auto change color according to neovims mode
    local mode_color = {
      n = colors.red,
      i = colors.green,
      v = colors.blue,
      [''] = colors.blue,
      V = colors.blue,
      c = colors.magenta,
      no = colors.red,
      s = colors.orange,
      S = colors.orange,
      [''] = colors.orange,
      ic = colors.yellow,
      R = colors.violet,
      Rv = colors.violet,
      cv = colors.red,
      ce = colors.red,
      r = colors.cyan,
      rm = colors.cyan,
      ['r?'] = colors.cyan,
      ['!'] = colors.red,
      t = colors.red
    }
    vim.api.nvim_command(
        'hi! LualineMode guifg=' .. mode_color[vim.fn.mode()] .. " guibg=" ..
            colors.bg)
    return ''
  end,
  color = "LualineMode",
  left_padding = 0
}

ins_left {
  -- filesize component
  function()
    local function format_file_size(file)
      local size = vim.fn.getfsize(file)
      if size <= 0 then return '' end
      local sufixes = {'b', 'k', 'm', 'g'}
      local i = 1
      while size > 1024 do
        size = size / 1024
        i = i + 1
      end
      return string.format('%.1f%s', size, sufixes[i])
    end
    local file = vim.fn.expand('%:p')
    if string.len(file) == 0 then return '' end
    return format_file_size(file)
  end,
  condition = conditions.buffer_not_empty
}

ins_left {
  'filename',
  condition = conditions.buffer_not_empty,
  color = {fg = colors.magenta}
}

ins_left {'location'}

ins_left {'progress', color = {fg = colors.fg, gui = 'bold'}}

ins_left {
  'diagnostics',
  sources = {'nvim_lsp'},
  symbols = {error = ' ', warn = ' ', info = ' '},
  color_error = colors.red,
  color_warn = colors.yellow,
  color_info = colors.cyan

}

-- Insert mid section. You can make any number of sections in neovim :)
-- for lualine it's any number greater then 2
ins_left {function() return '%=' end}

ins_left {
  -- Lsp server name .
  function()
    local msg = 'No Active Lsp'
    local buf_ft = vim.api.nvim_buf_get_option(0, 'filetype')
    local clients = vim.lsp.get_active_clients()
    if next(clients) == nil then return msg end
    for _, client in ipairs(clients) do
      local filetypes = client.config.filetypes
      if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
        return client.name
      end
    end
    return msg
  end,
  icon = ' ',
  color = {fg = '#ffffff'}
}

-- Add components to right sections
ins_right {
  'o:encoding', -- option component same as &encoding in viml
  upper = true, -- I'm not sure why it's upper case either ;)
  condition = conditions.hide_in_width,
  color = {fg = colors.green}
}

ins_right {
  'fileformat',
  upper = true,
  icons_enabled = false, -- I think icons are cool but Eviline doesn't have them. sigh
  color = {fg = colors.green}
}

ins_right {
  'branch',
  icon = '',
  condition = conditions.check_git_workspace,
  color = {fg = colors.violet, gui = 'bold'}
}

ins_right {
  'diff',
  -- Is it me or the symbol for modified us really weird
  symbols = {added = ' ', modified = '柳 ', removed = ' '},
  color_added = colors.green,
  color_modified = colors.orange,
  color_removed = colors.red,
  condition = conditions.hide_in_width
}

ins_right {
  function() return '▊' end,
  color = {fg = colors.blue},
  right_padding = 0
}

-- Now don't forget to initialize lualine
lualine.setup(config)



-- slanted-gaps.lua
-- local colors = {
--   red = '#ca1243',
--   grey = '#a0a1a7',
--   black = '#383a42',
--   white = '#f3f3f3',
--   light_green = '#83a598',
--   orange = '#fe8019',
--   green = '#8ec07c',
-- }
--
-- local theme = {
--   normal = {
--     a = { fg = colors.white, bg = colors.black },
--     b = { fg = colors.white, bg = colors.grey },
--     c = { fg = colors.black, bg = colors.white },
--     z = { fg = colors.white, bg = colors.black },
--   },
--   insert = { a = { fg = colors.black, bg = colors.light_green } },
--   visual = { a = { fg = colors.black, bg = colors.orange } },
--   replace = { a = { fg = colors.black, bg = colors.green } },
-- }
--
-- -- local empty = require('lualine.component'):extend()
-- -- function empty:draw(default_highlight)
-- --   self.status = ''
-- --   self.applied_separator = ''
-- --   self:apply_highlights(default_highlight)
-- --   self:apply_section_separators()
-- --   return self.status
-- -- end
-- --
-- -- Put proper separators and gaps between components in sections
-- local function process_sections(sections)
--   for name, section in pairs(sections) do
--     local left = name:sub(9, 10) < 'x'
--     for pos = 1, name ~= 'lualine_z' and #section or #section - 1 do
--       table.insert(section, pos * 2, { empty, color = { fg = colors.white, bg = colors.white } })
--     end
--     for id, comp in ipairs(section) do
--       if type(comp) ~= 'table' then
--         comp = { comp }
--         section[id] = comp
--       end
--       comp.separator = left and { right = '' } or { left = '' }
--     end
--   end
--   return sections
-- end
--
-- local function search_result()
--   if vim.v.hlsearch == 0 then
--     return ''
--   end
--   local last_search = vim.fn.getreg '/'
--   if not last_search or last_search == '' then
--     return ''
--   end
--   local searchcount = vim.fn.searchcount { maxcount = 9999 }
--   return last_search .. '(' .. searchcount.current .. '/' .. searchcount.total .. ')'
-- end
--
-- local function modified()
--   if vim.bo.modified then
--     return '+'
--   elseif vim.bo.modifiable == false or vim.bo.readonly == true then
--     return '-'
--   end
--   return ''
-- end
--
-- require('lualine').setup {
--   options = {
--     theme = theme,
--     component_separators = '',
--     section_separators = { left = '', right = '' },
--   },
--   sections = process_sections {
--     lualine_a = { 'mode' },
--     lualine_b = {
--       'branch',
--       'diff',
--       {
--         'diagnostics',
--         source = { 'nvim' },
--         sections = { 'error' },
--         diagnostics_color = { error = { bg = colors.red, fg = colors.white } },
--       },
--       {
--         'diagnostics',
--         source = { 'nvim' },
--         sections = { 'warn' },
--         diagnostics_color = { warn = { bg = colors.orange, fg = colors.white } },
--       },
--       { 'filename', file_status = false, path = 1 },
--       { modified, color = { bg = colors.red } },
--       {
--         '%w',
--         cond = function()
--           return vim.wo.previewwindow
--         end,
--       },
--       {
--         '%r',
--         cond = function()
--           return vim.bo.readonly
--         end,
--       },
--       {
--         '%q',
--         cond = function()
--           return vim.bo.buftype == 'quickfix'
--         end,
--       },
--     },
--     lualine_c = {},
--     lualine_x = {},
--     lualine_y = { search_result, 'filetype' },
--     lualine_z = { '%l:%c', '%p%%/%L' },
--   },
--   inactive_sections = {
--     lualine_c = { '%f %y %m' },
--     lualine_x = {},
--   },
-- }
--
