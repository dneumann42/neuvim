local Projects = {
    default_config = {
        auto_prompt_add_project = true
    },
    config = {},
    projects = {},
}

local Project = {}
Project.__index = Project

function Project:new(values)
    local tbl = vim.tbl_extend("force", {
        name = "",
        path = "",
    }, values)
    return setmetatable(tbl, self)
end

local function get_project_name()
  if vim.fn.executable("git") == 0 then
    vim.notify("git not installed, aborting", vim.log.levels.ERROR)
    return nil
  end
  local cmd = "git rev-parse --show-toplevel 2>/dev/null"
  local toplevel = vim.fn.system(cmd)
  if vim.v.shell_error ~= 0 then
    vim.notify("not a git repository", vim.log.levels.WARN)
    return nil
  end
  toplevel = vim.fn.trim(toplevel)
  local name = vim.fn.fnamemodify(toplevel, ":t")
  return name
end

local function get_git_root()
  if vim.fn.executable("git") == 0 then
    return nil, "git not installed"
  end
  local root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
  if vim.v.shell_error ~= 0 or not root or root == "" then
    return nil, "not in a git repo"
  end
  return root
end

local function get_project_path()
    -- TODO: allow changing how a project is identified
    return get_git_root()
end

function Projects.setup(cfg)
    Projects.config = vim.tbl_extend('force', Projects.default_config, cfg)
end

function Projects:add_project()
    local project = Project:new { 
        name = get_project_name(),
        path = get_project_path(),
    }

    local dir = vim.fn.expand("~/.local/share/nvim_projects")
    if uv.fs_stat(dir) == nil then
        ui.fs_mkdir(dir, 448)
    end

    local f = io.open(dir .. "projects.lua")

    return project
end

vim.print(Projects:add_project())

return Projects
