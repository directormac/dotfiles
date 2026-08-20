local file_ignore_patterns = {
  ".git",
  -- Elixir Ignores
  "_build",
  "deps",
  ".elixir_ls",
  ".expert",
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
  "src/content/docs/reference/.*",
}

return {
  {
    "ibhagwan/fzf-lua",
    opts = function(_, opts)
      return vim.tbl_deep_extend("force", opts, {

        file_ignore_patterns = file_ignore_patterns,

        files = {
          cwd_prompt = true,
          find_opts = [[-type f -not -path '*/\.git/*']],
          -- rg_opts = [[--color=never --files --hidden --follow -g "!.git"]],
          -- fd_opts = [[--color=never --type f --hidden --follow --exclude .git]],
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
