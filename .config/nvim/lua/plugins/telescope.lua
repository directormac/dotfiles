return {
  {
    "nvim-telescope/telescope-file-browser.nvim",
    keys = {
      {
        "<leader>fB",
        "<cmd>Telescope file_browser file_browser previewer=false hidden=true<cr>",
        { desc = "Browse Files in root directory" },
      },
    },
    event = "VeryLazy",
    dependencies = "nvim-telescope/telescope.nvim",
    config = function(_, opts)
      require("telescope").load_extension("file_browser")
    end,
  },
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "make",
    conf = vim.fn.executable("make") == 1,
    event = "VeryLazy",
    dependencies = "nvim-telescope/telescope.nvim",
    config = function(_, opts)
      require("telescope").load_extension("fzf")
    end,
  },
  {
    "nvim-telescope/telescope.nvim",
    opts = {
      defaults = {
        vimgrep_arguments = {
          "rg",
          "--color=never",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
          "--smart-case",
          "--hidden",
          "--glob",
          "!**/.git/*",
          "--glob",
          "!**/**-lock.yaml",
          "--glob",
          "!**/dist/*",
          "--glob",
          "!**/build/*",
          "--glob",
          "!**/.svelte-kit/*",
          "--glob",
          "!**/.nuxt/*",
          "--glob",
          "!**/.next/*",
          "--glob",
          "!**/.target/*",
          "--glob",
          "!**/test-results/*",
          "--glob",
          "!**/.yarn/*",
          "--glob",
          "!**/playwright-report/*",
          "-L",
        },
        -- NOTE: Add Ignore Patterns here
        file_ignore_patterns = {
          ".git/", -- ignore git files
          "node_modules/", -- ignore node_modules
          "tmp/", -- tmp folders ignore
          "build/", -- Build Folders
          "./dist/", -- Dist Folders
          ".svelte-kit/", -- Svelte kit
          ".nuxt/", -- Svelte kit
          ".target/", -- Rust Target
          ".next/", -- Next Ignore
          ".vitepress/cache/*", -- Vitepress Cache Ignore
          "**/**-lock.yaml",
          "**/.yarn",
          "**/test-results/",
          "**/playwright-report/",
        },
      },
      pickers = {
        find_files = {
          find_command = {
            "rg",
            "--files",
            "--hidden",
            "--glob",
            "!**/.git/*",
            "--glob",
            "!**/**-lock.yaml",
            "--glob",
            "!**/dist/*",
            "--glob",
            "!**/build/*",
            "--glob",
            "!**/.svelte-kit/*",
            "--glob",
            "!**/.nuxt/*",
            "--glob",
            "!**/.next/*",
            "--glob",
            "!**/.target/*",
            "--glob",
            "!**/test-results/*",
            "--glob",
            "!**/.yarn/*",
            "--glob",
            "!**/playwright-report/*",
            "-L",
          },
        },
      },
    },
  },
}
