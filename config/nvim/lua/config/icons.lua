local M = {}

M.diagnostics = {
  Error = ' ',
  Warn = ' ',
  Hint = ' ',
  Info = ' ',
}

M.dap = {
  Stopped = { '󰁕 ', 'DiagnosticWarn', 'DapStoppedLine' },
  Breakpoint = ' ',
  BreakpointCondition = ' ',
  BreakpointRejected = { ' ', 'DiagnosticError' },
  LogPoint = '.>',
}

M.git = {
  added = ' ',
  modified = ' ',
  removed = ' ',
  deleted = ' ',
  renamed = ' ',
  copied = '󰆑 ',
  conflict = ' ',
  untracked = ' ',
  ignored = ' ',
  staged = '✓ ',
  unstaged = '󰄱 ',
  branch = ' ',
}

M.kinds = {
  Array = ' ',
  Boolean = '󰨙 ',
  Class = ' ',
  Codeium = '󰘦 ',
  Color = ' ',
  Control = ' ',
  Collapsed = ' ',
  Constant = '󰏿 ',
  Constructor = ' ',
  Copilot = ' ',
  Enum = ' ',
  EnumMember = ' ',
  Event = ' ',
  Field = ' ',
  File = ' ',
  Folder = ' ',
  Function = '󰊕 ',
  Interface = ' ',
  Key = ' ',
  Keyword = ' ',
  Method = '󰊕 ',
  Module = ' ',
  Namespace = '󰦮 ',
  Null = ' ',
  Number = '󰎠 ',
  Object = ' ',
  Operator = ' ',
  Package = ' ',
  Property = ' ',
  Reference = ' ',
  Snippet = '󱄽 ',
  String = ' ',
  Struct = '󰆼 ',
  TabNine = '󰏚 ',
  Text = ' ',
  TypeParameter = ' ',
  Unit = ' ',
  Value = ' ',
  Variable = '󰀫 ',
}

---@type table<string, string[]|boolean>?
M.kind_filter = {
  default = {
    'Class',
    'Constructor',
    'Enum',
    'Field',
    'Function',
    'Interface',
    'Method',
    'Module',
    'Namespace',
    'Package',
    'Property',
    'Struct',
    'Trait',
  },
  markdown = false,
  help = false,
  -- you can specify a different filter for each filetype
  lua = {
    'Class',
    'Constructor',
    'Enum',
    'Field',
    'Function',
    'Interface',
    'Method',
    'Module',
    'Namespace',
    -- "Package", -- remove package since luals uses it for control flow structures
    'Property',
    'Struct',
    'Trait',
  },
}

_G.Icons = M
return M
