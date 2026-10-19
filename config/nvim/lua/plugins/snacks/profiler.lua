-- Snacks Profiler
--
-- Work around a missing file extension when the profiler resolves the source
-- of a function that lives in the Neovim runtime.
--
-- The profiler derives the file to read from the chunkname of the function
-- and then reads it with `readfile`. Neovim 0.13 uses extension-less
-- chunknames for some of its runtime modules (`vim/_core/shared` is the one
-- that shows up in practice, e.g. for `vim.list.bisect`), so the derived path
-- does not exist and the profiler aborts with
-- `E484: Can't open file .../runtime/lua/vim/_core/shared`.
--
-- Resolve the `.lua` file first so that the location can be found.
return {
  'snacks.nvim',
  init = function()
    local loc = require('snacks.profiler.loc')
    local ts_locs = loc.ts_locs

    loc.ts_locs = function(file)
      if vim.fn.filereadable(file) == 0 and vim.fn.filereadable(file .. '.lua') == 1 then file = file .. '.lua' end

      return ts_locs(file)
    end
  end,
}
