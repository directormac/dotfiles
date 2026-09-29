return {
  {
    "nvim-mini/mini.snippets",
    opts = function(_, opts)
      local snippets = require("mini.snippets")
      opts.snippets = {
        -- Load custom global snippets
        snippets.gen_loader.from_file(vim.fn.stdpath("config") .. "/snippets/global.json"),
        snippets.gen_loader.from_file(vim.fn.stdpath("config") .. "/snippets/all.json"),
        -- Load language-specific snippets
        snippets.gen_loader.from_lang(),
      }
    end,
  },
}
