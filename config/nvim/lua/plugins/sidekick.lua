return {
  {
    'sidekick.nvim',
    pkgs = {
      'folke/sidekick.nvim',
    },
    cmd = { 'Sidekick' },
    keys = {
      {
        '<c-.>',
        function() require('sidekick.cli').toggle() end,
        mode = { 'n', 't', 'i', 'x' },
        desc = 'Sidekick Toggle',
      },
      { '<leader>aa', function() require('sidekick.cli').toggle() end, desc = 'Sidekick Toggle CLI' },
      { '<leader>as', function() require('sidekick.cli').select() end, desc = 'Select CLI' },
      { '<leader>ad', function() require('sidekick.cli').close() end, desc = 'Detach a CLI Session' },
      {
        '<leader>at',
        function() require('sidekick.cli').send({ msg = '{this}' }) end,
        mode = { 'x', 'n' },
        desc = 'Send This',
      },
      { '<leader>af', function() require('sidekick.cli').send({ msg = '{file}' }) end, desc = 'Send File' },
      {
        '<leader>av',
        function() require('sidekick.cli').send({ msg = '{selection}' }) end,
        mode = 'x',
        desc = 'Send Visual Selection',
      },
      {
        '<leader>ap',
        function() require('sidekick.cli').prompt() end,
        mode = { 'n', 'x' },
        desc = 'Sidekick Select Prompt',
      },
      {
        '<leader>ac',
        function() require('sidekick.cli').toggle({ name = 'claude', focus = true }) end,
        desc = 'Sidekick Toggle Claude',
      },
    },
    after = function()
      require('sidekick').setup({
        cli = {
          win = {
            split = {
              width = 120,
            },
          },
          tools = {
            amp = { cmd = { 'amp', 'threads', 'continue' } },
            antigravity = { cmd = { 'agy', '--continue' } },
            codex = { cmd = { 'codex', 'resume', '--last' } },
            opencode = { cmd = { 'opencode', '--continue' } },
            gemini = { cmd = { 'gemini', '--resume' } },
            pi = { cmd = { 'pi', '--continue' } },
            omp = { cmd = { 'omp', '--resume' } },
            vibe = { cmd = { 'vibe', '--continue' } },
            claude = {
              cmd = {
                'claude',
                '--continue',
                '--allowedTools=Bash(gh:*)',
                '--allowedTools=RunBash(go:*)',
                '--allowedTools=Read(~/code/public/**)',
              },
            },
            ['pi via omlx'] = {
              cmd = { 'omlx', 'launch', 'pi', '--continue' },
            },
          },
        },
      })
    end,
  },
}
