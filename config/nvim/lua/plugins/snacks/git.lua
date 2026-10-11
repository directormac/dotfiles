local M = {}

M.opts = {
  git = {},
  gh = {},
  gitbrowse = {},
}

function M.keys()
  local map = function(mode, lhs, rhs, opts)
    opts = opts or {}
    vim.keymap.set(mode, lhs, rhs, opts)
  end

  map({ 'n', 'v' }, '<leader>go', function() Snacks.gitbrowse() end, { desc = 'Git Browse (Remote)' })
  map('n', '<leader>gb', function() Snacks.picker.git_branches() end, { desc = 'Git Branches' })
  map('n', '<leader>gl', function() Snacks.picker.git_log() end, { desc = 'Git Log' })
  map('n', '<leader>gL', function() Snacks.picker.git_log_line() end, { desc = 'Git Log Line' })
  map('n', '<leader>gs', function() Snacks.picker.git_status() end, { desc = 'Git Status' })
  map('n', '<leader>gS', function() Snacks.picker.git_stash() end, { desc = 'Git Stash' })
  map('n', '<leader>gd', function() Snacks.picker.git_diff() end, { desc = 'Git Diff (Hunks)' })
  map('n', '<leader>gf', function() Snacks.picker.git_log_file() end, { desc = 'Git Log File' })

  -- GitHub
  map('n', '<leader>gi', function() Snacks.picker.gh_issue() end, { desc = 'GitHub Issues (open)' })
  map('n', '<leader>gI', function() Snacks.picker.gh_issue({ state = 'all' }) end, { desc = 'GitHub Issues (all)' })
  map('n', '<leader>gp', function() Snacks.picker.gh_pr() end, { desc = 'GitHub Pull Requests (open)' })
  map('n', '<leader>gP', function() Snacks.picker.gh_pr({ state = 'all' }) end, { desc = 'GitHub Pull Requests (all)' })
end

return M
