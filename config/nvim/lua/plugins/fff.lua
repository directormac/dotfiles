-- fff.nvim: patch the file renderer so the path is rendered *before* the
-- file name (`modules/docs/readme.nix` instead of `readme.nix modules/docs`).
--
-- fff renders `<icon> <name> <dir>` and has no option to change that order,
-- so the renderer is wrapped here. The patch is a no-op when
-- `layout.show_path_first` is false.

local function path_first_enabled()
  local ok, conf = pcall(require, 'fff.conf')
  if not ok then return true end
  local cfg = conf.get() or {}
  local layout = cfg.layout or {}
  if layout.show_path_first == nil then return true end
  return layout.show_path_first ~= false
end

---@return string, string the directory path and the file name
local function split_display(item, ctx)
  local icon, _ = require('fff.file_picker.icons').get_icon(item.name, item.extension, false)
  local icon_width = icon and (vim.fn.strdisplaywidth(icon) + 1) or 0
  local available_width = math.max(ctx.max_path_width - icon_width, 40)
  local filename, dir_path = ctx.format_file_display(item, available_width)
  return dir_path, filename
end

local function apply_path_first_patch()
  local ok, file_renderer = pcall(require, 'fff.picker_ui.file_renderer')
  if not ok or file_renderer.__path_first_patched then return end

  local original_render_line = file_renderer.render_line
  local original_apply_highlights = file_renderer.apply_highlights

  file_renderer.__path_first_patched = true

  file_renderer.render_line = function(item, ctx, item_idx)
    if not path_first_enabled() then return original_render_line(item, ctx, item_idx) end

    local icons = require('fff.file_picker.icons')
    local icon, _ = icons.get_icon(item.name, item.extension, false)

    -- Frecency indicator (debug mode only)
    local frecency = ''
    if ctx.debug_enabled then
      local total = item.total_frecency_score or 0
      local access = item.access_frecency_score or 0
      local mod = item.modification_frecency_score or 0
      if total > 0 then
        local indicator = ''
        if mod >= 6 then
          indicator = '🔥'
        elseif access >= 4 then
          indicator = '⭐️'
        elseif mod >= 3 then
          indicator = '✨'
        elseif total >= 1 then
          indicator = '•'
        end
        frecency = string.format(' %s%d', indicator, total)
      end
    end

    local dir_path, filename = split_display(item, ctx)

    -- `<icon> <dir>/<name>`
    local line
    if dir_path ~= '' then
      line = icon and string.format('%s %s/%s%s', icon, dir_path, filename, frecency)
        or string.format('%s/%s%s', dir_path, filename, frecency)
    else
      line = icon and string.format('%s %s%s', icon, filename, frecency) or string.format('%s%s', filename, frecency)
    end

    local padding = math.max(0, ctx.win_width - vim.fn.strdisplaywidth(line) + 5)
    return { line .. string.rep(' ', padding) }
  end

  file_renderer.apply_highlights = function(item, ctx, item_idx, buf, ns_id, line_idx, line_content)
    if not path_first_enabled() then
      return original_apply_highlights(item, ctx, item_idx, buf, ns_id, line_idx, line_content)
    end

    local icons = require('fff.file_picker.icons')
    local highlights = require('fff.highlights')
    local file_picker = require('fff.file_picker')

    local is_cursor = (ctx.cursor == item_idx)
    local score = file_picker.get_file_score(item_idx)
    local is_current_file = score and score.current_file_penalty and score.current_file_penalty < 0

    local icon, icon_hl_group = icons.get_icon(item.name, item.extension, false)
    local dir_path, filename = split_display(item, ctx)

    -- Byte offsets of the path and of the name inside the rendered line:
    -- `<icon> <dir>/<name>`
    local path_start = icon and (#icon + 1) or 0
    local filename_start = dir_path ~= '' and (path_start + #dir_path + 1) or path_start

    -- 1. Cursor highlight
    if is_cursor then
      vim.api.nvim_buf_set_extmark(buf, ns_id, line_idx - 1, 0, {
        end_col = 0,
        end_row = line_idx,
        hl_group = ctx.config.hl.cursor,
        hl_eol = true,
        priority = 100,
      })
    end

    -- 2. Icon
    if icon and icon_hl_group and vim.fn.strdisplaywidth(icon) > 0 then
      local icon_hl = is_current_file and 'Comment' or icon_hl_group
      vim.api.nvim_buf_set_extmark(buf, ns_id, line_idx - 1, 0, {
        end_col = vim.fn.strdisplaywidth(icon),
        hl_group = icon_hl,
      })
    end

    -- 3. Git text color (file name)
    if ctx.config.git and ctx.config.git.status_text_color and icon and #filename > 0 then
      local git_text_hl = item.git_status and highlights.get_git_text_highlight(item.git_status) or nil
      if git_text_hl and git_text_hl ~= '' and not is_current_file then
        vim.api.nvim_buf_set_extmark(buf, ns_id, line_idx - 1, filename_start, {
          end_col = filename_start + #filename,
          hl_group = git_text_hl,
        })
      end
    end

    -- 4. Frecency indicator
    if ctx.debug_enabled then
      local start_pos, end_pos = line_content:find('[⭐️🔥✨•]%d+')
      if start_pos and end_pos then
        vim.api.nvim_buf_set_extmark(buf, ns_id, line_idx - 1, start_pos - 1, {
          end_col = end_pos,
          hl_group = ctx.config.hl.frecency,
        })
      end
    end

    -- 5. Directory path (dimmed)
    if #dir_path > 0 then
      vim.api.nvim_buf_set_extmark(buf, ns_id, line_idx - 1, path_start, {
        end_col = path_start + #dir_path,
        hl_group = ctx.config.hl.directory_path,
      })
    end

    -- 6. Current file
    if is_current_file then
      local hl
      if is_cursor then
        hl = ctx.config.hl.cursor
      else
        hl = 'Comment'
      end

      vim.api.nvim_buf_set_extmark(buf, ns_id, line_idx - 1, 0, {
        virt_text = { { ' ' .. ctx.config.file_picker.current_file_label, hl } },
        virt_text_pos = 'right_align',
      })
    end

    -- 7. Git sign
    if item.git_status and highlights.should_show_git_border(item.git_status) then
      local border_char = highlights.get_git_border_char(item.git_status)
      local border_hl = highlights.get_git_sign_highlight(item.git_status, is_cursor, ctx.config.hl.cursor)

      if border_hl and border_hl ~= '' then
        vim.api.nvim_buf_set_extmark(buf, ns_id, line_idx - 1, 0, {
          sign_text = border_char,
          sign_hl_group = border_hl,
          priority = 1000,
        })
      end
    elseif is_cursor then
      vim.api.nvim_buf_set_extmark(buf, ns_id, line_idx - 1, 0, {
        sign_text = ' ',
        sign_hl_group = ctx.config.hl.cursor,
        priority = 1000,
      })
    end

    -- 8. Selection
    if ctx.selected_files and ctx.selected_files[item.relative_path] then
      local selection_hl = is_cursor and ctx.config.hl.selected_active or ctx.config.hl.selected
      vim.api.nvim_buf_set_extmark(buf, ns_id, line_idx - 1, 0, {
        sign_text = '▊',
        sign_hl_group = selection_hl,
        priority = 1001,
      })
    end

    -- 9. Query matches
    if ctx.query and ctx.query ~= '' then
      local matched_hl = ctx.config.hl.matched or 'IncSearch'
      local fuzzy_highlighting = ctx.config.file_picker and ctx.config.file_picker.fuzzy_query_highlighting

      if not fuzzy_highlighting then
        local match_start, match_end = string.find(line_content, ctx.query, 1, true)
        if match_start and match_end then
          vim.api.nvim_buf_set_extmark(buf, ns_id, line_idx - 1, match_start - 1, {
            end_col = match_end,
            hl_group = matched_hl,
          })
        end
        return
      end

      local ranges = item.match_ranges
      if not ranges or #ranges == 0 then return end

      local rel_path = item.relative_path or ''
      if type(rel_path) ~= 'string' then rel_path = tostring(rel_path) end

      local original_dir_path = ''
      local parent_dir = vim.fn.fnamemodify(rel_path, ':h')
      if parent_dir ~= '.' and parent_dir ~= '' then original_dir_path = parent_dir end

      local filename_rel_start = math.max(0, #rel_path - #filename)
      local filename_rel_end = filename_rel_start + #filename
      local segments = { { filename_rel_start, filename_rel_end, filename_start } }

      if original_dir_path ~= '' and dir_path == original_dir_path then
        segments[#segments + 1] = { 0, #original_dir_path, path_start }
      end

      local function apply_segment(raw_start, raw_end, segment)
        local source_start, source_end, target_start = segment[1], segment[2], segment[3]
        local start_col = math.max(raw_start, source_start)
        local end_col = math.min(raw_end, source_end)
        if end_col <= start_col then return end

        local hl_start = target_start + (start_col - source_start)
        local hl_end = target_start + (end_col - source_start)
        if hl_start < #line_content and hl_end <= #line_content then
          vim.api.nvim_buf_set_extmark(buf, ns_id, line_idx - 1, hl_start, {
            end_col = hl_end,
            hl_group = matched_hl,
            priority = 200,
          })
        end
      end

      for _, range in ipairs(ranges) do
        local raw_start = range[1] or 0
        local raw_end = range[2] or 0
        if raw_end > raw_start then
          for _, segment in ipairs(segments) do
            apply_segment(raw_start, raw_end, segment)
          end
        end
      end
    end
  end
end

return {
  -- Configuration Defaults https://github.com/dmtrKovalenko/fff#configuration
  'fff.nvim',
  on_require = { 'fff' },
  cmd = {
    'FFFFind',
    'FFFScan',
    'FFFResume',
    'FFFLiveGrep',
    'FFFRefreshGit',
    'FFFClearCache',
    'FFFHealth',
    'FFFDebug',
    'FFFOpenLog',
  },
  keys = {
    -- Primary file finders
    {
      '<leader><leader>',
      function() require('fff').find_files({ cwd = Utils.root() }) end,
      desc = 'Find Files (fff)',
    },
    {
      '<leader>ff',
      function() require('fff').find_files({ cwd = Utils.cwd() }) end,
      desc = 'Find Files (cwd) (fff)',
    },
    {
      '<leader>fF',
      function() require('fff').find_files({ cwd = Utils.root() }) end,
      desc = 'Find Files (root) (fff)',
    },
    -- Grep
    {
      '<leader>/',
      function() require('fff').live_grep({ cwd = Utils.root() }) end,
      desc = 'Grep (root) (fff)',
    },
    {
      '<leader>sg',
      function() require('fff').live_grep({ cwd = Utils.cwd() }) end,
      desc = 'Grep (cwd) (fff)',
    },
    {
      '<leader>sG',
      function() require('fff').live_grep({ cwd = Utils.root() }) end,
      desc = 'Grep (root) (fff)',
    },
    {
      '<leader>sw',
      function() require('fff').live_grep_under_cursor({ cwd = Utils.cwd() }) end,
      mode = { 'n', 'x' },
      desc = 'Grep word/selection (cwd) (fff)',
    },
    {
      '<leader>sW',
      function() require('fff').live_grep_under_cursor({ cwd = Utils.root() }) end,
      mode = { 'n', 'x' },
      desc = 'Grep word/selection (root) (fff)',
    },
    {
      '<leader>fw',
      function() require('fff').live_grep_under_cursor() end,
      mode = { 'n', 'x' },
      desc = 'Search current word / selection (fff)',
    },
    -- Utilities
    {
      '<leader>fR',
      function() require('fff').resume() end,
      desc = 'Resume last FFF search',
    },
    {
      '<leader>fc',
      function() require('fff').open_file_under_cursor() end,
      desc = 'Open file under cursor (fff)',
    },
  },
  opts = {
    title = ' Fuzzy Fucking Finder.   󰩐 󱡴 ',
    prompt = ' ',
    prompt_vim_mode = true,
    layout = {
      prompt_position = 'top',
      preview_position = 'right',
      preview_size = 0.6,
      -- Render the path before the file name (implemented by the renderer
      -- patch below, fff itself always renders `<name> <dir>`).
      show_path_first = true,
      flex = { wrap = 'bottom' },
    },
    preview = {
      enabled = true,
      line_numbers = true,
    },
    git = {
      status_text_color = true,
    },
    grep = {
      smart_case = true,
    },
  },
  after = function() apply_path_first_patch() end,
  before = function()
    vim.api.nvim_create_autocmd('User', {
      pattern = { 'FFFOpen', 'FFFClose' },
      callback = function(ev) vim.o.showtabline = ev.match == 'FFFOpen' and 0 or 2 end,
    })
  end,
}
