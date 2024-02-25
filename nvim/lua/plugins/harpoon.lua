return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local harpoon = require("harpoon")

    vim.keymap.set("n", "<leader>ha", function()
      harpoon:list():append()
    end)

    vim.keymap.set("n", "<leader>hh", function()
      harpoon.ui:toggle_quick_menu(harpoon:list())
    end)

    vim.keymap.set("n", "<leader>h1", function()
      harpoon:list():select(1)
    end)

    vim.keymap.set("n", "<leader>h2", function()
      harpoon:list():select(2)
    end)

    vim.keymap.set("n", "<leader>h3", function()
      harpoon:list():select(3)
    end)

    vim.keymap.set("n", "<leader>h4", function()
      harpoon:list():select(4)
    end)

    vim.keymap.set("n", "<leader>hn", function()
      harpoon:list():next()
    end)

    vim.keymap.set("n", "<leader>hp", function()
      harpoon:list():prev()
    end)
  end,
}
