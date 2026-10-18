local current_browser_mode = 'default'

local function get_preview_url()
  local ok, mdkite = pcall(require, 'mdkite')
  if not ok then return nil end

  local port = mdkite._server and mdkite._server.port or 8421
  return string.format('http://127.0.0.1:%d/', port)
end

local function open_in_ghostty(url)
  if vim.fn.executable('terminal-browser') == 1 then
    if vim.fn.executable('ghostty') == 1 then
      vim.fn.jobstart({ 'ghostty', '--title=Mdkite Preview (terminal-browser)', '-e', 'terminal-browser', url }, { detach = true })
    else
      vim.fn.jobstart({ 'terminal-browser', url }, { detach = true })
    end
  else
    vim.notify('terminal-browser not found; opening in default browser.', vim.log.levels.INFO)
    vim.ui.open(url)
  end
end

local function open_in_chromium_app(url)
  if vim.fn.executable('chromium') == 1 then
    vim.fn.jobstart({ 'chromium', '--app=' .. url }, { detach = true })
  else
    vim.ui.open(url)
  end
end

return {
  {
    'kitehost-nvim',
    load_before = { 'mdkite-nvim' },
    on_require = { 'kitehost' },
  },
  {
    'mdkite-nvim',
    cmd = {
      'MdKite',
      'MdKiteGhostty',
      'MdKiteApp',
      'MdKiteSelectBrowser',
    },
    on_require = { 'mdkite' },
    ft = { 'markdown', 'mermaid' },
    keys = {
      { '<leader>mp', '<cmd>MdKite toggle<cr>', desc = 'Toggle MdKite Preview' },
      { '<leader>mps', '<cmd>MdKite start<cr>', desc = 'Start MdKite Preview' },
      { '<leader>mpS', '<cmd>MdKite stop<cr>', desc = 'Stop MdKite Preview' },
      { '<leader>mpr', '<cmd>MdKite refresh<cr>', desc = 'Refresh MdKite Preview' },
      { '<leader>mpb', '<cmd>MdKiteSelectBrowser<cr>', desc = 'Select Preview Browser' },
      { '<leader>mpg', '<cmd>MdKiteGhostty<cr>', desc = 'Open Preview in Ghostty' },
      { '<leader>mpa', '<cmd>MdKiteApp<cr>', desc = 'Open Preview in App Window' },
    },
    opts = {
      instance_mode = 'takeover',
      open_browser = false,
      mermaid_renderer = 'rust',
      default_theme = 'dark',
      debounce_ms = 200,
      hooks = {
        on_start = function(url)
          if current_browser_mode == 'ghostty' then
            open_in_ghostty(url)
          elseif current_browser_mode == 'app' then
            open_in_chromium_app(url)
          else
            vim.ui.open(url)
          end
        end,
      },
    },
    after = function()
      vim.api.nvim_create_user_command('MdKiteGhostty', function()
        current_browser_mode = 'ghostty'
        vim.cmd('MdKite start')
      end, { desc = 'Open MdKite preview in a new Ghostty instance' })

      vim.api.nvim_create_user_command('MdKiteApp', function()
        current_browser_mode = 'app'
        vim.cmd('MdKite start')
      end, { desc = 'Open MdKite preview in a standalone Chromium App window' })

      vim.api.nvim_create_user_command('MdKiteSelectBrowser', function()
        local choices = {
          { label = '1. Default Browser (Zen / System)', mode = 'default' },
          { label = '2. Standalone App Window (Chromium --app)', mode = 'app' },
          { label = '3. Terminal Browser in Ghostty (terminal-browser)', mode = 'ghostty' },
        }

        vim.ui.select(choices, {
          prompt = 'Select MdKite Preview Browser:',
          format_item = function(item) return item.label end,
        }, function(choice)
          if not choice then return end
          current_browser_mode = choice.mode
          vim.notify('MdKite preview browser set to: ' .. choice.label, vim.log.levels.INFO)
          if choice.mode == 'ghostty' then
            vim.cmd('MdKiteGhostty')
          elseif choice.mode == 'app' then
            vim.cmd('MdKiteApp')
          else
            vim.cmd('MdKite start')
          end
        end)
      end, { desc = 'Select MdKite preview browser target' })
    end,
  },
}
