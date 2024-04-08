return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  config = function()
    require("neo-tree").setup({
      window = {
        width = 60,
      },
    })

    vim.keymap.set("n", "<leader>n", "<Cmd>Neotree filesystem reveal toggle left<CR>", { desc = "Toggle neotree" })
    vim.keymap.set("n", "<leader>bf", "<Cmd>Neotree buffers reveal toggle float<CR>", { desc = "Neotree for bufeers" })
  end,
}
