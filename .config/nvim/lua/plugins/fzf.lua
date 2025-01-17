local file_ignore_patterns = {
  ".git",
  -- Elixir Ignores
  "_build",
  "deps",
  ".elixir_ls",
  -- JS Ignores
  "node_modules",
  "**-lock.yaml",
  "lazy-lock.json",
  "dist",
  "build",
  ".svelte-kit",
  ".nuxt",
  ".turbo",
  ".tsup",
  ".next",
  ".target",
  "test-results",
  ".yarn",
  "playwright-report",
  -- Others
  ".gradle",
}

return {
  {
    "ibhagwan/fzf-lua",
    opts = function(_, opts)
      return vim.tbl_deep_extend("force", opts, {

        file_ignore_patterns = file_ignore_patterns,

        files = {
          resume = true,
          cwd_prompt = true,
        },
        grep = {
          rg_glob = true,
          glob_flag = "--iglob",
          glob_separator = "%s%-%-",
          resume = true,
          cwd_prompt = true,
        },
      })
    end,
  },
}
