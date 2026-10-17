return {
  'obsidian',
  cmd = { 'Obsidian' },

  keys = {

    -- Daily Notes
    { '<leader>nt', '<cmd>ObsidianToday<cr>', desc = 'Obsidian Today' },
    { '<leader>ny', '<cmd>ObsidianYesterday<cr>', desc = 'Obsidian Yesterday' },
    { '<leader>nn', '<cmd>ObsidianTomorrow<cr>', desc = 'Obsidian Tomorrow' },
    { '<leader>na', '<cmd>ObsidianDailies<cr>', desc = 'Obsidian Dailies (Picker)' },

    -- Navigation & Search
    { '<leader>ns', '<cmd>ObsidianSearch<cr>', desc = 'Obsidian Search' },
    { '<leader>nf', '<cmd>ObsidianQuickSwitch<cr>', desc = 'Obsidian Quick Switch (Find)' },
    { '<leader>no', '<cmd>ObsidianOpen<cr>', desc = 'Obsidian Open in App' },
    { '<leader>nw', '<cmd>ObsidianWorkspace<cr>', desc = 'Obsidian Switch Workspace' },

    -- Creation & Templates
    { '<leader>nc', '<cmd>ObsidianNew<cr>', desc = 'Obsidian Create New Note' },
    { '<leader>ni', '<cmd>ObsidianTemplate<cr>', desc = 'Obsidian Insert Template' },
    { '<leader>nN', '<cmd>ObsidianNewFromTemplate<cr>', desc = 'Obsidian New From Template' },

    -- Note Manipulation
    { '<leader>nb', '<cmd>ObsidianBacklinks<cr>', desc = 'Obsidian Backlinks' },
    { '<leader>nl', '<cmd>ObsidianLinks<cr>', desc = 'Obsidian Links (In Buffer)' },
    { '<leader>nr', '<cmd>ObsidianRename<cr>', desc = 'Obsidian Rename Note' },
    { '<leader>ntc', '<cmd>ObsidianToggleCheckbox<cr>', desc = 'Obsidian Toggle Checkbox' },
    { '<leader>nT', '<cmd>ObsidianTOC<cr>', desc = 'Obsidian Table of Contents' },

    -- Visual Mode (Highlight text first)
    { '<leader>nk', ':ObsidianLink<cr>', mode = 'v', desc = 'Obsidian Link Selection' },
    { '<leader>nK', ':ObsidianLinkNew<cr>', mode = 'v', desc = 'Obsidian Link New Note' },
    { '<leader>nx', ':ObsidianExtractNote<cr>', mode = 'v', desc = 'Obsidian Extract to Note' },

    -- Utility
    { '<leader>np', '<cmd>ObsidianPasteImg<cr>', desc = 'Obsidian Paste Image' },

    -- {
    --   "gf",
    --   function()
    --     if require("obsidian").util.cursor_on_markdown_link() then
    --       return "<cmd>ObsidianFollowLink<cr>"
    --     else
    --       return "gf"
    --     end
    --   end,
    --   noremap = false,
    --   expr = true,
    --   desc = "Obsidian Follow Link",
    -- },
  },
  opts = {
    workspaces = {
      {
        name = 'Vault',
        path = '~/Notes',
      },
      {
        name = 'Areas',
        path = '~/Notes/areas',
      },
      {
        name = 'Resources',
        path = '~/Notes/resources',
      },
      {
        name = 'Public',
        path = '~/Notes/public',
      },
    },

    -- see below for full list of options 👇
    notes_subdir = 'resrouces/notes',

    note_frontmatter_func = function(note)
      if note.title then note:add_alias(note.title) end
      local out = { id = note.id, aliases = note.aliases, tags = note.tags }
      if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
        for k, v in pairs(note.metadata) do
          out[k] = v
        end
      end
      return out
    end,

    daily_notes = {
      folder = 'areas/dailies',
      date_format = '%Y-%m-%d',
      alias_format = '%B %-d, %Y',
      default_tags = { 'daily-notes' },
      template = 'daily.md',
    },

    templates = {
      folder = 'templates',
      date_format = '%Y-%m-%d',
      substitutions = {
        desc = function() return 'Post created on ' .. os.date('%Y-%m-%d') end,
      },
    },
  },
}
