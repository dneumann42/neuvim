local function packages(tbl)
    for i = 1, #tbl do
        local p = tbl[i]
        local src = p.src or p[1] or error("Expected src")
        if src:sub(1, 4) ~= "http" then
            src = "https://github.com/" .. src
        end
        p.src = src
    end
    return tbl
end

return packages {
    { "nvim-lua/plenary.nvim" },
    { "MunifTanjim/nui.nvim" },
    { "nvim-tree/nvim-web-devicons" },
    { "nvim-mini/mini.surround" },
    { "nvim-telescope/telescope.nvim" },
    { "nvim-telescope/telescope-live-grep-args.nvim" },
    { "nvim-neo-tree/neo-tree.nvim" },
    { "nvim-treesitter/nvim-treesitter" },
    { "nvim-mini/mini.indentscope" },
    { "pechorin/any-jump.vim" },
}
