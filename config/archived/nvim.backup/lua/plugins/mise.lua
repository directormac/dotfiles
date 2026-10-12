-- [Reference](https://mise.jdx.dev/mise-cookbook/neovim.html#mise-neovim-cookbook)
return {
  {
    "nvim-treesitter/nvim-treesitter",
    init = function()
      require("vim.treesitter.query").add_predicate("is-mise?", function(_, _, bufnr, _)
        local b = tonumber(bufnr) or 0

        -- 1. Check cache first to avoid heavy I/O on every keystroke
        if vim.b[b]._mise_checked then
          return vim.b[b]._is_mise_file
        end

        local filepath = vim.api.nvim_buf_get_name(b)
        local filename = vim.fn.fnamemodify(filepath, ":t")
        local is_mise = false

        -- 2. Check if it's explicitly a mise file
        if string.match(filename, ".*mise.*%.toml$") then
          is_mise = true
        -- 3. If it's tasks.toml, search upwards for a mise configuration file
        elseif filename == "tasks.toml" then
          local dir = vim.fs.dirname(filepath)
          local found = vim.fs.find({ "mise.toml", ".mise.toml" }, {
            path = dir,
            upward = true,
            type = "file",
          })
          is_mise = #found > 0
        end

        -- 4. Cache the result to the current buffer
        vim.b[b]._is_mise_file = is_mise
        vim.b[b]._mise_checked = true

        return is_mise
      end, { force = true, all = false })
    end,
  },
  -- {
  --   "nvim-treesitter/nvim-treesitter",
  --   init = function()
  --     require("vim.treesitter.query").add_predicate("is-mise?", function(_, _, bufnr, _)
  --       local filepath = vim.api.nvim_buf_get_name(tonumber(bufnr) or 0)
  --       local filename = vim.fn.fnamemodify(filepath, ":t")
  --       return string.match(filename, ".*mise.*%.toml$") ~= nil
  --     end, { force = true, all = false })
  --   end,
  -- },
  {
    "jmbuhr/otter.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      vim.api.nvim_create_autocmd({ "FileType" }, {
        pattern = { "toml" },
        group = vim.api.nvim_create_augroup("EmbedToml", {}),
        callback = function()
          require("otter").activate()
        end,
      })
    end,
  },
}
