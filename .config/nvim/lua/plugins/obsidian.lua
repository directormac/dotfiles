return {
  "epwalsh/obsidian.nvim",
  keys = {
    -- { "<leader>on", "<cmd>ObsidianToday<cr>", desc = "Obsidian Today" },
    -- { "<leader>oq", "<cmd>ObsidianQuickNote<cr>", desc = "Obsidian Quick Note" },
    -- { "<leader>os", "<cmd>ObsidianSearch<cr>", desc = "Obsidian Search" },

    -- Daily Notes
    { "<leader>ot", "<cmd>ObsidianToday<cr>", desc = "Obsidian Today" },
    { "<leader>oy", "<cmd>ObsidianYesterday<cr>", desc = "Obsidian Yesterday" },
    { "<leader>on", "<cmd>ObsidianTomorrow<cr>", desc = "Obsidian Tomorrow" },
    { "<leader>oa", "<cmd>ObsidianDailies<cr>", desc = "Obsidian Dailies (Picker)" },

    -- Navigation & Search
    { "<leader>os", "<cmd>ObsidianSearch<cr>", desc = "Obsidian Search" },
    { "<leader>of", "<cmd>ObsidianQuickSwitch<cr>", desc = "Obsidian Quick Switch (Find)" },
    { "<leader>oo", "<cmd>ObsidianOpen<cr>", desc = "Obsidian Open in App" },
    { "<leader>ow", "<cmd>ObsidianWorkspace<cr>", desc = "Obsidian Switch Workspace" },

    -- Creation & Templates
    { "<leader>oc", "<cmd>ObsidianNew<cr>", desc = "Obsidian Create New Note" },
    { "<leader>oi", "<cmd>ObsidianTemplate<cr>", desc = "Obsidian Insert Template" },
    { "<leader>oN", "<cmd>ObsidianNewFromTemplate<cr>", desc = "Obsidian New From Template" },

    -- Note Manipulation
    { "<leader>ob", "<cmd>ObsidianBacklinks<cr>", desc = "Obsidian Backlinks" },
    { "<leader>ol", "<cmd>ObsidianLinks<cr>", desc = "Obsidian Links (In Buffer)" },
    { "<leader>or", "<cmd>ObsidianRename<cr>", desc = "Obsidian Rename Note" },
    { "<leader>otc", "<cmd>ObsidianToggleCheckbox<cr>", desc = "Obsidian Toggle Checkbox" },
    { "<leader>oT", "<cmd>ObsidianTOC<cr>", desc = "Obsidian Table of Contents" },

    -- Visual Mode (Highlight text first)
    { "<leader>ok", ":ObsidianLink<cr>", mode = "v", desc = "Obsidian Link Selection" },
    { "<leader>oK", ":ObsidianLinkNew<cr>", mode = "v", desc = "Obsidian Link New Note" },
    { "<leader>ox", ":ObsidianExtractNote<cr>", mode = "v", desc = "Obsidian Extract to Note" },

    -- Utility
    { "<leader>op", "<cmd>ObsidianPasteImg<cr>", desc = "Obsidian Paste Image" },
    {
      "gf",
      function()
        if require("obsidian").util.cursor_on_markdown_link() then
          return "<cmd>ObsidianFollowLink<cr>"
        else
          return "gf"
        end
      end,
      noremap = false,
      expr = true,
      desc = "Obsidian Follow Link",
    },
  },
  version = "*", -- recommended, use latest release instead of latest commit
  lazy = true,
  ft = "markdown",
  -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
  -- event = {
  --   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
  --   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
  --   -- refer to `:h file-pattern` for more examples
  --   "BufReadPre path/to/my-vault/*.md",
  --   "BufNewFile path/to/my-vault/*.md",
  -- },
  dependencies = {
    -- Required.
    "nvim-lua/plenary.nvim",

    -- see below for full list of optional dependencies 👇
  },
  opts = {
    workspaces = {
      {
        name = "Vault",
        path = "~/Notes",
      },
      {
        name = "Areas",
        path = "~/Notes/areas",
      },
      {
        name = "Resources",
        path = "~/Notes/resources",
      },
      {
        name = "Public",
        path = "~/Notes/public",
      },
    },

    -- see below for full list of options 👇
    notes_subdir = "resrouces/notes",

    note_frontmatter_func = function(note)
      if note.title then
        note:add_alias(note.title)
      end
      local out = { id = note.id, aliases = note.aliases, tags = note.tags }
      if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
        for k, v in pairs(note.metadata) do
          out[k] = v
        end
      end
      return out
    end,

    daily_notes = {
      folder = "areas/dailies",
      date_format = "%Y-%m-%d",
      alias_format = "%B %-d, %Y",
      default_tags = { "daily-notes" },
      template = "daily.md",
    },

    templates = {
      folder = "templates",
      date_format = "%Y-%m-%d",
      substitutions = {
        desc = function()
          return "Post created on " .. os.date("%Y-%m-%d")
        end,
      },
    },
  },
}
