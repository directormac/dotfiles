--- archives.yazi
--- Upstream: https://github.com/maximtrp/archives.yazi
--- Archive compression and extraction with fast tool detection

-- Archives plugin for Yazi file manager
-- Handles compression and extraction of various archive formats

local unpack = table.unpack or unpack

-- Unified format configurations
local FORMATS = {
	-- TAR-based compressed formats
	tar_bz2 = {
		patterns = { "%.tar%.bz2$", "%.tbz2?$" },
		compression = {
			{ tools = { "pbzip2", "lbzip2", "bzip2" }, flags = { "-cjf" } },
		},
		extraction = {
			{ tools = { "tar" }, flags = { "-xf" } },
		},
	},
	tar_bz3 = {
		patterns = { "%.tar%.bz3$", "%.tbz3$" },
		special_extraction = "pipe",
		compression = {
			{ tools = { "bzip3" }, flags = { "-cf" } },
		},
		extraction = {
			{ tools = { "tar" }, flags = { "-xf" } },
		},
	},
	tar_gz = {
		patterns = { "%.tar%.gz$", "%.tgz$", "%.taz$" },
		compression = {
			{ tools = { "pigz", "gzip" }, flags = { "-czf" } },
		},
		extraction = {
			{ tools = { "tar" }, flags = { "-xf" } },
		},
	},
	tar_xz = {
		patterns = { "%.tar%.xz$", "%.txz$", "%.tlz$" },
		compression = {
			{ tools = { "pixz", "xz" }, flags = { "-cJf" } },
		},
		extraction = {
			{ tools = { "tar" }, flags = { "-xf" } },
		},
	},
	tar_lz4 = {
		patterns = { "%.tar%.lz4$" },
		compression = {
			{ tools = { "lz4" }, flags = { "-cf" } },
		},
		extraction = {
			{ tools = { "tar" }, flags = { "-xf" } },
		},
	},
	tar_lrz = {
		patterns = { "%.tar%.lrz$" },
		compression = {
			{ tools = { "lrzip" }, flags = { "-cf" } },
		},
		extraction = {
			{ tools = { "tar" }, flags = { "-xf" } },
		},
	},
	tar_lzip = {
		patterns = { "%.tar%.lz$" },
		compression = {
			{ tools = { "plzip", "lzip" }, flags = { "-cf" } },
		},
		extraction = {
			{ tools = { "tar" }, flags = { "-xf" } },
		},
	},
	tar_lzop = {
		patterns = { "%.tar%.lzop$", "%.tzo$" },
		compression = {
			{ tools = { "lzop" }, flags = { "-cf" } },
		},
		extraction = {
			{ tools = { "tar" }, flags = { "-xf" } },
		},
	},
	tar_zst = {
		patterns = { "%.tar%.zst$" },
		compression = {
			{ tools = { "zstd" }, flags = { "-cf" } },
		},
		extraction = {
			{ tools = { "tar" }, flags = { "-xf" } },
		},
	},
	tar = {
		patterns = { "%.tar$" },
		compression = {
			{ tools = { "tar" }, flags = { "-cf" } },
			{ tools = { "7z" }, flags = { "a" } },
		},
		extraction = {
			{ tools = { "tar" }, flags = { "-xf" } },
		},
	},

	-- Single-file compression formats
	bz2 = {
		patterns = { "%.bz2$" },
		single_file = true,
		check_tar = true,
		compression = {
			{ tools = { "pbzip2", "lbzip2", "bzip2" }, flags = { "-c" } },
		},
		extraction = {
			{ tools = { "pbzip2", "lbzip2", "bzip2" }, flags = { "-dk" } },
		},
	},
	bz3 = {
		patterns = { "%.bz3$" },
		single_file = true,
		check_tar = true,
		compression = {
			{ tools = { "bzip3" }, flags = { "-c" } },
		},
		extraction = {
			{ tools = { "bzip3" }, flags = { "-dk" } },
		},
	},
	gz = {
		patterns = { "%.gz$" },
		single_file = true,
		check_tar = true,
		compression = {
			{ tools = { "pigz", "gzip" }, flags = { "-c" } },
		},
		extraction = {
			{ tools = { "pigz", "gzip" }, flags = { "-dk" } },
		},
	},
	xz = {
		patterns = { "%.xz$", "%.lzma$" },
		single_file = true,
		check_tar = true,
		compression = {
			{ tools = { "pixz", "xz" }, flags = { "-c" } },
		},
		extraction = {
			{ tools = { "pixz", "xz" }, flags = { "-dk" } },
		},
	},
	lzip = {
		patterns = { "%.lz$" },
		single_file = true,
		check_tar = true,
		compression = {
			{ tools = { "plzip", "lzip" }, flags = { "-c" } },
		},
		extraction = {
			{ tools = { "plzip", "lzip" }, flags = { "-dk" } },
		},
	},
	lz4 = {
		patterns = { "%.lz4$" },
		single_file = true,
		check_tar = true,
		compression = {
			{ tools = { "lz4" }, flags = { "-c" } },
		},
		extraction = {
			{ tools = { "lz4" }, flags = { "-dk" } },
		},
	},
	lzop = {
		patterns = { "%.lzop$" },
		single_file = true,
		check_tar = true,
		compression = {
			{ tools = { "lzop" }, flags = { "-c" } },
		},
		extraction = {
			{ tools = { "lzop" }, flags = { "-dk" } },
		},
	},
	lrzip = {
		patterns = { "%.lrz$" },
		single_file = true,
		check_tar = true,
		compression = {
			{ tools = { "lrzip" }, flags = { "-o -" } },
		},
		extraction = {
			{ tools = { "lrzip" }, flags = { "-d" } },
		},
	},

	-- Standard archive formats
	seven_zip = {
		patterns = { "%.7z$" },
		compression = {
			{ tools = { "7z" }, flags = { "a" } },
		},
		extraction = {
			{ tools = { "7z" }, flags = { "x" }, output_flag = "-o" },
		},
	},
	rar = {
		patterns = { "%.rar$" },
		compression = {
			{ tools = { "rar" }, flags = { "a", "-r" } },
		},
		extraction = {
			{ tools = { "rar", "unrar" }, flags = { "x" } },
			{ tools = { "7z" }, flags = { "x" }, output_flag = "-o" },
		},
	},
	zip = {
		patterns = { "%.zip$" },
		compression = {
			{ tools = { "zip" }, flags = { "-r" } },
			{ tools = { "7z" }, flags = { "a -tzip" } },
		},
		extraction = {
			{ tools = { "unzip" }, flags = {}, output_flag = "-d" },
			{ tools = { "7z" }, flags = { "x" }, output_flag = "-o" },
		},
	},
	zpaq = {
		patterns = { "%.zpaq$" },
		compression = {
			{ tools = { "zpaq" }, flags = { "a" } },
		},
		extraction = {
			{ tools = { "zpaq" }, flags = { "x" }, output_flag = "-to" },
		},
	},
	deb = {
		patterns = { "%.deb$" },
		extraction = {
			{ tools = { "ar" }, flags = { "-x" }, output_flag = "--output=" },
		},
	},
}

-- Utility functions
local function is_command_available(cmd)
	if not cmd or cmd == "" then
		ya.dbg("is_command_available: empty command")
		return false
	end

	local output = Command("which"):arg(cmd):output()
	local available = output and output.status.success
	ya.dbg("is_command_available: " .. cmd .. " = " .. tostring(available))
	return available
end

local function find_available_tool(tools)
	if not tools then
		ya.dbg("find_available_tool: no tools provided")
		return nil
	end
	ya.dbg("find_available_tool: checking tools: " .. table.concat(tools, ", "))
	for _, tool in ipairs(tools) do
		if is_command_available(tool) then
			ya.dbg("find_available_tool: found " .. tool)
			return tool
		end
	end
	ya.dbg("find_available_tool: no tools available")
	return nil
end

local function find_available_tool_group(tool_groups)
	if not tool_groups then
		ya.dbg("find_available_tool_group: no tool groups provided")
		return nil, nil
	end

	for _, group in ipairs(tool_groups) do
		local tool = find_available_tool(group.tools)
		if tool then
			ya.dbg("find_available_tool_group: found tool " .. tool .. " with flags")
			return tool, group.flags, group.output_flag
		end
	end
	ya.dbg("find_available_tool_group: no tool groups available")
	return nil, nil, nil
end

local function is_tar_format(format_name)
	return format_name and format_name:match("^tar_") or format_name == "tar"
end

local function match_format_patterns(filename, patterns)
	for _, pattern in ipairs(patterns) do
		if filename:lower():match(pattern) then
			return true
		end
	end
	return false
end

local function find_archive_format(filename, format_table)
	ya.dbg("find_archive_format: checking " .. filename)

	-- Create sorted list by pattern specificity (longest patterns first)
	local sorted_formats = {}
	for format_name, config in pairs(format_table) do
		local max_len = 0
		for _, pattern in ipairs(config.patterns) do
			max_len = math.max(max_len, #pattern)
		end
		table.insert(sorted_formats, { name = format_name, config = config, len = max_len })
	end
	table.sort(sorted_formats, function(a, b)
		return a.len > b.len
	end)

	-- Check formats in order of specificity
	for _, entry in ipairs(sorted_formats) do
		if match_format_patterns(filename, entry.config.patterns) then
			ya.dbg("find_archive_format: matched " .. entry.name)
			return entry.name, entry.config
		end
	end
	ya.dbg("find_archive_format: no format matched")
	return nil, nil
end

-- Path utilities
local function convert_to_relative_paths(files, base_dir)
	local base_url = Url(base_dir)
	local relative_files = {}

	for i, file_path in ipairs(files) do
		local file_url = Url(file_path)
		local relative_url = file_url:strip_prefix(base_url)
		relative_files[i] = tostring(relative_url)
	end

	return relative_files
end

-- Command array builder that filters out nil values
local function build_cmd_array(...)
	local result = {}
	for i = 1, select("#", ...) do
		local v = select(i, ...)
		if v ~= nil then
			result[#result + 1] = v
		end
	end
	return result
end

-- Yazi context access functions
local get_selected_files = ya.sync(function()
	local paths = {}
	for _, f in pairs(cx.active.selected) do
		paths[#paths + 1] = tostring(f.url)
	end
	if #paths == 0 and cx.active.current.hovered then
		paths[1] = tostring(cx.active.current.hovered.url)
	end
	return paths
end)

local get_current_directory = ya.sync(function()
	return tostring(cx.active.current.cwd)
end)

-- Command builders
local function build_tar_command_with_compression(compression_tool, flags, archive_name, files)
	if not is_command_available("tar") then
		return nil
	end
	return build_cmd_array(
		"tar",
		unpack(flags),
		archive_name,
		"--use-compress-program",
		compression_tool,
		unpack(files)
	)
end

local function build_single_file_compression_command(compression_tool, flags, archive_name, files)
	if #files == 1 then
		ya.dbg("build_single_file_compression_command: single file, using original flags")
		local flags_str = table.concat(flags or {}, " ")
		return {
			"sh",
			"-c",
			compression_tool
				.. " "
				.. flags_str
				.. " "
				.. ya.quote(files[1])
				.. " > "
				.. ya.quote(archive_name),
		}
	end

	-- Convert to tar format for multiple files
	ya.dbg("build_single_file_compression_command: multiple files, converting to tar format")
	for _, format_config in pairs(FORMATS) do
		if format_config.single_file then
			for _, pattern in ipairs(format_config.patterns) do
				if archive_name:lower():match(pattern) then
					local clean_pattern = pattern:gsub("^%%", ""):gsub("%$$", "")
					local tar_name = archive_name:gsub(clean_pattern, ".tar" .. clean_pattern)
					ya.dbg("build_single_file_compression_command: converted " .. archive_name .. " to " .. tar_name)

					-- Find the corresponding tar format and use its flags
					local tar_format_name, tar_format_config = find_archive_format(tar_name, FORMATS)
					if tar_format_config and is_tar_format(tar_format_name) then
						local tar_tool, tar_flags = find_available_tool_group(tar_format_config.compression)
						if tar_flags then
							ya.dbg(
								"build_single_file_compression_command: found tar format "
									.. tar_format_name
									.. " with flags "
									.. table.concat(tar_flags, " ")
							)
							return build_tar_command_with_compression(tar_tool, tar_flags, tar_name, files)
						end
					end
					ya.dbg("build_single_file_compression_command: no tar format found, using fallback")
					return build_tar_command_with_compression(compression_tool, { "-cf" }, tar_name, files)
				end
			end
		end
	end
	ya.dbg("build_single_file_compression_command: no pattern matched, using fallback .tar")
	return build_tar_command_with_compression(compression_tool, { "-cf" }, archive_name .. ".tar", files)
end

local function build_compression_command(archive_name, files)
	ya.dbg("build_compression_command: " .. archive_name .. " with " .. #files .. " files")
	local format_name, format_config = find_archive_format(archive_name, FORMATS)
	if not format_config then
		ya.dbg("build_compression_command: no format config found")
		return nil
	end
	ya.dbg("build_compression_command: using format " .. (format_name or "unknown"))

	-- Try to find available compression tools
	local tool, flags, _ = find_available_tool_group(format_config.compression)
	if not tool then
		ya.dbg("build_compression_command: no compression tools available")
		return nil
	end

	-- Single-file compression
	if format_config.single_file then
		ya.dbg("build_compression_command: single-file compression")
		return build_single_file_compression_command(tool, flags, archive_name, files)
	end

	-- TAR-based compression
	if is_tar_format(format_name) then
		ya.dbg("build_compression_command: tar-based compression")
		if is_command_available("tar") then
			return build_tar_command_with_compression(tool, flags, archive_name, files)
		end
		ya.dbg("build_compression_command: tar not available")
		return nil
	end

	-- Standard archive formats
	ya.dbg("build_compression_command: standard archive format")
	local cmd = build_cmd_array(tool, unpack(flags or {}), archive_name, unpack(files))
	ya.dbg("build_compression_command: built command: " .. table.concat(cmd, " "))
	return cmd
end

local function get_fallback_compression_command(archive_name, files)
	local zip_config = FORMATS.zip
	local tool, flags = find_available_tool_group(zip_config.compression)
	if tool then
		return build_cmd_array(tool, unpack(flags or {}), archive_name, unpack(files))
	end

	return nil
end

-- Archive extraction
local function is_compressed_tar_archive(file_path)
	return file_path:lower():match("%.tar%.")
end

local function build_extraction_command(archive_path, output_dir)
	ya.dbg("build_extraction_command: " .. archive_path .. (output_dir and (" to " .. output_dir) or ""))
	local format_name, format_config = find_archive_format(archive_path, FORMATS)

	-- Special handling for formats that need piped extraction
	if format_config and format_config.special_extraction == "pipe" then
		ya.dbg("build_extraction_command: detected special pipe extraction for " .. (format_name or "unknown"))
		local compression_tool, compression_flags = find_available_tool_group(format_config.compression)
		if compression_tool and is_command_available("tar") then
			local cmd = { "sh", "-c" }
			local pipe_cmd = compression_tool .. " -dc " .. ya.quote(archive_path) .. " | tar -xf -"
			if output_dir then
				pipe_cmd = pipe_cmd .. " -C " .. ya.quote(output_dir)
			end
			table.insert(cmd, pipe_cmd)
			ya.dbg("build_extraction_command: pipe command: " .. pipe_cmd)
			return cmd
		end
		ya.dbg("build_extraction_command: compression tool or tar not available for pipe extraction")
		return nil
	end

	if not format_config then
		ya.dbg("build_extraction_command: no format config found")
		return nil
	end

	-- Handle ambiguous compressed files
	if format_config.check_tar then
		ya.dbg("build_extraction_command: checking if compressed tar")
		if is_compressed_tar_archive(archive_path) then
			ya.dbg("build_extraction_command: treating as compressed tar")
			-- Treat as compressed tar
			if is_command_available("tar") then
				local cmd = build_cmd_array("tar", "-xf", archive_path)
				if output_dir then
					table.insert(cmd, "-C")
					table.insert(cmd, output_dir)
				end
				ya.dbg("build_extraction_command: compressed tar command: " .. table.concat(cmd, " "))
				return cmd
			end
		else
			ya.dbg("build_extraction_command: treating as single-file compression")
			-- Treat as single-file compression - use standard extraction approach
			local tool, flags = find_available_tool_group(format_config.extraction)
			if tool then
				local cmd = build_cmd_array(tool, unpack(flags or {}), archive_path)
				ya.dbg("build_extraction_command: single-file decompression command: " .. table.concat(cmd, " "))
				return cmd
			end
		end
		ya.dbg("build_extraction_command: ambiguous file handling failed")
		return nil
	end

	-- Standard extraction with unified approach
	ya.dbg("build_extraction_command: using format " .. (format_name or "unknown"))

	local tool, flags, output_flag = find_available_tool_group(format_config.extraction)
	if not tool then
		ya.dbg("build_extraction_command: no extraction tool available")
		return nil
	end

	ya.dbg("build_extraction_command: using tool " .. tool)
	local cmd = build_cmd_array(tool, unpack(flags or {}), archive_path)
	if output_dir and output_flag then
		if output_flag == "-o" then
			table.insert(cmd, "-o" .. output_dir)
		elseif output_flag == "--output=" then
			table.insert(cmd, "--output=" .. output_dir)
		elseif output_flag == "" then
			table.insert(cmd, output_dir)
		else
			table.insert(cmd, output_flag)
			table.insert(cmd, output_dir)
		end
	end

	ya.dbg("build_extraction_command: final command: " .. table.concat(cmd, " "))
	return cmd
end

-- Core operations
local function execute_command_safely(cmd, cwd)
	if not cmd or #cmd == 0 then
		ya.dbg("execute_command_safely: no command to execute")
		return false, "No command to execute"
	end

	ya.dbg("execute_command_safely: executing: " .. table.concat(cmd, " "))
	local args = {}
	for i = 2, #cmd do
		args[#args + 1] = cmd[i]
	end

	local builder = Command(cmd[1]):arg(args)
	if cwd then
		builder = builder:cwd(cwd)
	end

	local output, err = builder:output()

	if output and output.status.success then
		ya.dbg("execute_command_safely: command succeeded")
		if output.stdout and output.stdout ~= "" then
			ya.dbg("execute_command_safely: stdout: " .. output.stdout)
		end
		return true, nil
	else
		local error_msg = "Unknown error"
		if output and output.stderr and output.stderr ~= "" then
			error_msg = output.stderr
		elseif err then
			error_msg = tostring(err)
		end
		ya.dbg("execute_command_safely: command failed: " .. error_msg)
		return false, error_msg
	end
end

local function validate_files(files)
	if not files or #files == 0 then
		return false, "No files selected"
	end
	return true, nil
end

local function validate_archive_name(archive_name)
	if not archive_name or archive_name == "" then
		return false, "Archive name cannot be empty"
	end
	return true, nil
end

local function compress_selected_files(archive_name, files)
	ya.dbg("compress_selected_files: starting compression of " .. archive_name)
	local is_valid, error_msg = validate_files(files)
	if not is_valid then
		ya.dbg("compress_selected_files: file validation failed: " .. error_msg)
		ya.notify({
			title = "Archives",
			content = error_msg,
			level = "error",
			timeout = 5,
		})
		return
	end

	is_valid, error_msg = validate_archive_name(archive_name)
	if not is_valid then
		ya.dbg("compress_selected_files: archive name validation failed: " .. error_msg)
		ya.notify({
			title = "Archives",
			content = error_msg,
			level = "error",
			timeout = 5,
		})
		return
	end

	local current_dir = get_current_directory()
	local relative_files = convert_to_relative_paths(files, current_dir)
	ya.dbg("compress_selected_files: files: " .. table.concat(relative_files, ", "))

	local cmd = build_compression_command(archive_name, relative_files)
	if not cmd then
		ya.dbg("compress_selected_files: trying fallback compression")
		cmd = get_fallback_compression_command(archive_name, relative_files)
	end

	if not cmd then
		ya.dbg("compress_selected_files: no compression command available")
		ya.notify({
			title = "Archives",
			content = "No suitable compression tool found",
			level = "error",
			timeout = 5,
		})
		return
	end

	local success, err = execute_command_safely(cmd, current_dir)

	if success then
		ya.dbg("compress_selected_files: compression successful")
		ya.notify({
			title = "Archives",
			content = "Compressed successfully",
			timeout = 4,
		})
		ya.emit("refresh", {})
	else
		ya.dbg("compress_selected_files: compression failed: " .. err)
		ya.notify({
			title = "Archives",
			content = "Compression failed: " .. err,
			level = "error",
			timeout = 5,
		})
	end
end

local function extract_selected_files(files, output_dir)
	ya.dbg("extract_selected_files: starting extraction" .. (output_dir and (" to " .. output_dir) or ""))
	local is_valid, error_msg = validate_files(files)
	if not is_valid then
		ya.dbg("extract_selected_files: file validation failed: " .. error_msg)
		ya.notify({
			title = "Archives",
			content = error_msg,
			level = "error",
			timeout = 5,
		})
		return
	end

	local current_dir = get_current_directory()

	for _, file in ipairs(files) do
		ya.dbg("extract_selected_files: processing " .. file)
		local cmd = build_extraction_command(file, output_dir)
		if not cmd then
			ya.dbg("extract_selected_files: no extraction command for " .. file)
			ya.notify({
				title = "Archives",
				content = "Unsupported archive format: " .. file:match("[^/]+$"),
				level = "warn",
				timeout = 5,
			})
			goto continue
		end

		local success, err = execute_command_safely(cmd, current_dir)

		if success then
			ya.dbg("extract_selected_files: extraction successful for " .. file)
			ya.notify({
				title = "Archives",
				content = "Extracted successfully",
				timeout = 5,
			})
		else
			ya.dbg("extract_selected_files: extraction failed for " .. file .. ": " .. err)
			ya.notify({
				title = "Archives",
				content = "Extraction failed: " .. err,
				level = "error",
				timeout = 5,
			})
		end

		::continue::
	end
	ya.emit("refresh", {})
end

local function show_usage()
	ya.notify({
		title = "Archives",
		content = "Usage:\n  compress [archive_name]\n  extract [output_dir]",
		level = "info",
		timeout = 5,
	})
end

local function handle_compress_command(args)
	local files = get_selected_files()

	if #files == 0 then
		ya.notify({
			title = "Archives",
			content = "No files selected",
			level = "error",
			timeout = 5,
		})
		return
	end

	local archive_name = args[2]

	if archive_name then
		compress_selected_files(archive_name, files)
	else
		local current_dir = get_current_directory()
		local current_dir_name = current_dir:match("[^/]+$") or "current directory"

		local value, event = ya.input({
			title = "Compress to archive (in " .. current_dir_name .. "):",
			pos = { "center", w = 50 },
		})

		if event == 1 and value and value ~= "" then
			compress_selected_files(value, files)
		end
	end
end

local function handle_extract_command(args)
	local files = get_selected_files()
	local output_dir = args[2]
	extract_selected_files(files, output_dir)
end

-- Plugin entry point
local plugin = {
	entry = function(self, job)
		local args = job.args
		local command = args[1]

		if command == "compress" then
			handle_compress_command(args)
		elseif command == "extract" then
			handle_extract_command(args)
		else
			show_usage()
		end
	end,
}

return plugin
