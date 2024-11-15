local M = {}

local createDirIfNotExists = function(filePath)
	-- Check if directory exists
	if vim.fn.isdirectory(filePath) == 0 then -- Create the directory
		-- Create the directory
		local success = vim.fn.mkdir(filePath, "p")
		if success == -1 then
			error("Error creating directory: " .. filePath)
		end
		print(".nvim directory created.")
	else
		print(".nvim directory already exists.")
	end

	return true
end

M.openConfigFile = function()
	local homePath = os.getenv("HOME")
	local filePath = homePath .. "/.config/nvim/commands.json"

	local file = io.open(filePath, "rb")
	if file == nil then
		local choice
		repeat
			choice = vim.fn.input("commands.json isn't found do you want to create it? (y/n): ")
		until choice == "y" or choice == "n"

		if choice == "y" then
			if createDirIfNotExists(os.getenv("HOME") .. "/.config/nvim") == false then
				error("Can't create nvim directory.")
			end
			-- Create a new file and write an empty table
			local new_file = io.open(filePath, "w")
			if new_file == nil then
				error("commands.json could not be created.")
			end

			new_file:write('{\n  "commands": {\n    "ls:la": "ls -la"\n   }\n}\n')
			new_file:close()

			print(".nvim/config.json created with an empty table.")
			vim.api.nvim_command("edit " .. filePath)
		end
		return nil, ".nvim/config.json isn't found."
	end

	local jsonString = file:read("*a")
	file:close()

	return jsonString, nil
end

M.readEnvFromFile = function(filepath)
	local env_table = {}
	for line in io.lines(filepath) do
		local key, value = string.match(line, "([^=]+)=(.+)")
		if key and value then
			env_table[key] = value
		end
	end
	return env_table
end

M.getEnvTable = function(filepath)
	local envTable
	if filepath then
		local envFilePath = filepath
		envTable = M.readEnvFromFile(envFilePath)
	end
	return envTable
end

return M
